// transcript_tab.dart
import 'package:aimateflutter/services/ads/rewarder_sdk.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/colors.dart';
import '../widgets/transcript_message_bubble.dart';
import 'transcript_viewmodel.dart';

class TranscriptTab extends StatefulWidget {
  const TranscriptTab({super.key, this.id});

  final String? id;

  @override
  State<TranscriptTab> createState() => _TranscriptTabState();
}

class _TranscriptTabState extends State<TranscriptTab> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TranscriptViewModel(id: widget.id),
      child: Consumer<TranscriptViewModel>(
        builder: (context, viewModel, child) {
          switch (viewModel.state) {
            case TranscriptState.loading:
              return _buildLoadingState();
            case TranscriptState.none:
              return _buildNoneState(context, viewModel);
            case TranscriptState.processing:
              return _buildProcessingState(); // while processing
            case TranscriptState.done:
              return _buildTranscriptList(viewModel);
            case TranscriptState.failed:
              return _buildErrorState(context, viewModel);
          }
        },
      ),
    );
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
          ],
        ),
      ),
    );
  }

  Widget _buildNoneState(BuildContext context, TranscriptViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.center,
            children: [
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
          Text(
            'No transcript yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: () async {
                  RewarderManager.startShowAutoLoadRewardedVideoAd();
                  await Future.delayed(const Duration(seconds: 1));

                  await viewModel.processTranscript();
                },
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

  Widget _buildProcessingState() {
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

  Widget _buildTranscriptList(TranscriptViewModel viewModel) {
    if (viewModel.transcriptItems.isEmpty) {
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
      padding: const EdgeInsets.only(top: 0, bottom: 24),
      itemCount: viewModel.transcriptItems.length,
      itemBuilder: (context, index) {
        final item = viewModel.transcriptItems[index];
        final showAvatar =
            index == 0 ||
            viewModel.transcriptItems[index - 1].speaker != item.speaker;

        return TranscriptMessageBubble(item: item, showAvatar: showAvatar);
      },
    );
  }

  Widget _buildErrorState(BuildContext context, TranscriptViewModel viewModel) {
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
              viewModel.errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: viewModel.processTranscript,
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
