import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../services/repository.dart';
import '../../../models/transcript.dart';
import '../widgets/transcript_message_bubble.dart';

enum TranscriptState {
  none, // No transcript, show button
  processing, // Transcription in progress
  done, // Transcript loaded successfully
  failed, // Error occurred
}

class TranscriptTab extends StatefulWidget {
  const TranscriptTab({super.key, this.id});

  final String? id;

  @override
  State<TranscriptTab> createState() => _TranscriptTabState();
}

class _TranscriptTabState extends State<TranscriptTab> {
  List<TranscriptItem> _transcriptItems = [];
  TranscriptState? _state;
  String _errorMessage = '';
  bool _isPolling = false; // Track polling state

  @override
  void initState() {
    super.initState();
    _checkCurrentStatus();
  }

  @override
  void dispose() {
    _isPolling = false; // Stop polling when widget is disposed
    super.dispose();
  }

  Future<void> _checkCurrentStatus() async {
    if (widget.id == null) return;

    try {
      final detail = await Repository.getMeetingDetail(widget.id!);
      final transcriptStatus = detail.meeting.transcriptStatus;

      if (transcriptStatus == 'DONE' && detail.transcripts.isNotEmpty) {
        // Transcript already exists, load it
        setState(() {
          _transcriptItems = detail.transcripts;
          _state = TranscriptState.done;
        });
      } else if (transcriptStatus == 'PROCESSING') {
        // Transcription is in progress, start polling
        setState(() {
          _state = TranscriptState.processing;
          _isPolling = true;
        });
        _pollTranscript();
      } else if (transcriptStatus == 'FAILED') {
        setState(() {
          _state = TranscriptState.failed;
          _errorMessage = 'Transcription previously failed. Please try again.';
        });
      } else {
        setState(() {
          _state = TranscriptState.none;
        });
      }
    } catch (e) {
      debugPrint('Error checking transcript status: $e');
      setState(() {
        _state = TranscriptState.failed;
        _errorMessage = 'Error checking status: ${e.toString()}';
      });
    }
  }

  Future<void> _getTranscription() async {
    if (widget.id == null) return;

    setState(() {
      _state = TranscriptState.processing;
      _isPolling = true;
    });

    try {
      // Start transcription
      await Repository.processTranscript(widget.id!);

      // Don't await - let it run in background
      _pollTranscript();
    } catch (e) {
      setState(() {
        _state = TranscriptState.failed;
        _errorMessage = 'Không thể tạo bản phiên âm.\n${e.toString()}';
        _isPolling = false;
      });
      debugPrint('Error in transcription: $e');
    }
  }

  Future<void> _pollTranscript() async {
    if (!_isPolling) return;

    const checkInterval = Duration(seconds: 5);

    while (_isPolling) {
      await Future.delayed(checkInterval);

      if (!_isPolling) break;

      try {
        final statusResponse = await Repository.status(widget.id!);
        debugPrint('Transcription status: $statusResponse');

        if (statusResponse == 'DONE') {
          final detail = await Repository.getMeetingDetail(widget.id!);
          if (mounted) {
            setState(() {
              _transcriptItems = detail.transcripts;
              _state = TranscriptState.done;
              _isPolling = false;
            });
          }
          break;
        } else if (statusResponse == 'FAILED') {
          if (mounted) {
            setState(() {
              _state = TranscriptState.failed;
              _errorMessage = 'Transcription failed. Please try again.';
              _isPolling = false;
            });
          }
          break;
        }
      } catch (e) {
        debugPrint('Error polling transcript: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking initial status
    if (_state == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Đang kiểm tra...',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    switch (_state!) {
      case TranscriptState.none:
        return _buildEmptyState();
      case TranscriptState.processing:
        return _buildProcessingState();
      case TranscriptState.done:
        return _buildTranscriptList();
      case TranscriptState.failed:
        return _buildErrorState();
    }
  }

  // Empty state - show button to start transcription
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Icon container with glow effect
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              // Icon box
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.cardDark,
                      AppColors.cardDark.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.graphic_eq,
                  size: 40,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            'Chưa có bản phiên âm',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Đoạn hội thoại này chưa được xử lý. Nhấn nút bên dưới để tạo bản phiên âm văn bản.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // CTA Button
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: _getTranscription,
                icon: const Icon(Icons.transcribe, size: 20),
                label: const Text('Phiên âm đoạn hội thoại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Processing state - show loading with progress
  Widget _buildProcessingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular progress indicator
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                backgroundColor: AppColors.cardDark,
                color: AppColors.primary,
                strokeWidth: 6,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Đang phiên âm...',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Quá trình này có thể mất vài phút.\nVui lòng chờ...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Loaded state - show transcript messages
  Widget _buildTranscriptList() {
    if (_transcriptItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Không tìm thấy nội dung phiên âm',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      itemCount: _transcriptItems.length,
      itemBuilder: (context, index) {
        final item = _transcriptItems[index];
        // Check if previous message is from same speaker
        final showAvatar =
            index == 0 || _transcriptItems[index - 1].speaker != item.speaker;

        return TranscriptMessageBubble(item: item, showAvatar: showAvatar);
      },
    );
  }

  // Error state - show error message with retry button
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 24),
            Text(
              'Có lỗi xảy ra',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _getTranscription,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
