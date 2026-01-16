import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../services/repository.dart';
import '../../../models/transcript.dart';
import '../widgets/transcript_message_bubble.dart';

enum TranscriptState {
  empty, // No transcript, show button
  processing, // Transcription in progress
  done, // Transcript loaded successfully
  error, // Error occurred
}

class TranscriptTab extends StatefulWidget {
  const TranscriptTab({super.key, this.id});

  final String? id;

  @override
  State<TranscriptTab> createState() => _TranscriptTabState();
}

class _TranscriptTabState extends State<TranscriptTab> {
  TranscriptState _state = TranscriptState.empty;
  List<TranscriptItem> _transcriptItems = [];
  double _processingProgress = 0.0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _checkCurrentStatus();
  }

  Future<void> _checkCurrentStatus() async {
    if (widget.id == null) return;

    print("status");
    try {
      final detail = await Repository.getMeetingDetail(widget.id!);

      if (detail.meeting.transcriptStatus == 'DONE' &&
          detail.transcripts.isNotEmpty) {
        // Transcript already exists, load it
        setState(() {
          _transcriptItems = detail.transcripts;
          _state = TranscriptState.done;
        });
      } else if (detail.meeting.transcriptStatus == 'PROCESSING') {
        // Transcription is in progress, start polling
        setState(() {
          _state = TranscriptState.processing;
        });
        _pollTranscript();
      }
      // If status is empty or something else, stay in empty state
    } catch (e) {
      debugPrint('Error checking transcript status: $e');
      // Stay in empty state, user can retry
    }
  }

  Future<void> _getTranscription() async {
    if (widget.id == null) return;

    setState(() {
      _state = TranscriptState.processing;
      _processingProgress = 0.0;
    });

    try {
      // Step 1: Start transcription
      await Repository.processTranscript(widget.id!);

      // Step 2: Poll for completion
      await _pollTranscript();
    } catch (e) {
      setState(() {
        _state = TranscriptState.error;
        _errorMessage = 'Không thể tạo bản phiên âm.\n${e.toString()}';
      });
      debugPrint('Error in transcription: $e');
    }
  }

  Future<void> _pollTranscript() async {
    const maxChecks = 30; // 30 checks * 5s = 2.5 minutes max
    const checkInterval = Duration(seconds: 5);

    for (int i = 0; i < maxChecks; i++) {
      await Future.delayed(checkInterval);

      // Update progress
      setState(() {
        _processingProgress = (i + 1) / maxChecks;
      });

      final statusResponse = await Repository.status(widget.id!);

      debugPrint('Transcription status: $statusResponse (${(i + 1) * 5}s)');

      if (statusResponse == 'DONE') {
        final detail = await Repository.getMeetingDetail(widget.id!);
        setState(() {
          _transcriptItems = detail.transcripts;
          _state = TranscriptState.done;
        });
        return;
      }
    }

    // Timeout
    throw Exception('Transcription timeout after 2.5 minutes');
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case TranscriptState.empty:
        return _buildEmptyState();
      case TranscriptState.processing:
        return _buildProcessingState();
      case TranscriptState.done:
        return _buildTranscriptList();
      case TranscriptState.error:
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
                value: _processingProgress,
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
            const SizedBox(height: 8),
            Text(
              '${(_processingProgress * 100).toInt()}%',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
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
