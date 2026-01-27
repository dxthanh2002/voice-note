import 'package:flutter/material.dart';

import '../../../models/transcript.dart';
import '../../../theme/colors.dart';
import 'speaker_avatar.dart';

/// Widget that displays a transcript message in chat-style format
///
/// Layout: [Avatar] [Speaker Name + Message + Timestamp]
/// All messages aligned to the left
class TranscriptMessageBubble extends StatelessWidget {
  const TranscriptMessageBubble({
    super.key,
    required this.item,
    this.showAvatar = true,
  });

  final TranscriptItem item;
  final bool showAvatar; // Hide avatar for consecutive same-speaker messages

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 8,
        top: showAvatar ? 12 : 0, // Extra spacing when showing avatar
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar (or spacer for grouped messages)
          if (showAvatar)
            SpeakerAvatar(speaker: item.speaker, size: 36)
          else
            const SizedBox(width: 36),
          const SizedBox(width: 12),
          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Speaker name + timestamp (only show when avatar is shown)
                if (showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          item.speaker,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.formattedStartTime,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.textMuted,
                              ),
                        ),
                      ],
                    ),
                  ),
                // Message text
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Text(
                    item.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
