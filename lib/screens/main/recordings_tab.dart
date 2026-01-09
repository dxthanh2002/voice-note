import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/recordings_repository.dart';
import '../../navigation/app_routes.dart';
import '../../theme/colors.dart';
import '../recording/create_record_sheet.dart';

class RecordingsTab extends StatefulWidget {
  const RecordingsTab({super.key});

  @override
  State<RecordingsTab> createState() => _RecordingsTabState();
}

class _RecordingsTabState extends State<RecordingsTab> {
  @override
  void initState() {
    super.initState();
    // Load recordings on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecordingsRepository>().loadRecordings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<RecordingsRepository>();
    final recordings = repository.recordings;
    final isLoading = repository.isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ghi âm',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${recordings.length} bản ghi gần đây',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        // TODO: Search
                      },
                      icon: const Icon(Icons.search, size: 22),
                      color: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
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
                    'DANH SÁCH',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Sort
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Sắp xếp',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => repository.refresh(),
                      child: recordings.isEmpty
                          ? _buildEmptyState(context)
                          : _buildRecordingsList(context, recordings, repository),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showCreateRecordSheet(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.mic, size: 32),
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
                    'Chưa có bản ghi nào',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn nút mic để bắt đầu ghi âm cuộc họp đầu tiên.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kéo xuống để làm mới',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingsList(
    BuildContext context,
    List<Recording> recordings,
    RecordingsRepository repository,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: recordings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final recording = recordings[index];
        return _RecordingCard(
          recording: recording,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.recordDetail,
              arguments: recording,
            );
          },
          onDelete: () => _confirmDelete(context, recording, repository),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Recording recording,
    RecordingsRepository repository,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Xóa bản ghi?'),
        content: Text(
          'Bản ghi "${recording.title}" sẽ bị xóa vĩnh viễn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      final success = await repository.deleteRecording(recording.id);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Đã xóa "${recording.title}"' : 'Không thể xóa bản ghi',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
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

class _RecordingCard extends StatelessWidget {
  const _RecordingCard({
    required this.recording,
    required this.onTap,
    required this.onDelete,
  });

  final Recording recording;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
            ),
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
                          recording.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _formatDate(recording.date),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                            ),
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.textMuted.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              _formatDuration(recording.duration),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
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
                            Icon(Icons.share, size: 20, color: AppColors.textSecondary),
                            const SizedBox(width: 12),
                            const Text('Chia sẻ'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'rename',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20, color: AppColors.textSecondary),
                            const SizedBox(width: 12),
                            const Text('Đổi tên'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: AppColors.error),
                            const SizedBox(width: 12),
                            Text('Xóa', style: TextStyle(color: AppColors.error)),
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
                  _StatusBadge(hasSummary: recording.hasSummary),
                  _PlayButton(onPressed: () {
                    // TODO: Quick play
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} thg ${date.month}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.hasSummary});

  final bool hasSummary;

  @override
  Widget build(BuildContext context) {
    final color = hasSummary ? AppColors.success : AppColors.warning;
    final bgColor = hasSummary
        ? AppColors.success.withValues(alpha: 0.1)
        : AppColors.warning.withValues(alpha: 0.1);
    final borderColor = hasSummary
        ? AppColors.success.withValues(alpha: 0.2)
        : AppColors.warning.withValues(alpha: 0.2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasSummary ? Icons.check_circle : Icons.hourglass_top,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            hasSummary ? 'Đã tóm tắt' : 'Chưa tóm tắt',
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

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        hoverColor: AppColors.primary,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: const Icon(
            Icons.play_arrow,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
