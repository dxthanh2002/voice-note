import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/bouncing_button.dart';
import '../../components/button.dart';
import '../../components/shimmer_loading.dart';
import '../../models/meeting.dart';
import '../../services/meeting.dart';
import '../../navigation/app_routes.dart';
import '../../theme/colors.dart';
import '../../utils/format.dart';
import '../recording/create_record_sheet.dart';
import '../../services/repository.dart';

class RecordingsTab extends StatefulWidget {
  const RecordingsTab({super.key});

  @override
  State<RecordingsTab> createState() => _RecordingsTabState();
}

class _RecordingsTabState extends State<RecordingsTab> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Load recordings on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeetingService>().loadMeetings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final meetingService = context.watch<MeetingService>();
    final meetings = meetingService.meetings;
    final isLoading = meetingService.isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recordings',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${meetings.length} recent recordings',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
    const SizedBox(width: 12),
    SizedBox(
      width: 160, // slightly smaller = safer
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<MeetingService>().searchByTitleLive(value);
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.cardDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          isDense: true,
        ),
      ),
    ),
  ],
),

            ),
            // Section header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LIST',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     // TODO: Sort
                  //   },
                  //   style: TextButton.styleFrom(
                  //     padding: EdgeInsets.zero,
                  //     minimumSize: Size.zero,
                  //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  //   ),
                  //   child: Text(
                  //     'Sắp xếp',
                  //     style: TextStyle(
                  //       color: AppColors.primary,
                  //       fontSize: 14,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            // List
            Expanded(
              child: isLoading
                  ? const RecordingListShimmer()
                  : RefreshIndicator(
                      onRefresh: () => meetingService.loadMeetings(),
                      child: meetings.isEmpty
                          ? _buildEmptyState(context)
                          : _buildMeetingList(context, meetings),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: BouncingButton(
        onPressed: () => _showCreateRecordSheet(context),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.mic, size: 32, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    // Wrap in ListView to enable pull-to-refresh
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic_off,
                      size: 56,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No recordings yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the mic button to start recording your first meeting.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pull down to refresh',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingList(
    BuildContext context,
    List<MeetingResponse> meetings,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: meetings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        return _MeetingCard(meeting: meeting);
      },
    );
  }

  void _showCreateRecordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const CreateRecordSheet(),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  const _MeetingCard({required this.meeting});

  final MeetingResponse meeting;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'meeting_card_${meeting.id}',
      child: Material(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.recordDetail,
              arguments: meeting.id,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meeting.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                formatDate(meeting.startedAt),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textMuted),
                              ),
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.textMuted.withValues(
                                    alpha: 0.5,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                formatDuration(meeting.duration),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete recording?'),
                              content: Text(
                                'Are you sure you want to delete "${meeting.title}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            try {
                              await Repository.delete(meeting.id);
                              if (!context.mounted) return;
                              context.read<MeetingService>().loadMeetings();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Deleted "${meeting.title}"'),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${e.toString()}')),
                              );
                            }
                          }
                        } else if (value == 'rename') {
                          _showRenameDialog(context, meeting);
                        }
                      },
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      color: AppColors.cardDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(
                                Icons.share,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              const Text('Share'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              const Text('Rename'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                size: 20,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Delete',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Status & Play row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusBadge(meeting: meeting),
                    PlayButton(
                      onPressed: () {
                        // TODO: Quick play
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showRenameDialog(BuildContext context, MeetingResponse meeting) {
  final controller = TextEditingController(text: meeting.title);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Rename'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Enter new name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final newName = controller.text.trim();
            if (newName.isNotEmpty && newName != meeting.title) {
              try {
                await Repository.rename(meeting.id, newName);
                if (!context.mounted) return;
                context.read<MeetingService>().loadMeetings();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Renamed to "$newName"')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.meeting});

  final MeetingResponse meeting;

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    String text;
    IconData icon;

    if (meeting.transcriptStatus == 'DONE' && meeting.hasSummary) {
      color = AppColors.success;
      bgColor = AppColors.success.withValues(alpha: 0.1);
      text = 'Ready';
      icon = Icons.check_circle;
    } else if (meeting.transcriptStatus == 'PROCESSING') {
      color = AppColors.warning;
      bgColor = AppColors.warning.withValues(alpha: 0.1);
      text = 'Processing';
      icon = Icons.schedule;
    } else if (meeting.transcriptStatus == 'FAILED') {
      color = AppColors.error;
      bgColor = AppColors.error.withValues(alpha: 0.1);
      text = 'Error';
      icon = Icons.error;
    } else {
      color = AppColors.textMuted;
      bgColor = AppColors.textMuted.withValues(alpha: 0.1);
      text = 'Raw Audio';
      icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
