import 'package:aimateflutter/features/home/create_record/create_record_modal.dart';
import 'package:aimateflutter/services/audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../components/bouncing_button.dart';
import '../../components/shimmer_loading.dart';
import '../../models/meeting.dart';
import '../../navigation/routes.dart';
import '../../services/ads/interstitial_sdk.dart';
import '../../services/data/recordings.dart';
import '../../theme/colors.dart';
import '../../utils/console.dart';
import '../../utils/format.dart';
import 'recordings_viewmodel.dart'; // Import the ViewModel

class RecordingsScreen extends StatefulWidget {
  const RecordingsScreen({super.key});

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen> {
  // ViewModel will be accessed through Provider
  late RecordingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RecordingsViewModel();
    // Initialize ViewModel after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadRecordings();
    });
  }

  @override
  void dispose() {
    // Dispose ViewModel resources
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: const _RecordingsScreenContent(),
    );
  }
}

class _RecordingsScreenContent extends StatelessWidget {
  const _RecordingsScreenContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            child: Column(
              children: [
                // Header Section
                _buildHeaderSection(context, viewModel),

                // Section header
                _buildSectionHeader(context),

                // List Section
                _buildListSection(context, viewModel),
              ],
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(context, viewModel),
        );
      },
    );
  }

  // ============ Header Section ============
  Widget _buildHeaderSection(
    BuildContext context,
    RecordingsViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),

      child: Column(
        children: [
          // Search Bar (expandable)
          _buildSearchBar(context, viewModel),

          // Title and Search Icon
          _buildTitleRow(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, RecordingsViewModel viewModel) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: viewModel.isSearchExpanded
              ? MediaQuery.of(context).size.width - 48
              : 0,
          height: viewModel.isSearchExpanded ? 40 : 0,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: viewModel.isSearchExpanded
              ? Row(
                  children: [
                    Semantics(
                      button: true,
                      label: 'Close search',
                      child: GestureDetector(
                        onTap: () => viewModel.closeSearch(),
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.arrow_back,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: viewModel.searchController,
                        focusNode: viewModel.searchFocusNode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          suffixIcon: viewModel.searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () =>
                                      viewModel.searchController.clear(),
                                  child: Icon(
                                    Icons.close,
                                    color: AppColors.textMuted,
                                    size: 18,
                                  ),
                                )
                              : null,
                          suffixIconConstraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context, RecordingsViewModel viewModel) {
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: viewModel.isSearchExpanded
              ? const SizedBox(height: 12)
              : const SizedBox.shrink(),
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recordings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${viewModel.recordings.length} items',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!viewModel.isSearchExpanded)
              Semantics(
                button: true,
                label: 'Search recordings',
                child: GestureDetector(
                  onTap: () => viewModel.expandSearch(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.search,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ============ Section Header ============
  Widget _buildSectionHeader(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: Colors.white.withValues(alpha: 0.1),
          thickness: 1,
          height: 1,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT ACTIVITY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              // TODO: Implement sort functionality if needed
            ],
          ),
        ),
      ],
    );
  }

  // ============ List Section ============
  Widget _buildListSection(
    BuildContext context,
    RecordingsViewModel viewModel,
  ) {
    return Expanded(
      child: viewModel.isLoading
          ? const RecordingListShimmer()
          : RefreshIndicator(
              onRefresh: () => viewModel.loadRecordings(),
              child: viewModel.recordings.isEmpty
                  ? _buildEmptyState(context)
                  : _buildRecordingsList(context, viewModel),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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

  Widget _buildRecordingsList(
    BuildContext context,
    RecordingsViewModel viewModel,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: viewModel.recordings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final recording = viewModel.recordings[index];
        return RecordingCard(
          meeting: recording,
          onTap: () async {
            InterstitialManager.startShowAutoLoadInterstitialAd();
            await Future.delayed(const Duration(seconds: 2));

            if (context.mounted) {
              viewModel.navigateToRecordingDetail(context, recording.meetingId);
            }
          },
          onDelete: () =>
              viewModel.deleteRecording(context, recording.meetingId),
          onRename: () => viewModel.renameRecording(
            context,
            recording.meetingId,
            recording.title,
          ),
        );
      },
    );
  }

  // ============ Floating Action Button ============
  Widget _buildFloatingActionButton(
    BuildContext context,
    RecordingsViewModel viewModel,
  ) {
    return BouncingButton(
      semanticLabel: 'Create new recording',
      onPressed: () => _onCreateRecording(context, viewModel),
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
    );
  }

  Future<void> _onCreateRecording(
    BuildContext context,
    RecordingsViewModel viewModel,
  ) async {
    final granted = await AudioService.requestPermissions();
    if (!granted) {
      Console.warning('XXX Permissions not granted');
      return;
    }

    // create record sheet
    final newMeeting = await showDialog<MeetingResponse>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) => const CreateRecordModal(),
    );

    if (newMeeting != null && context.mounted && granted) {
      final meetingId = await Navigator.pushNamed(
        context,
        AppRoutes.recordControl,
        arguments: newMeeting,
      );

      if (meetingId != null && meetingId is String && context.mounted) {
        await viewModel.navigateToRecordingDetail(context, meetingId);
      }
      viewModel.loadRecordings();
    }
  }
}

// ============ Recording Card Component ============
class RecordingCard extends StatelessWidget {
  const RecordingCard({
    super.key,
    required this.meeting,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  final Recording meeting;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  String _getStatusText() {
    if (meeting.status == 'done') {
      return 'Ready';
    } else if (meeting.status == 'processing') {
      return 'Processing';
    } else if (meeting.status == 'failed') {
      return 'Error';
    }
    return 'Raw Audio';
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'meeting_card_${meeting.id}',
      child: Semantics(
        button: true,
        label:
            '${meeting.title}, recorded on ${formatDate(meeting.recordedAt)}, duration ${formatDurationFromSeconds(meeting.duration)}, status ${_getStatusText()}',
        child: Material(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainRow(context),
                  const SizedBox(height: 8),
                  _buildStatusBadge(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.audio_file,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meeting.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    formatDate(meeting.recordedAt),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
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
                    formatDurationFromSeconds(meeting.duration),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildOptionsMenu(),
      ],
    );
  }



  Widget _buildOptionsMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      onSelected: (value) {
        if (value == 'delete') {
          onDelete();
        } else if (value == 'rename') {
          onRename();
        }
      },
      icon: const Icon(Icons.more_horiz, size: 20, color: AppColors.textMuted),
      color: AppColors.cardDark,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
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
              const Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              const Text('Rename', style: TextStyle(fontSize: 13)),
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
              const Icon(Icons.delete, size: 16, color: AppColors.error),
              const SizedBox(width: 8),
              const Text(
                'Delete',
                style: TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    Color bgColor;
    String text;
    IconData icon;

    if (meeting.status == 'done') {
      color = AppColors.success;
      bgColor = AppColors.success.withValues(alpha: 0.1);
      text = 'Ready';
      icon = Icons.check_circle;
    } else if (meeting.status == 'processing') {
      color = AppColors.warning;
      bgColor = AppColors.warning.withValues(alpha: 0.1);
      text = 'Processing';
      icon = Icons.schedule;
    } else if (meeting.status == 'failed') {
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),

      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
