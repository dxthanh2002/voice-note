import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/colors.dart';
// TODO: Uncomment when Chat AI feature is ready
// import 'tabs/chat_ai_tab.dart';
import 'detai_record_viewmodel.dart';
import 'tabs/summary_tab.dart';
import 'tabs/transcript_tab.dart';
import 'widgets/audio_player_bar.dart';
import 'widgets/pill_tab_bar.dart';
import '../../utils/format.dart';

// Main Screen
class DetailRecordScreen extends StatefulWidget {
  final String? id;

  const DetailRecordScreen({super.key, this.id});

  @override
  State<DetailRecordScreen> createState() => _DetailRecordScreenState();
}

class _DetailRecordScreenState extends State<DetailRecordScreen> {
  late DetailRecordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DetailRecordViewModel(id: widget.id);
    _viewModel.loadMeetingInfo();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: const _DetailRecordScreenContent(),
    );
  }
}

// Screen Content
class _DetailRecordScreenContent extends StatelessWidget {
  const _DetailRecordScreenContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailRecordViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading || viewModel.meetingInfo == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundDark,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // App Bar
                _HeaderBar(viewModel: viewModel),
                // Content
                Expanded(child: _Content(viewModel: viewModel)),
                // Bottom bar - Audio player
                _BottomAudioPlayBar(viewModel: viewModel),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderBar extends StatelessWidget {
  final DetailRecordViewModel viewModel;

  const _HeaderBar({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.meetingInfo == null) return const SizedBox.shrink();

    // final meeting = viewModel.meetingDetail!.meeting;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          bottom: BorderSide(
            color: AppColors.dividerDark.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => viewModel.onNavigateBack(context),
            tooltip: 'Go back',
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              viewModel.meetingInfo?.title ?? "Unknown",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'More options',
            offset: const Offset(0, 48),
            onSelected: (value) async {
              if (value == 'delete') {
                await viewModel.deleteRecording(context);
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } else if (value == 'rename') {
                await viewModel.renameRecording(context);
              }
            },
            icon: const Icon(Icons.more_vert, size: 20, color: Colors.white),
            color: AppColors.cardDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            menuPadding: EdgeInsets.zero,
            itemBuilder: (context) => [
              PopupMenuItem(
                height: 40,
                value: 'rename',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text('Rename', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem(
                height: 40,
                value: 'delete',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete, size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final DetailRecordViewModel viewModel;

  const _Content({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.meetingInfo == null) return const SizedBox.shrink();

    final meeting = viewModel.meetingInfo;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              Text(
                meeting != null
                    ? 'Recorded on ${formatDate(meeting.recordedAt)}'
                    : "Recorded on Unknown",
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              PillTabBar(
                tabs: viewModel.tabs,
                selectedIndex: viewModel.selectedTabIndex,
                onTabSelected: viewModel.selectTab,
              ),
            ],
          ),
        ),
        Expanded(child: _buildTabContent()),
      ],
    );
  }

  Widget _buildTabContent() {
    if (viewModel.meetingInfo == null) return const SizedBox.shrink();

    final meetingId = viewModel.meetingInfo!.meetingId;

    switch (viewModel.selectedTabIndex) {
      case 0:
        return TranscriptTab(id: meetingId);
      case 1:
        return SummaryTab(id: meetingId);
      // TODO: Uncomment when Chat AI feature is ready
      // case 2:
      //   return const ChatAITab();
      default:
        return TranscriptTab(id: meetingId);
    }
  }
}

class _BottomAudioPlayBar extends StatelessWidget {
  final DetailRecordViewModel viewModel;

  const _BottomAudioPlayBar({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // TODO: Uncomment when Chat AI feature is ready
    // if (viewModel.selectedTabIndex == 2) return const SizedBox.shrink();
    if (viewModel.meetingInfo == null) return const SizedBox.shrink();

    final total = viewModel.duration.inMilliseconds > 0
        ? viewModel.duration
        : Duration(seconds: viewModel.meetingInfo!.duration);

    final progress = total.inMilliseconds == 0
        ? 0.0
        : viewModel.position.inMilliseconds / total.inMilliseconds;

    return AudioPlayerBar(
      isPlaying: viewModel.isPlaying,
      progress: progress.clamp(0.0, 1.0),
      currentTime: formatDuration(viewModel.position),
      totalTime: formatDuration(total),
      onPlayPause: viewModel.togglePlayPause,
      onSeek: viewModel.seekAudio,
      onRewind: viewModel.rewindAudio,
      onForward: viewModel.forwardAudio,
      onEdit: () {
        // TODO: Edit
      },
      onShare: () {
        // TODO: Share
      },
    );
  }
}
