// summary_tab.dart
import 'package:aimateflutter/services/ads/rewarder_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../theme/colors.dart';
import 'summary_viewmodel.dart';

class SummaryTab extends StatefulWidget {
  const SummaryTab({super.key, this.id});

  final String? id;

  @override
  State<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SummaryViewModel(id: widget.id),
      child: Consumer<SummaryViewModel>(
        builder: (context, viewModel, child) {
          switch (viewModel.state) {
            case SummaryState.loading:
              return _buildLoadingState();
            case SummaryState.none:
              return _buildNoneState(context, viewModel);
            case SummaryState.processing:
              return _buildProcessingState();
            case SummaryState.done:
              return _buildSummaryList(context, viewModel);
            case SummaryState.error:
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
                strokeWidth: 6,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoneState(BuildContext context, SummaryViewModel viewModel) {
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
                child: Icon(
                  Icons.auto_awesome,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Summary not generated yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Summary generation is not activated for this recording.',
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
                onPressed: () {
                  RewarderManager.startShowAutoLoadRewardedVideoAd();

                  viewModel.getSummary();
                },
                icon: Icon(Icons.auto_awesome, size: 20),
                label: Text('Generate Summary'),
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
              'AI is generating summary...',
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

  Widget _buildSummaryList(BuildContext context, SummaryViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Summary generated by AI',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSummaryContent(viewModel),
          const SizedBox(height: 20),
          _buildSummaryActions(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildSummaryContent(SummaryViewModel viewModel) {
    if (viewModel.summaryContent == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No summary content found',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }

    final lines = viewModel.summaryContent!.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: Text(
              line.substring(3),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          );
        } else if (line.startsWith('### ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line.substring(4),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          );
        } else if (line.startsWith('**') && line.endsWith('**')) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              line.replaceAll('**', ''),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        } else if (line.startsWith('- [')) {
          final isChecked = line.contains('[x]') || line.contains('[X]');
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    color: isChecked
                        ? AppColors.success.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isChecked
                          ? AppColors.success
                          : AppColors.textMuted.withValues(alpha: 0.5),
                    ),
                  ),
                  child: isChecked
                      ? Icon(Icons.check, size: 14, color: AppColors.success)
                      : null,
                ),
                Expanded(
                  child: Text(
                    line.substring(line.indexOf(']') + 1).trim(),
                    style: TextStyle(
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (line.startsWith('- ')) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8, right: 12),
                  child: Icon(
                    Icons.circle,
                    size: 6,
                    color: AppColors.textSecondary,
                  ),
                ),
                Expanded(child: Text(line.substring(2))),
              ],
            ),
          );
        } else if (line.trim().isEmpty) {
          return const SizedBox(height: 8);
        } else if (line.startsWith('---')) {
          return const Divider(height: 40);
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(line),
          );
        }
      }).toList(),
    );
  }

  Widget _buildSummaryActions(
    BuildContext context,
    SummaryViewModel viewModel,
  ) {
    return OutlinedButton.icon(
      onPressed: () {
        if (viewModel.summaryContent != null) {
          Clipboard.setData(ClipboardData(text: viewModel.summaryContent!));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Summary copied to clipboard'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      icon: const Icon(Icons.copy, size: 18),
      label: const Text('Copy'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, SummaryViewModel viewModel) {
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
              viewModel.errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.getSummary(),
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
