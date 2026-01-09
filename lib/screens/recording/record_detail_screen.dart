import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../../data/recordings_repository.dart';
import '../../theme/colors.dart';
import 'tabs/chat_ai_tab.dart';
import 'tabs/summary_tab.dart';
import 'tabs/transcript_tab.dart';
import 'widgets/audio_player_bar.dart';
import 'widgets/pill_tab_bar.dart';
import 'widgets/recording_modal.dart';

class RecordDetailScreen extends StatefulWidget {
  const RecordDetailScreen({super.key, this.recording});

  final Recording? recording;

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  int _selectedTabIndex = 0;

  Recording? _currentRecording;
  bool _isLoading = false;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  Recording? get recording => _currentRecording ?? widget.recording;

  final List<String> _tabs = ['Phiên âm', 'Tóm tắt', 'Chat AI'];

  @override
  void initState() {
    super.initState();
    _currentRecording = widget.recording;

    if (widget.recording == null) {
      // Show recording modal after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRecordingModal();
      });
    } else {
      _initAudioPlayer();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initAudioPlayer() async {
    final rec = recording;
    if (rec == null) return;

    try {
      await _audioPlayer.setFilePath(rec.filePath);

      // Listen to player state
      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });

      // Listen to position
      _audioPlayer.positionStream.listen((pos) {
        if (mounted) {
          setState(() {
            _position = pos;
          });
        }
      });

      // Listen to duration
      _audioPlayer.durationStream.listen((dur) {
        if (mounted && dur != null) {
          setState(() {
            _duration = dur;
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  Future<void> _showRecordingModal() async {
    final result = await RecordingModal.show(context);

    if (result == null) {
      // User cancelled, go back
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    // Recording completed, save to repository
    if (mounted) {
      setState(() => _isLoading = true);

      final repository = context.read<RecordingsRepository>();
      final savedRecording = await repository.addRecording(
        result.filePath,
        result.duration,
      );

      if (savedRecording != null && mounted) {
        setState(() {
          _currentRecording = savedRecording;
          _isLoading = false;
        });

        _initAudioPlayer();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã lưu: ${p.basename(result.filePath)}'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while saving recording
    if (_isLoading || recording == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
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
            _buildAppBar(context),
            // Content
            Expanded(
              child: Column(
                children: [
                  // File info & tabs
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // File info
                        Text(
                          '${_getFileName(recording!.title)}.m4a',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Đã ghi vào ${_formatDate(recording!.date)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                        ),
                        const SizedBox(height: 20),
                        // Tab bar
                        PillTabBar(
                          selectedIndex: _selectedTabIndex,
                          onTabSelected: (index) {
                            setState(() => _selectedTabIndex = index);
                          },
                          tabs: _tabs,
                        ),
                      ],
                    ),
                  ),
                  // Tab content
                  Expanded(
                    child: _buildTabContent(),
                  ),
                ],
              ),
            ),
            // Bottom bar - Audio player
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
              recording!.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return const TranscriptTab();
      case 1:
        return const SummaryTab();
      case 2:
        return const ChatAITab();
      default:
        return const TranscriptTab();
    }
  }

  Widget _buildBottomBar() {
    // Show audio player (only on Phiên âm and Tóm tắt tabs)
    if (_selectedTabIndex != 2) {
      final totalDuration = _duration.inMilliseconds > 0
          ? _duration
          : recording!.duration;
      final progress = totalDuration.inMilliseconds > 0
          ? _position.inMilliseconds / totalDuration.inMilliseconds
          : 0.0;

      return AudioPlayerBar(
        isPlaying: _isPlaying,
        progress: progress.clamp(0.0, 1.0),
        currentTime: _formatDuration(_position),
        totalTime: _formatDuration(totalDuration),
        onPlayPause: () {
          if (_isPlaying) {
            _audioPlayer.pause();
          } else {
            _audioPlayer.play();
          }
        },
        onSeek: (value) {
          final newPosition = Duration(
            milliseconds: (value * totalDuration.inMilliseconds).round(),
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
          _audioPlayer.seek(
            newPosition > totalDuration ? totalDuration : newPosition,
          );
        },
        onEdit: () {
          // TODO: Edit
        },
        onShare: () {
          // TODO: Share
        },
      );
    }

    return const SizedBox.shrink();
  }

  String _getFileName(String title) {
    // Convert title to filename format
    return title
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\u00C0-\u024F]'), '');
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}
