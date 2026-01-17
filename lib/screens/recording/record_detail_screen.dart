import 'package:aimateflutter/models/meeting.dart';
import 'package:aimateflutter/services/repository.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../theme/colors.dart';
import 'tabs/chat_ai_tab.dart';
import 'tabs/summary_tab.dart';
import 'tabs/transcript_tab.dart';
import 'widgets/audio_player_bar.dart';
import 'widgets/pill_tab_bar.dart';

import '../../utils/format.dart';

class RecordDetailScreen extends StatefulWidget {
  const RecordDetailScreen({super.key, this.id});

  final String? id;

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _selectedTabIndex = 0;

  MeetingDetail? _detail;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  bool _isPlaying = false;
  bool _loading = true;

  final List<String> _tabs = ['Transcript', 'Summary', 'Chat AI'];

  @override
  void initState() {
    super.initState();

    _loadMeeting();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadMeeting() async {
    try {
      final response = await Repository.getMeetingDetail(widget.id!);

      setState(() {
        _detail = response;
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
    if (_loading || _detail == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final meeting = _detail!.meeting;

    return Hero(
      tag: 'meeting_card_${widget.id}',
      child: Scaffold(
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
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final meeting = _detail!.meeting;

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
            onPressed: () => Navigator.pop(context),
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
          IconButton(
            onPressed: () {
              // TODO: More options
            },
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(MeetingResponse meeting) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 20),
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
        return const SummaryTab();
      case 2:
        return const ChatAITab();
      default:
        return TranscriptTab(id: id);
    }
  }

  Widget _buildBottomBar() {
    if (_selectedTabIndex == 2) return const SizedBox.shrink();

    final meeting = _detail!.meeting;
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
