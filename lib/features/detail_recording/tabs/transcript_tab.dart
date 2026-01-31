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
  bool _isTranscriptActivated = false;
  late DatabaseService _db;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _db = DatabaseService();

    if (ProcessingService().isProcessing("transcript_${widget.id!}")) {
      setState(() {
        _state = TranscriptState.processing;
        _isPolling = true;
        _isProcessing = true;
      });
      _pollTranscript();
    } else {
      _checkTranscriptStatus();
    }
  }

  @override
  void dispose() {
    _isPolling = false; // Stop polling when widget is disposed
    super.dispose();
  }

  Future<void> _checkTranscriptStatus() async {
    if (widget.id == null) return;

    try {
      final recording = await _db.getRecording(widget.id!);

      if (recording != null) {
        _isTranscriptActivated = recording.isTranscriptActivated;

        // If transcript is already activated AND DONE, check server status
        if (_isTranscriptActivated) {
          final detail = await Repository.getMeetingbyId(widget.id!);
          if (!mounted) return;

          final transcriptStatus = detail.meeting.transcriptStatus;

          if (transcriptStatus == 'DONE' && detail.transcripts.isNotEmpty) {
            setState(() {
              _transcriptItems = detail.transcripts;
              _state = TranscriptState.done;
            });
            return;
          } else if (transcriptStatus == 'PROCESSING') {
            setState(() {
              _state = TranscriptState.processing;
              _isPolling = true;
            });
            _pollTranscript();
            return;
          } else if (transcriptStatus == 'FAILED') {
            setState(() {
              _state = TranscriptState.failed;
              _errorMessage =
                  'Transcription previously failed. Please try again.';
            });
            return;
          }
        }

        // If not activated OR activated but no transcript yet
        setState(() {
          _state = TranscriptState.none;
        });
      } else {
        // No recording found
        setState(() {
          _state = TranscriptState.none;
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error checking transcript status: $e');
      setState(() {
        _state = TranscriptState.failed;
        _errorMessage = 'Error checking status: ${e.toString()}';
      });
    }
  }

  Future<void> _getTranscription() async {
    if (widget.id == null) return;

    // ads
    // final result = await RewardedManager.showAndWait(
    //   rewardData: {'action': "start_chat"},
    // );

    // if (result?.status != RewardResultStatus.success) {
    //   Console.log("FAILL to watch reward");
    //   return;
    // }

    Console.log("START processing");
    await _db.updateRecordingStatus(
      meetingId: widget.id!,
      status: 'processing',
    );

    setState(() {
      _state = TranscriptState.processing;
      _isPolling = true;
      _isProcessing = true;
    });

    try {
      final detail = await Repository.getMeetingbyId(widget.id!);
      if (detail.meeting.transcriptStatus == 'NONE') {
        // get from data local

        final savedRecording = await _db.getRecording(widget.id!);
        // debug
        if (savedRecording != null) {
          debugPrint('''
        ✅ VERIFIED IN DATABASE:
        ├─ ID: ${savedRecording.id}
        ├─ Meeting ID: ${savedRecording.meetingId}
        ├─ File: ${savedRecording.title}
        ├─ Path: ${savedRecording.filePath}
        ├─ Duration: ${savedRecording.duration}s
        ├─ Status: ${savedRecording.status}
        └─ Recorded at: ${savedRecording.recordedAt}
        ''');
        } else {
          debugPrint('❌ ERROR: Recording not found in database after saving!');
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

        // now start processing
        await DatabaseService().updateRecordingStatus(
          meetingId: widget.id!,
          status: 'processing',
        );

        final responseConfirm = await Repository.confirm(presigned.audioId);
        Console.log("ID from confirm ${responseConfirm.id}");

        // load outside
        Console.log("NOW START TRANSCRIPT ${widget.id}");
        // await Repository.processTranscript(detail.meeting.id);
      }

      ProcessingService().startPolling(
        meetingId: "transcript_${widget.id!}",
        checkFunction: () async {
          final status = await Repository.transcriptStatus(widget.id!);
          return status == 'DONE';
        },
        onSuccess: () async {
          // This runs even when you're not on the tab
          final detail = await Repository.getMeetingbyId(widget.id!);
          await _db.updateRecordingStatus(
            meetingId: widget.id!,
            status: 'done',
          );
          await _db.updateTranscriptActivation(
            meetingId: widget.id!,
            isActivated: true,
          );

          // If user comes back to tab, UI will be updated
          if (mounted) {
            setState(() {
              _isTranscriptActivated = true;
              _transcriptItems = detail.transcripts;
              _state = TranscriptState.done;
              _isPolling = false;
            });
          }
        },
        onError: () {
          // Handle background error
          if (mounted) {
            setState(() {
              _state = TranscriptState.failed;
              _errorMessage = 'Transcription failed in background';
              _isPolling = false;
              _isProcessing = false;
            });
          }
        },
      );

      // get

      _pollTranscript();
    } catch (e) {
      setState(() {
        _state = TranscriptState.failed;
        _errorMessage = 'Unable to create transcript.\n${e.toString()}';
        _isPolling = false;
        _isProcessing = false;
      });
      debugPrint('Error in transcription: $e');
    }
  }

  Future<void> _pollTranscript() async {
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
          if (mounted) {
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
              _isTranscriptActivated = true;
              _transcriptItems = detail.transcripts;
              _state = TranscriptState.done;
              _isProcessing = false;

              _isPolling = false;
            });

            // ✅ ADD THIS: Stop background service too
            ProcessingService().stopPolling("transcript_${widget.id!}");
          }
          break;
        } else if (statusResponse == 'FAILED') {
          if (mounted) {
            await DatabaseService().updateRecordingStatus(
              meetingId: widget.id!,
              status: 'failed',
            );

            setState(() {
              _state = TranscriptState.failed;
              _errorMessage = 'Transcription failed. Please try again.';
              _isProcessing = false;

              _isPolling = false;
            });

            // ✅ ADD THIS: Stop background service too
            ProcessingService().stopPolling("transcript_${widget.id!}");
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
                'Checking...',
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
                onPressed: _getTranscription,
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
              onPressed: _getTranscription,
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
