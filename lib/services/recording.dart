// services/recording_service.dart
import 'package:aimateflutter/components/dialogs/rename_dialog.dart';
import 'package:aimateflutter/services/database.dart';
import 'package:aimateflutter/services/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../components/dialogs/delete_dialog.dart';
import '../features/home/recordings_viewmodel.dart';

class RecordingService {
  static Future<void> deleteRecording(
    BuildContext context,
    String meetingId, {
    bool refresh = false,
  }) async {
    final confirmed = await showDeleteDialog(
      context,
      title: 'Delete Recording?',
    );

    if (confirmed == true) {
      HapticFeedback.heavyImpact();
      try {
        // Server delete
        await Repository.deleteMeeting(meetingId);

        // Local delete
        await DatabaseService().deleteRecording(meetingId);

        if (refresh) {
          // Notify listeners if using Provider
          final viewModel = context.read<RecordingsViewModel>();
          await viewModel.loadRecordings();
        }

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Recording deleted')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
  }

  static Future<void> renameRecording(
    BuildContext context,
    String meetingId,
    String meetingTitle, {
    bool refresh = false,
  }) async {
    final newName = await showRenameDialog(context, initialTitle: meetingTitle);

    if (newName != null && newName.isNotEmpty && newName != meetingTitle) {
      try {
        // Server rename
        await Repository.rename(meetingId: meetingId, name: newName);

        // Local rename
        await DatabaseService().updateRecordingTitle(
          meetingId: meetingId,
          newTitle: newName,
        );

        if (refresh) {
          final viewModel = context.read<RecordingsViewModel>();
          await viewModel.loadRecordings();
        }

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Renamed to "$newName"')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
  }
}
