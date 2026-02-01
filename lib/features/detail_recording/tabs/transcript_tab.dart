import 'package:flutter/material.dart';

import '../../../services/ads/ads.dart';
import '../../../services/database.dart';
import '../../../services/process.dart';
import '../../../theme/colors.dart';
import '../../../services/repository.dart';
import '../../../models/transcript.dart';
import '../../../utils/console.dart';
import '../widgets/transcript_message_bubble.dart';

enum TranscriptState {
  loading,
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
  TranscriptState _state = TranscriptState.loading;
  String _errorMessage = '';
  bool _isPolling = false; // Track polling state
  late DatabaseService _db;

  @override
  void initState() {
    super.initState();
    _db = DatabaseService();

    _checkStatus();
  }

  @override
  void dispose() {
    _isPolling = false; // Stop polling when widget is disposed
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (widget.id == null) return;

    try {
      final detail = await Repository.getMeetingbyId(widget.id!);
      if (!mounted) return;

      switch (detail.meeting.transcriptStatus) {
        case 'DONE' when detail.transcripts.isNotEmpty:
          setState(() {
            _transcriptItems = detail.transcripts;
            _state = TranscriptState.done;
          });
          return;
        case 'PROCESSING':
          setState(() {
            _state = TranscriptState.processing;
            _isPolling = true;
          });
          // continue polling
          _startPolling();
          return;
        case 'FAILED':
          setState(() {
            _state = TranscriptState.failed;
            _errorMessage = 'Transcription previously failed.';
          });
          return;
        case 'NONE':
          setState(() {
            _state = TranscriptState.none;
          });
          return;
      }
      //
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error checking transcript status: $e');
      setState(() {
        _state = TranscriptState.failed;
        _errorMessage = 'Error checking status: ${e.toString()}';
      });
    }
  }

  Future<void> showAds() async {
    final result = await RewardedManager.showAndWait(
      rewardData: {'action': "start_chat"},
    );

    if (result?.status != RewardResultStatus.success) {
      Console.log("FAILL to watch reward");
      return;
    }
  }

  Future<void> _getTranscript() async {
    if (widget.id == null) return;
    // showAds();

    Console.log("START processing");
    await _db.updateRecordingStatus(
      meetingId: widget.id!,
      status: 'processing',
    );

    setState(() {
      _state = TranscriptState.processing;
      _isPolling = true;
    });

    try {
      final detail = await Repository.getMeetingbyId(widget.id!);
      if (detail.meeting.transcriptStatus == 'NONE') {
        // get from data local

        Console.log("SAVE TO LOCAL");
        final savedRecording = await _db.getRecording(widget.id!);
        // debug
        if (savedRecording == null) {
          throw Exception('Recording not found in database');
        }

        final presigned = await Repository.getPresignedUrl(
          widget.id!,
          savedRecording!.title,
          savedRecording.duration,
        );

        await Repository.uploadAudioToServer(
          presigned.url,
          savedRecording.filePath,
        );

        final responseConfirm = await Repository.confirm(presigned.audioId);
        Console.log("ID from confirm ${responseConfirm.id}");
      }

      _startPolling();
      //
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = TranscriptState.failed;
        _errorMessage = 'Unable to create transcript.\n${e.toString()}';
        _isPolling = false;
      });

      await _db.updateRecordingStatus(meetingId: widget.id!, status: 'failed');
    }
  }

  Future<void> _startPolling() async {
    if (!_isPolling) return;

    const checkInterval = Duration(seconds: 5);

    while (_isPolling) {
      await Future.delayed(checkInterval);

      if (!_isPolling || !mounted) break;

      try {
        final statusResponse = await Repository.transcriptStatus(widget.id!);
        debugPrint('Transcription status: $statusResponse');

        if (statusResponse == 'DONE') {
          final detail = await Repository.getMeetingbyId(widget.id!);
          // set status
          await _db.updateRecordingStatus(
            meetingId: widget.id!,
            status: 'done',
          );

          // set activated
          await _db.updateTranscriptActivation(
            meetingId: widget.id!,
            isActivated: true,
          );

          setState(() {
            _transcriptItems = detail.transcripts;
            _state = TranscriptState.done;

            _isPolling = false;
          });
          break;
        } else if (statusResponse == 'FAILED') {
          await _db.updateRecordingStatus(
            meetingId: widget.id!,
            status: 'failed',
          );

          setState(() {
            _state = TranscriptState.failed;
            _errorMessage = 'Transcription failed. Please try again.';

            _isPolling = false;
          });

          // ✅ ADD THIS: Stop background service too
          ProcessingService().stopPolling("transcript_${widget.id!}");
          break;
        }
      } catch (e) {
        debugPrint('Error polling transcript: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case TranscriptState.loading:
        return _buildLoadingState();

      case TranscriptState.none:
        return _buildNoneState();
      case TranscriptState.processing:
        return _buildProcessingState();
      case TranscriptState.done:
        return _buildTranscriptList();
      case TranscriptState.failed:
        return _buildErrorState();
    }
  }

  Widget _buildLoadingState() {
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
                backgroundColor: AppColors.cardDark,
                color: AppColors.primary,
                strokeWidth: 6,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Empty state - show button to start transcription
  Widget _buildNoneState() {
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
            'No transcript yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'This conversation has not been processed. Tap the button below to create a transcript.',
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
                onPressed: _getTranscript,
                icon: const Icon(Icons.transcribe, size: 20),
                label: const Text('Transcribe conversation'),
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
              'Transcribing...',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'This may take a few minutes.\nPlease wait...',
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
            'No transcript content found',
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
              'An error occurred',
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
              onPressed: _getTranscript,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Retry'),
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
