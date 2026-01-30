import 'package:aimateflutter/models/meeting.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../services/repository.dart';
import '../../utils/console.dart';
import 'recording_control_viewmodel.dart';
import '../../../theme/colors.dart';
import '../../../utils/format.dart';

class RecordControlScreen extends StatefulWidget {
  final MeetingResponse meeting;

  const RecordControlScreen({super.key, required this.meeting});

  @override
  State<RecordControlScreen> createState() => _RecordControlScreenState();
}

class _RecordControlScreenState extends State<RecordControlScreen>
    with TickerProviderStateMixin {
  late RecordingViewModel _viewModel;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _viewModel = RecordingViewModel();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initializeRecording();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onExit(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1222),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return _viewModel.isLoading
                  ? _buildLoadingState()
                  : Column(
                      children: [
                        _buildHeader(context),
                        Expanded(child: _buildMainContent()),
                        _buildFooter(),
                        const SizedBox(height: 8),
                        _buildHomeIndicator(),
                        const SizedBox(height: 8),
                      ],
                    );
            },
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
                baseColor: Colors.white.withOpacity(0.08),
                highlightColor: Colors.white.withOpacity(0.15),
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
      baseColor: Colors.white.withOpacity(0.08),
      highlightColor: Colors.white.withOpacity(0.15),
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
      baseColor: Colors.white.withOpacity(0.08),
      highlightColor: Colors.white.withOpacity(0.15),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => _onExit(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white.withOpacity(0.6),
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
                  widget.meeting.title,
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

  Widget _buildMainContent() {
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
              final baseHeight = _viewModel.waveHeights[index];
              final height = _viewModel.isRecording ? baseHeight * 180 : 40.0;

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
                      AppColors.primary.withOpacity(0.7),
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
          formatDuration(_viewModel.duration),
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -1,
            fontFeatures: const [FontFeature.tabularFigures()],
            shadows: [
              Shadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 20),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Elapsed Time',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.4),
            letterSpacing: 2,
          ),
        ),
        // Spacer to push content to upper 2/3
        const Spacer(),
      ],
    );
  }

  Widget _buildFooter() {
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
                  onTap: () => _viewModel.togglePause(),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _viewModel.isPaused ? Icons.play_arrow : Icons.pause,
                          color: Colors.white.withOpacity(0.8),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _viewModel.isPaused ? 'Resume' : 'Pause',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.8),
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
                  onTap: () => _onStopRecording(context),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withOpacity(0.3),
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
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Future<void> _onExit(BuildContext context) async {
    // TODO: save id
    // Show if they want to exit or not while recording
    if (_viewModel.isRecordingOrPaused) {
      // Save recording then go back
      // MSG: do u wanna save
      await _onStopRecording(context);
    } else {
      // is recording
      // POP a meetingId
      Navigator.pop(context);
    }
  }

  Future<void> _onStopRecording(BuildContext context) async {
    final meetingId = widget.meeting.id;
    try {
      await _viewModel.stopRecording(
        title: widget.meeting.title,
        meetingId: meetingId,
      );

      if (mounted) {
        // return the meetingId
        Navigator.pop(context, meetingId);
      }
      //
    } catch (e) {
      final result = await Repository.deleteMeeting(meetingId);

      if (result == true) {
        Console.log("Successful delete meeting while ERROR");
      }

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
}
