import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../components/bouncing_button.dart';
import '../../../theme/colors.dart';
import 'create_record_viewmodel.dart';

class CreateRecordModal extends StatelessWidget {
  const CreateRecordModal({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateRecordViewModel(),
      child: _CreateRecordSheetContent(),
    );
  }
}

class _CreateRecordSheetContent extends StatelessWidget {
  const _CreateRecordSheetContent();

  void _handleClose(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Consumer<CreateRecordViewModel>(
        builder: (context, viewModel, _) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with title and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New Recording',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Close',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _handleClose(context),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.close,
                                color: AppColors.textMuted,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Title label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'TITLE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title input field
                  TextField(
                    controller: viewModel.titleController,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter meeting title...',
                      hintStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Start button
                  _StartRecordButton(viewModel: viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Primary recording button - large blue button with arrow
class _StartRecordButton extends StatelessWidget {
  final CreateRecordViewModel viewModel;

  const _StartRecordButton({required this.viewModel});

  Future<void> _onStartRecording(BuildContext context) async {
    final meeting = await viewModel.createMeeting();

    if (meeting != null && context.mounted) {
      Navigator.pop(context, meeting);
    } else if (context.mounted) {
      // Show validation error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      semanticLabel: viewModel.isSubmitting
          ? 'Creating meeting...'
          : 'Start recording now, tap to begin',
      // Don't pass null, handle it differently
      onPressed: viewModel.isSubmitting
          ? () {
              // Do nothing when submitting
            }
          : () => _onStartRecording(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: viewModel.isSubmitting
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (viewModel.isSubmitting)
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                ),
              )
            else
              const Icon(Icons.mic, color: Colors.white, size: 28),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.isSubmitting
                        ? 'Creating meeting...'
                        : 'Start recording now',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    viewModel.isSubmitting ? 'Please wait' : 'Tap to begin',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
