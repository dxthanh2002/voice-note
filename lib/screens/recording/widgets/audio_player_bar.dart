import 'package:flutter/material.dart';

import '../../../theme/colors.dart';

class AudioPlayerBar extends StatelessWidget {
  const AudioPlayerBar({
    super.key,
    required this.isPlaying,
    required this.progress,
    required this.currentTime,
    required this.totalTime,
    required this.onPlayPause,
    required this.onSeek,
    required this.onRewind,
    required this.onForward,
    required this.onEdit,
    required this.onShare,
  });

  final bool isPlaying;
  final double progress;
  final String currentTime;
  final String totalTime;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onSeek;
  final VoidCallback onRewind;
  final VoidCallback onForward;
  final VoidCallback onEdit;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.edit_note,
                    label: 'Chỉnh sửa',
                    onPressed: onEdit,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.ios_share,
                    label: 'Chia sẻ',
                    onPressed: onShare,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Progress bar
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                final box = context.findRenderObject() as RenderBox;
                final localPosition = box.globalToLocal(details.globalPosition);
                final progress =
                    (localPosition.dx / box.size.width).clamp(0.0, 1.0);
                onSeek(progress);
              },
              onTapDown: (details) {
                final box = context.findRenderObject() as RenderBox;
                final localPosition = box.globalToLocal(details.globalPosition);
                final progress =
                    (localPosition.dx / box.size.width).clamp(0.0, 1.0);
                onSeek(progress);
              },
              child: Stack(
                children: [
                  // Background track
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.dividerDark,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Progress indicator
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Time & controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 48,
                  child: Text(
                    currentTime,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                          fontFamily: 'monospace',
                        ),
                  ),
                ),
                // Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onRewind,
                      icon: const Icon(Icons.replay_10),
                      color: AppColors.textMuted,
                      iconSize: 32,
                    ),
                    const SizedBox(width: 8),
                    // Play/Pause button
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: onPlayPause,
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        color: Colors.white,
                        iconSize: 32,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onForward,
                      icon: const Icon(Icons.forward_10),
                      color: AppColors.textMuted,
                      iconSize: 32,
                    ),
                  ],
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    totalTime,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                          fontFamily: 'monospace',
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.dividerDark,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
