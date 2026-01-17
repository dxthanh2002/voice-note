import 'dart:async';

import 'package:flutter/material.dart';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path/path.dart' as p;

import '../../services/audio.dart';
import '../../theme/colors.dart';

class ActiveRecordScreen extends StatefulWidget {
  const ActiveRecordScreen({super.key});

  @override
  State<ActiveRecordScreen> createState() => _ActiveRecordScreenState();
}

class _ActiveRecordScreenState extends State<ActiveRecordScreen>
    with SingleTickerProviderStateMixin {
  late final AudioService _recorderService;
  Duration _duration = Duration.zero;
  RecordingState _state = RecordingState.idle;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<RecordingState>? _stateSubscription;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _recorderService = AudioService();

    // Pulse animation for recording indicator
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Listen to duration updates
    _durationSubscription = _recorderService.durationStream.listen((duration) {
      setState(() => _duration = duration);
    });

    // Listen to state changes
    _stateSubscription = _recorderService.stateStream.listen((state) {
      setState(() => _state = state);
      if (state == RecordingState.recording) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    });

    // Start recording automatically
    _startRecording();
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _stateSubscription?.cancel();
    _pulseController.dispose();
    _recorderService.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final success = await _recorderService.startRecording();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to start recording. Please check permissions.'),
          backgroundColor: AppColors.error,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _togglePause() async {
    await _recorderService.togglePause();
  }

  Future<void> _stopRecording() async {
    final filePath = await _recorderService.stopRecording();
    if (filePath != null && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recording saved: ${p.basename(filePath)}'),
          backgroundColor: AppColors.success,
        ),
      );
      // Navigate back
      Navigator.pop(context, filePath);
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _cancelRecording() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Cancel recording?'),
        content: const Text(
          'This recording will be deleted and cannot be recovered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue recording'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancel recording'),
          ),
        ],
      ),
    );

    if (shouldCancel == true && mounted) {
      await _recorderService.cancelRecording();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPaused = _state == RecordingState.paused;
    final isRecording = _state == RecordingState.recording;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        leading: IconButton(
          onPressed: _cancelRecording,
          icon: const Icon(Icons.close),
        ),
        title: const Text('New recording'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Status indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isRecording) ...[
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
                  const SizedBox(width: 8),
                ],
                Text(
                  isPaused ? 'Paused' : 'Recording...',
                  style: TextStyle(
                    color: isPaused ? AppColors.warning : AppColors.error,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Timer
            Text(
              _formatDuration(_duration),
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              isPaused ? 'Tap play to resume' : 'Recording from microphone',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 32),
            // Waveform visualization
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isRecording
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.dividerDark,
                ),
              ),
              child: AudioWaveforms(
                recorderController: _recorderService.recorderController,
                size: Size(MediaQuery.of(context).size.width - 96, 64),
                waveStyle: WaveStyle(
                  waveColor: AppColors.primary,
                  extendWaveform: true,
                  showMiddleLine: false,
                  spacing: 5.0,
                  waveThickness: 3.0,
                  showBottom: true,
                  waveCap: StrokeCap.round,
                ),
              ),
            ),
            const Spacer(),
            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Stop button
                  _ControlButton(
                    icon: Icons.stop_rounded,
                    label: 'Stop',
                    backgroundColor: AppColors.cardDark,
                    iconColor: AppColors.textPrimary,
                    size: 72,
                    onTap: _stopRecording,
                  ),
                  // Pause/Resume button
                  _ControlButton(
                    icon: isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    label: isPaused ? 'Resume' : 'Pause',
                    backgroundColor: isPaused
                        ? AppColors.success
                        : AppColors.primary,
                    iconColor: Colors.white,
                    size: 88,
                    isMain: true,
                    onTap: _togglePause,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

class _ControlButton extends StatefulWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.size,
    required this.onTap,
    this.isMain = false,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final VoidCallback onTap;
  final bool isMain;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.85);
  }

  void _onTapUp(TapUpDetails details) {
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
    return Column(
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
            child: Material(
              color: widget.backgroundColor,
              shape: widget.isMain
                  ? const CircleBorder()
                  : RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
              elevation: 4,
              shadowColor: widget.backgroundColor.withValues(alpha: 0.3),
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Icon(
                  widget.icon,
                  size: widget.size * 0.5,
                  color: widget.iconColor,
                ),
              ),
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
    );
  }
}
