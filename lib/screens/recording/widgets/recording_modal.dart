import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aimateflutter/services/repository.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:provider/provider.dart';

import '../../../services/audio.dart';
import '../../../services/meeting.dart';
import '../../../theme/colors.dart';
import '../../../utils/format.dart';

enum RecordingModalState { initial, recording, paused }

class RecordingModal extends StatefulWidget {
  const RecordingModal({super.key});

  /// Shows the recording modal and returns the file path on success, null on cancel
  static Future<String?> show(BuildContext context) {
    return showDialog<String?>(
      context: context,
      barrierDismissible: false, // We control this manually based on state
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => const RecordingModal(),
    );
  }

  @override
  State<RecordingModal> createState() => _RecordingModalState();
}

class _RecordingModalState extends State<RecordingModal>
    with TickerProviderStateMixin {
  RecordingModalState _state = RecordingModalState.initial;
  AudioService? _audioService;
  bool _isStopping = false;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<RecordingState>? _stateSubscription;

  Duration _duration = Duration.zero;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _appearController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _appearController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _appearController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _appearController,
            curve: Curves.easeOutCubic,
          ),
        );

    _appearController.forward();
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _stateSubscription?.cancel();
    _pulseController.dispose();
    _appearController.dispose();
    _audioService?.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    _audioService = AudioService();

    _durationSubscription = _audioService!.durationStream.listen((duration) {
      if (mounted && !_isStopping) setState(() => _duration = duration);
    });

    _stateSubscription = _audioService!.stateStream.listen((state) {
      if (!mounted || _isStopping) return;
      if (state == RecordingState.recording) {
        setState(() => _state = RecordingModalState.recording);
        _pulseController.repeat(reverse: true);
      } else if (state == RecordingState.paused) {
        setState(() => _state = RecordingModalState.paused);
        _pulseController.stop();
      }
    });

    final success = await _audioService!.startRecording();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to start recording. Please check permissions.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _togglePause() async {
    await _audioService?.togglePause();
  }

  Future<void> _stopRecording() async {
    if (_audioService == null || _isStopping) return;

    setState(() => _isStopping = true);
    _pulseController.stop();
    
    // Cancel subscriptions to stop timer updates
    await _durationSubscription?.cancel();
    await _stateSubscription?.cancel();

    // Timeout after 7 seconds
    final timeoutTimer = Timer(const Duration(seconds: 7), () {
      if (mounted && _isStopping) {
        debugPrint('[STOP] Timeout after 7 seconds, returning to home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing timeout. Please try again.'),
            backgroundColor: AppColors.warning,
          ),
        );
        Navigator.pop(context, null);
      }
    });

    try {
      final filePath = await _audioService!.stopRecording();

      if (filePath == null) {
        debugPrint('No file path returned from recording');
        timeoutTimer.cancel();
        if (mounted) Navigator.pop(context, null);
        return;
      }

      // Get file size
      // final fileSize = await _audioService!.getFileSize(filePath);
      final fileName = path.basename(filePath);
      final duration = _audioService!.recordedDuration;
      debugPrint('Recording saved: $filePath');
      debugPrint('Duration: $duration');
      debugPrint('Seconds: ${duration.inSeconds}}');

      // Get presigned URL and upload to S3
      debugPrint('Meeting title: $fileName');
      final withoutExtension = fileName.substring(0, fileName.length - 4);
      debugPrint('New name: $withoutExtension');

      try {
        debugPrint('[STOP] Step 1: Creating meeting...');
        final newMeeting = await Repository.createMeeting(withoutExtension);
        debugPrint('[STOP] Step 1 done: Meeting created with id=${newMeeting.id}');
        
        debugPrint('[STOP] Step 2: Getting presigned URL...');
        final presigned = await Repository.getPresignedUrl(
          newMeeting.id,
          fileName,
          duration.inSeconds,
        );
        debugPrint('[STOP] Step 2 done: Got presigned URL');

        debugPrint('[STOP] Step 3: Uploading audio...');
        final code = await Repository.uploadAudio(presigned.url, filePath);
        debugPrint('[STOP] Step 3 done: Upload code=$code');

        debugPrint('[STOP] Step 4: Confirming...');
        final responseConfirm = await Repository.confirm(presigned.audioId);
        debugPrint('[STOP] Step 4 done: Confirmed');
        if (!mounted) return;

        debugPrint('[STOP] Step 5: Loading meetings...');
        final meetingService = context.read<MeetingService>();
        await meetingService.loadMeetings();
        debugPrint('[STOP] Step 5 done: Meetings loaded');

        timeoutTimer.cancel();
        if (mounted) Navigator.pop(context, responseConfirm.meetingId);
      } catch (e) {
        debugPrint('Error getting presigned URL: $e');
        timeoutTimer.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload error: $e'),
              backgroundColor: AppColors.error,
            ),
          );
          Navigator.pop(context, null);
        }
      }
    } catch (e) {
      debugPrint('Error in stopRecording: $e');
      timeoutTimer.cancel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping recording: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.pop(context, null);
      }
    }
  }

  void _handleOutsideTap() {
    if (_state == RecordingModalState.initial) {
      Navigator.pop(context);
    }
    // Ignore tap outside when recording or paused
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _state == RecordingModalState.initial,
      child: GestureDetector(
        onTap: _handleOutsideTap,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: _state == RecordingModalState.initial
                          ? _buildInitialState()
                          : _buildRecordingState(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Microphone icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mic, size: 40, color: AppColors.primary),
        ),
        const SizedBox(height: 20),
        const Text(
          'Ready to record',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap the button below to start',
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        _BouncingButton(
          onPressed: _startRecording,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'Start recording',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Cancel hint
        Text(
          'Tap outside to cancel',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingState() {
    final isPaused = _state == RecordingModalState.paused;
    final isRecording = _state == RecordingModalState.recording;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRecording)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(
                        alpha: _pulseAnimation.value,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
            if (isRecording) const SizedBox(width: 8),
            Text(
              isPaused ? 'Paused' : 'Recording...',
              style: TextStyle(
                color: isPaused ? AppColors.warning : AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Timer
        Semantics(
          label: 'Recording duration: ${formatDuration(_duration)}',
          liveRegion: true,
          child: Text(
            formatDuration(_duration),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Waveform visualization
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AudioWaveforms(
            recorderController: _audioService!.recorderController,
            size: Size(MediaQuery.of(context).size.width - 120, 48),
            waveStyle: WaveStyle(
              waveColor: AppColors.primary,
              extendWaveform: true,
              showMiddleLine: false,
              spacing: 4.0,
              waveThickness: 3.0,
              showBottom: true,
              waveCap: StrokeCap.round,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Controls or Loading
        if (_isStopping)
          Column(
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Processing...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Pause/Resume button
              _ModalControlButton(
                icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                label: isPaused ? 'Resume' : 'Pause',
                backgroundColor:
                    isPaused ? AppColors.success : AppColors.primary,
                onTap: _togglePause,
              ),
              // Stop button
              _ModalControlButton(
                icon: Icons.stop_rounded,
                label: 'Stop',
                backgroundColor: AppColors.error,
                onTap: _stopRecording,
              ),
            ],
          ),
      ],
    );
  }
}

class _ModalControlButton extends StatefulWidget {
  const _ModalControlButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  State<_ModalControlButton> createState() => _ModalControlButtonState();
}

class _ModalControlButtonState extends State<_ModalControlButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.85);
  }

  void _onTapUp(TapUpDetails details) {
    HapticFeedback.lightImpact();
    setState(() => _scale = 1.0);
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.onTap();
    });
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutBack,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.backgroundColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(widget.icon, size: 32, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.label,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BouncingButton extends StatefulWidget {
  const _BouncingButton({required this.onPressed, required this.child});

  final VoidCallback onPressed;
  final Widget child;

  @override
  State<_BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<_BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.08,
          end: 0.97,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.97,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    HapticFeedback.mediumImpact();
    setState(() => _isPressed = false);
    _controller.forward(from: 0);
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _controller.isAnimating ? _scaleAnimation.value : 1.0,
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
