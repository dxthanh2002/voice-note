import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../components/app_button.dart';

class RecordingControlsBar extends StatelessWidget {
  const RecordingControlsBar({
    super.key,
    required this.duration,
    required this.isPaused,
    required this.onPause,
    required this.onStop,
  });

  final Duration duration;
  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          top: BorderSide(color: AppColors.dividerDark),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Recording badge
            _RecordingBadge(isPaused: isPaused),
            const SizedBox(height: 16),
            // Timer
            Text(
              _formatDuration(duration),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()],
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 20),
            // Waveform
            _WaveformVisualization(isActive: !isPaused),
            const SizedBox(height: 24),
            // Control buttons
            Row(
              children: [
                // Pause button
                Expanded(
                  child: AppButton(
                    onPressed: onPause,
                    icon: isPaused ? Icons.play_arrow : Icons.pause,
                    label: isPaused ? 'Tiếp tục' : 'Tạm dừng',
                    size: AppButtonSize.large,
                    variant: AppButtonVariant.secondary,
                    fullWidth: true,
                  ),
                ),
                const SizedBox(width: 16),
                // Stop button
                Expanded(
                  child: AppButton(
                    onPressed: onStop,
                    icon: Icons.stop,
                    label: 'Dừng',
                    size: AppButtonSize.large,
                    variant: AppButtonVariant.primary,
                    isDestructive: true,
                    fullWidth: true,
                  ),
                ),
              ],
            ),
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

class _RecordingBadge extends StatefulWidget {
  const _RecordingBadge({required this.isPaused});

  final bool isPaused;

  @override
  State<_RecordingBadge> createState() => _RecordingBadgeState();
}

class _RecordingBadgeState extends State<_RecordingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (!widget.isPaused) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_RecordingBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused && _controller.isAnimating) {
      _controller.stop();
    } else if (!widget.isPaused && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isPaused ? AppColors.warning : Colors.red;
    final text = widget.isPaused ? 'ĐÃ TẠM DỪNG' : 'ĐANG GHI ÂM';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing dot
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: widget.isPaused ? 1.0 : _animation.value,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: widget.isPaused
                      ? null
                      : [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformVisualization extends StatelessWidget {
  const _WaveformVisualization({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(7, (index) {
          // Create varied heights for visual interest
          final heights = [12.0, 20.0, 32.0, 40.0, 24.0, 16.0, 8.0];
          final activeHeight = heights[index];
          final inactiveHeight = 8.0;

          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + index * 50),
            width: 6,
            height: isActive ? activeHeight : inactiveHeight,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isActive
                  ? (index == 3
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.4 + index * 0.1))
                  : AppColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
