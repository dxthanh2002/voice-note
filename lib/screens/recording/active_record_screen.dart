import 'dart:async';

import 'package:flutter/material.dart';
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
        content: const Text('This recording will be deleted and cannot be recovered.'),
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
              isPaused
                  ? 'Tap play to resume'
                  : 'Recording from microphone',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 32),
            // Waveform placeholder
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isRecording ? AppColors.primary : AppColors.textMuted)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(20, (index) {
                    final height = isRecording
                        ? 20.0 + (index % 5) * 10.0
                        : 8.0;
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200 + index * 20),
                      width: 4,
                      height: height,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color:
                            (isRecording
                                    ? AppColors.primary
                                    : AppColors.textMuted)
                                .withValues(alpha: isRecording ? 0.8 : 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const Spacer(),
            // Controls
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(width: 32),
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
                  const SizedBox(width: 32),
                  // Placeholder for alignment
                  const SizedBox(width: 72),
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

class _ControlButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: isMain ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isMain ? null : BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: size * 0.5, color: iconColor),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
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
