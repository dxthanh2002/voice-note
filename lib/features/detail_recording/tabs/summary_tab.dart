// summary_tab.dart
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
  bool _isCopied = false;

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
                onPressed: () async {
                  final hasTranscript = await viewModel.hasTranscript();
                  if (!hasTranscript) {
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.cardDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('Transcript Required'),
                        content: const Text(
                          'Please generate transcript before creating a summary.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              'OK',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'SUMMARY BY AI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              _buildCopyButton(context, viewModel),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryContent(viewModel),
        ],
      ),
    );
  }

  Widget _buildCopyButton(BuildContext context, SummaryViewModel viewModel) {
    return GestureDetector(
      onTap: () {
        if (viewModel.summaryContent != null && !_isCopied) {
          Clipboard.setData(ClipboardData(text: viewModel.summaryContent!));
          setState(() => _isCopied = true);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _isCopied = false);
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _isCopied
              ? AppColors.success.withValues(alpha: 0.15)
              : AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isCopied
                ? AppColors.success.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isCopied ? Icons.done_all : Icons.copy,
              size: 14,
              color: _isCopied ? AppColors.success : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              _isCopied ? 'Copied' : 'Copy',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _isCopied ? AppColors.success : AppColors.textSecondary,
              ),
            ),
          ],
        ),
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

    // Split by bullet points
    final bulletPoints = <String>[];
    final lines = viewModel.summaryContent!.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- ')) {
        // Extract bullet point text
        bulletPoints.add(trimmed.substring(2).trim());
      }
    }

    // If no bullet points found, show as plain text
    if (bulletPoints.isEmpty) {
      return _buildSectionCard(
        icon: Icons.auto_awesome,
        iconColor: AppColors.primary,
        title: 'Summary',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            viewModel.summaryContent!,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      );
    }

    // Display bullet points
    return _buildSectionCard(
      icon: Icons.lightbulb,
      iconColor: const Color(0xFF818CF8),
      title: 'The main points',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: bulletPoints.map((point) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 12),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 10),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
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

class _SummarySection {
  final String title;
  final List<String> items;

  _SummarySection({required this.title, required this.items});
}
