import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        border: Border(top: BorderSide(color: AppColors.dividerDark)),
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
            // TODO: Uncomment when Edit/Share features are developed
            // Row(
            //   children: [
            //     Expanded(
            //       child: _ActionButton(
            //         icon: Icons.edit_note,
            //         label: 'Chỉnh sửa',
            //         onPressed: onEdit,
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Expanded(
            //       child: _ActionButton(
            //         icon: Icons.ios_share,
            //         label: 'Chia sẻ',
            //         onPressed: onShare,
            //       ),
            //     ),
            //   ],
            // ),
            // Progress bar
            Semantics(
              label: 'Audio progress: $currentTime of $totalTime',
              slider: true,
              value: '${(progress * 100).round()} percent',
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(details.globalPosition);
                  final progress = (localPosition.dx / box.size.width).clamp(
                    0.0,
                    1.0,
                  );
                  onSeek(progress);
                },
                onTapDown: (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(details.globalPosition);
                  final progress = (localPosition.dx / box.size.width).clamp(
                    0.0,
                    1.0,
                  );
                  onSeek(progress);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onRewind();
                      },
                      tooltip: 'Rewind 10 seconds',
                      icon: const Icon(Icons.replay_10),
                      color: AppColors.textMuted,
                      iconSize: 32,
                    ),
                    const SizedBox(width: 8),
                    // Play/Pause button
                    Semantics(
                      button: true,
                      label: isPlaying ? 'Pause audio' : 'Play audio',
                      child: Container(
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
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            onPlayPause();
                          },
                          tooltip: isPlaying ? 'Pause' : 'Play',
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          color: Colors.white,
                          iconSize: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onForward();
                      },
                      tooltip: 'Forward 10 seconds',
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
