import 'dart:async';

import 'package:aimateflutter/features/recordings/recordings_viewmodel.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:aimateflutter/services/repository.dart';
import '../../../services/database.dart';
import '../../../services/audio.dart';
import '../../../theme/colors.dart';
import '../../../utils/console.dart';
import '../../../utils/format.dart';

enum RecordingScreenState { loading, initial, recording, paused }

class RecordingScreen extends StatefulWidget {
  final RecordingsViewModel viewModel;
  final String title;

  const RecordingScreen({
    super.key,
    required this.viewModel,
    required this.title,
  });

  static Future<String?> show(
    BuildContext context,
    RecordingsViewModel viewModel, {
    required String title,
  }) {
    return Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => RecordingScreen(viewModel: viewModel, title: title),
      ),
    );
  }

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with TickerProviderStateMixin {
  RecordingScreenState _state = RecordingScreenState.loading;
  AudioService? _audioService;
  Duration _duration = Duration.zero;

  late AnimationController _pulseController;
  List<double> _waveHeights = [];
  double _smoothedAmp = 0.0;
  StreamSubscription<double>? _ampSubscription;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _waveHeights = List.generate(18, (_) => 0.1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeRecording();
    });
  }

  Future<void> _initializeRecording() async {
    // Show loading for a brief moment
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() => _state = RecordingScreenState.initial);
      _startRecording();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ampSubscription?.cancel();

    _audioService?.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    _audioService = AudioService();

    _audioService!.durationStream.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });

    _audioService!.stateStream.listen((state) {
      if (!mounted) return;
      if (state == RecordingState.recording) {
        setState(() => _state = RecordingScreenState.recording);
        _pulseController.repeat(reverse: true);
        _startAmplitudeListening();
      } else if (state == RecordingState.paused) {
        setState(() => _state = RecordingScreenState.paused);
        _pulseController.stop();
        _ampSubscription?.cancel();
      }
    });

    final success = await _audioService!.startRecording();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể bắt đầu ghi âm. Vui lòng kiểm tra quyền truy cập.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _startAmplitudeListening() {
    _ampSubscription?.cancel();
    _ampSubscription = _audioService!.amplitudeStream.listen((amp) {
      if (!mounted || _state != RecordingScreenState.recording) return;

      // Exponential smoothing
      _smoothedAmp = 0.3 * amp + 0.7 * _smoothedAmp;

      // Gate noise floor
      final value = _smoothedAmp < 0.05 ? 0.1 : _smoothedAmp;

      setState(() {
        _waveHeights.removeAt(0);
        _waveHeights.add(value);
      });
    });
  }

  Future<void> _togglePause() async {
    await _audioService?.togglePause();
  }

  Future<void> _stopRecording() async {
    if (_audioService == null) return;

    try {
      final filePath = await _audioService!.stopRecording();

      if (filePath == null) {
        Console.log('No file path returned from recording');
        if (mounted) Navigator.pop(context, null);
        return;
      }

      final fileName = p.basename(filePath);
      final duration = _audioService!.recordedDuration.inSeconds;
      Console.log('Recording saved: $filePath');

      final meetingTitle = widget.title.isNotEmpty ? widget.title : fileName;

      try {
        final newMeeting = await Repository.createMeeting(meetingTitle);

        final db = DatabaseService();
        await db.save(
          meetingId: newMeeting.id,
          fileName: fileName,
          filePath: filePath,
          duration: duration,
          status: 'raw',
        );

        await widget.viewModel.loadRecordings();

        if (mounted) Navigator.pop(context, newMeeting.id);
      } catch (e) {
        debugPrint('Error creating meeting: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi tải lên: $e'),
              backgroundColor: AppColors.error,
            ),
          );
          Navigator.pop(context, null);
        }
      }
    } catch (e) {
      debugPrint('Error in stopRecording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi dừng ghi âm: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.pop(context, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1222),
        body: SafeArea(
          child: _state == RecordingScreenState.loading
              ? _buildLoadingState()
              : Column(
                  children: [
                    _buildHeader(),
                    Expanded(child: _buildMainContent()),
                    _buildFooter(),
                    const SizedBox(height: 8),
                    _buildHomeIndicator(),
                    const SizedBox(height: 8),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        // Header shimmer
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              _buildShimmerCircle(40),
              Expanded(
                child: Column(
                  children: [
                    _buildShimmerBox(80, 10),
                    const SizedBox(height: 8),
                    _buildShimmerBox(150, 16),
                  ],
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
        // Main content shimmer - positioned in upper area
        const SizedBox(height: 32),
        // Waveform shimmer
        SizedBox(
          height: 180,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(18, (index) {
              final heights = [
                48,
                96,
                64,
                128,
                160,
                112,
                170,
                144,
                80,
                180,
                128,
                160,
                64,
                96,
                48,
                128,
                80,
                112,
              ];
              return Shimmer.fromColors(
                baseColor: Colors.white.withValues(alpha: 0.08),
                highlightColor: Colors.white.withValues(alpha: 0.15),
                child: Container(
                  width: 4,
                  height: heights[index].toDouble(),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 48),
        // Timer shimmer
        _buildShimmerBox(200, 56),
        const SizedBox(height: 12),
        _buildShimmerBox(100, 12),
        const Spacer(),
        // Footer shimmer
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildShimmerBox(double.infinity, 60, radius: 24),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildShimmerBox(double.infinity, 60, radius: 24),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildHomeIndicator(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildShimmerCircle(double size) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.08),
      highlightColor: Colors.white.withValues(alpha: 0.15),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildShimmerBox(double width, double height, {double radius = 8}) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.08),
      highlightColor: Colors.white.withValues(alpha: 0.15),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: _handleBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white.withValues(alpha: 0.6),
                size: 24,
              ),
            ),
          ),
          // Center title
          Expanded(
            child: Column(
              children: [
                Text(
                  'LIVE RECORDING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Placeholder for balance
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  bool _isRecordingOrPaused() {
    return _state == RecordingScreenState.recording ||
        _state == RecordingScreenState.paused;
  }

  Future<void> _handleBack() async {
    if (_isRecordingOrPaused()) {
      // Save recording then go back
      await _stopRecording();
    } else {
      // Not recording yet, just go back
      Navigator.pop(context);
    }
  }

  Widget _buildMainContent() {
    final isRecording = _state == RecordingScreenState.recording;

    return Column(
      children: [
        const SizedBox(height: 32),
        // Waveform visualization - positioned in upper 2/3
        SizedBox(
          height: 180,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(18, (index) {
              final baseHeight = _waveHeights[index];
              final height = isRecording ? baseHeight * 180 : 40.0;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 60),
                curve: Curves.easeOut,

                width: 4,
                height: height.clamp(20.0, 180.0),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
        // Timer display
        Text(
          formatDuration(_duration),
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -1,
            fontFeatures: const [FontFeature.tabularFigures()],
            shadows: [
              Shadow(
                color: AppColors.primary.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Elapsed Time',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 2,
          ),
        ),
        // Spacer to push content to upper 2/3
        const Spacer(),
      ],
    );
  }

  Widget _buildFooter() {
    final isPaused = _state == RecordingScreenState.paused;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
      child: Column(
        children: [
          // Control buttons
          Row(
            children: [
              // Pause button
              Expanded(
                child: GestureDetector(
                  onTap: _togglePause,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isPaused ? Icons.play_arrow : Icons.pause,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isPaused ? 'Resume' : 'Pause',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Stop button
              Expanded(
                child: GestureDetector(
                  onTap: _stopRecording,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stop, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Stop',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeIndicator() {
    return Center(
      child: Container(
        width: 128,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
