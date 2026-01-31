import 'package:aimateflutter/models/meeting.dart';
import 'package:aimateflutter/services/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../../services/ads/ads.dart';
import '../../services/process.dart';
import '../../services/recording.dart';
import '../../theme/colors.dart';
import '../../utils/console.dart';
// TODO: Uncomment when Chat AI feature is ready
// import 'tabs/chat_ai_tab.dart';
import 'tabs/summary_tab.dart';
import 'tabs/transcript_tab.dart';
import 'widgets/audio_player_bar.dart';
import 'widgets/pill_tab_bar.dart';

import '../../utils/format.dart';

class DetailRecordScreen extends StatefulWidget {
  final String? id;

  const DetailRecordScreen({super.key, this.id});

  @override
  State<DetailRecordScreen> createState() => _DetailRecordScreenState();
}

class _DetailRecordScreenState extends State<DetailRecordScreen> {
  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _selectedTabIndex = 0;

  MeetingDetail? _detailMeeting;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  bool _isPlaying = false;
  bool _loading = true;

  // TODO: Uncomment when Chat AI feature is ready
  // final List<String> _tabs = ['Transcript', 'Summary', 'Chat AI'];
  final List<String> _tabs = ['Transcript', 'Summary'];

  @override
  void initState() {
    super.initState();

    _loadMeetingInfo();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadMeetingInfo() async {
    try {
      // if uploaded to server or not ? confirm
      Console.log("HEHEHEHE DETAIL");
      final response = await Repository.getMeetingbyId(widget.id!);

      Console.log(widget.id!);
      await Repository.getMeetingbyId(widget.id!);

      setState(() {
        _detailMeeting = response;
        _loading = false;
      });

      if (response.audio?.playUrl != null) {
        await _initAudioPlayer(response.audio!.playUrl);
      } else {
        debugPrint('No audio URL available for this meeting');
        // You might want to show a message to the user
      }
    } catch (e) {
      debugPrint('Failed to load meeting: $e');
    }
  }

  Future<void> _initAudioPlayer(String url) async {
    try {
      await _audioPlayer.setUrl(url);

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() => _isPlaying = state.playing);
        }
      });

      _audioPlayer.positionStream.listen((pos) {
        if (mounted) {
          setState(() => _position = pos);
        }
      });

      _audioPlayer.durationStream.listen((dur) {
        if (mounted) {
          setState(() => _duration = dur ?? Duration.zero);
        }
      });
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while saving recording
    if (_loading || _detailMeeting == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final meeting = _detailMeeting!.meeting;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),
            // Content
            Expanded(child: _buildContent(meeting)),
            // Bottom bar - Audio player
            _buildBottomPlayBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final meeting = _detailMeeting!.meeting;

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
            onPressed: () async {
              final shouldExit = await _showExitConfirmation(context);
              if (shouldExit && mounted) {
                // show ads
                Console.log("WHATTT");
                Console.log("WHATTT");
                InterstitialManager.show();
                Future.delayed(const Duration(milliseconds: 300));

                Navigator.pop(context, true);
              }
            },
            tooltip: 'Go back',
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              meeting.title,
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
                await RecordingService.deleteRecording(
                  context,
                  meeting.id,
                  refresh: false,
                );
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } else if (value == 'rename') {
                await RecordingService.renameRecording(
                  context,
                  meeting.id,
                  meeting.title,
                  refresh: false,
                );
                if (context.mounted) {
                  await _loadMeetingInfo();
                }
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

  Future<bool> _showExitConfirmation(BuildContext context) async {
    // Check if any processing is happening
    final isTranscriptProcessing = ProcessingService().isProcessing(
      "transcript_${widget.id}",
    );
    final isSummaryProcessing = ProcessingService().isProcessing(
      "summary_${widget.id}",
    );

    final isAnyProcessing = isTranscriptProcessing || isSummaryProcessing;

    // If no processing, just exit
    if (!isAnyProcessing) {
      return true; // Allow exit
    }

    // If processing, show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Processing in Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('If you exit now:'),
            const SizedBox(height: 8),
            Text(
              '• The transcript proccess will lose',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit Anyway'),
          ),
        ],
      ),
    );

    return confirmed ?? false; // Return false if user cancels
  }

  Widget _buildContent(MeetingResponse meeting) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            children: [
              // Text(
              //   '${_getFileName(meeting.title)}.mp3',
              //   style: Theme.of(
              //     context,
              //   ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              //   textAlign: TextAlign.center,
              // ),
              // const SizedBox(height: 4),
              Text(
                'Recorded on ${formatDate(meeting.startedAt)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              PillTabBar(
                tabs: _tabs,
                selectedIndex: _selectedTabIndex,
                onTabSelected: (i) => setState(() => _selectedTabIndex = i),
              ),
            ],
          ),
        ),
        Expanded(child: _buildTabContent(meeting.id)),
      ],
    );
  }

  Widget _buildTabContent(String id) {
    switch (_selectedTabIndex) {
      case 0:
        return TranscriptTab(id: id);
      case 1:
        return SummaryTab(id: id);
      // TODO: Uncomment when Chat AI feature is ready
      // case 2:
      //   return const ChatAITab();
      default:
        return TranscriptTab(id: id);
    }
  }

  Widget _buildBottomPlayBar() {
    // TODO: Uncomment when Chat AI feature is ready
    // if (_selectedTabIndex == 2) return const SizedBox.shrink();

    final meeting = _detailMeeting!.meeting;
    final meetingDuration = meeting.duration ?? Duration.zero;
    final total = _duration.inMilliseconds > 0 ? _duration : meetingDuration;

    final progress = total.inMilliseconds == 0
        ? 0.0
        : _position.inMilliseconds / total.inMilliseconds;

    return AudioPlayerBar(
      isPlaying: _isPlaying,
      progress: progress.clamp(0.0, 1.0),
      currentTime: formatDuration(_position),
      totalTime: formatDuration(total),
      onPlayPause: () {
        if (_isPlaying) {
          _audioPlayer.pause();
        } else {
          _audioPlayer.play();
        }
      },
      onSeek: (value) {
        final newPosition = Duration(
          milliseconds: (value * total.inMilliseconds).round(),
        );
        _audioPlayer.seek(newPosition);
      },
      onRewind: () {
        final newPosition = _position - const Duration(seconds: 10);
        _audioPlayer.seek(
          newPosition < Duration.zero ? Duration.zero : newPosition,
        );
      },
      onForward: () {
        final newPosition = _position + const Duration(seconds: 10);
        _audioPlayer.seek(newPosition > total ? total : newPosition);
      },
      onEdit: () {
        // TODO: Edit
      },
      onShare: () {
        // TODO: Share
      },
    );
  }
}
