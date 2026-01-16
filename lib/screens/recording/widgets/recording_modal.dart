import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

import 'package:aimateflutter/services/repository.dart';
import 'package:provider/provider.dart';

import '../../../services/audio.dart';
import '../../../services/meeting.dart';
import '../../../theme/colors.dart';
import '../../../utils/format.dart';

enum RecordingModalState { initial, recording, paused }

class RecordingModal extends StatefulWidget {
  const RecordingModal({super.key});

  /// Shows the recording modal and returns the file path on success, null on cancel
  static Future<String?> show(BuildContext context) {
    return showDialog<String?>(
      context: context,
      barrierDismissible: false, // We control this manually based on state
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => const RecordingModal(),
    );
  }

  @override
  State<RecordingModal> createState() => _RecordingModalState();
}

class _RecordingModalState extends State<RecordingModal>
    with SingleTickerProviderStateMixin {
  RecordingModalState _state = RecordingModalState.initial;
  AudioService? _audioService;

  Duration _duration = Duration.zero;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
        setState(() => _state = RecordingModalState.recording);
        _pulseController.repeat(reverse: true);
      } else if (state == RecordingState.paused) {
        setState(() => _state = RecordingModalState.paused);
        _pulseController.stop();
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

  Future<void> _togglePause() async {
    await _audioService?.togglePause();
  }

  Future<void> _stopRecording() async {
    if (_audioService == null) return;

    try {
      final filePath = await _audioService!.stopRecording();

      if (filePath == null) {
        debugPrint('No file path returned from recording');
        if (mounted) Navigator.pop(context, null);
        return;
      }

      // Get file size
      final fileSize = await _audioService!.getFileSize(filePath);
      final fileName = path.basename(filePath);
      debugPrint('Recording saved: $filePath');
      debugPrint('Duration: ${_audioService!.recordedDuration}');

      // Get presigned URL and upload to S3
      debugPrint('Meeting title: $fileName');
      final withoutExtension = fileName.substring(0, fileName.length - 4);
      debugPrint('New name: $withoutExtension');

      try {
        final newMeeting = await Repository.createMeeting(withoutExtension);
        // Get presigned URL for S3 upload
        final presigned = await Repository.getPresignedUrl(
          newMeeting.id,
          fileName,
          fileSize,
        );

        final code = await Repository.uploadAudio(presigned.url, filePath);
        print("CODE: $code");

        final responseConfirm = await Repository.confirm(presigned.audioId);

        final meetingService = context.read<MeetingService>();
        await meetingService.loadMeetings();

        if (mounted) Navigator.pop(context, responseConfirm.meetingId);
      } catch (e) {
        debugPrint('Error getting presigned URL: $e');
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

  void _handleOutsideTap() {
    if (_state == RecordingModalState.initial) {
      Navigator.pop(context);
    }
    // Ignore tap outside when recording or paused
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _state == RecordingModalState.initial,
      child: GestureDetector(
        onTap: _handleOutsideTap,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent tap from propagating to parent
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _state == RecordingModalState.initial
                    ? _buildInitialState()
                    : _buildRecordingState(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Microphone icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mic, size: 40, color: AppColors.primary),
        ),
        const SizedBox(height: 20),
        const Text(
          'Sẵn sàng ghi âm',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Nhấn nút bên dưới để bắt đầu',
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        // Start button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _startRecording,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Bắt đầu ghi âm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Cancel hint
        Text(
          'Chạm bên ngoài để hủy',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingState() {
    final isPaused = _state == RecordingModalState.paused;
    final isRecording = _state == RecordingModalState.recording;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRecording)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(
                        alpha: _pulseAnimation.value,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
            if (isRecording) const SizedBox(width: 8),
            Text(
              isPaused ? 'Đã tạm dừng' : 'Đang ghi âm...',
              style: TextStyle(
                color: isPaused ? AppColors.warning : AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Timer
        Text(
          formatDuration(_duration),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 16),
        // Waveform
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(15, (index) {
                final height = isRecording ? 12.0 + (index % 4) * 6.0 : 6.0;
                return AnimatedContainer(
                  duration: Duration(milliseconds: 150 + index * 15),
                  width: 3,
                  height: height,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color:
                        (isRecording ? AppColors.primary : AppColors.textMuted)
                            .withValues(alpha: isRecording ? 0.8 : 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pause/Resume button
            _ModalControlButton(
              icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              label: isPaused ? 'Tiếp tục' : 'Tạm dừng',
              backgroundColor: isPaused ? AppColors.success : AppColors.primary,
              onTap: _togglePause,
            ),
            const SizedBox(width: 24),
            // Stop button
            _ModalControlButton(
              icon: Icons.stop_rounded,
              label: 'Dừng',
              backgroundColor: AppColors.error,
              onTap: _stopRecording,
            ),
          ],
        ),
      ],
    );
  }
}

class _ModalControlButton extends StatelessWidget {
  const _ModalControlButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 32, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
