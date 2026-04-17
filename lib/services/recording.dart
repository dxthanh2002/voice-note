// services/recording_service.dart
import 'package:aimateflutter/components/dialogs/rename_dialog.dart';
import 'package:aimateflutter/services/database.dart';
import 'package:aimateflutter/services/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/dialogs/delete_dialog.dart';
import '../utils/console.dart';

class RecordingService {
  static Future<void> deleteRecording(
    BuildContext context,
    String meetingId,
  ) async {
    final confirmed = await showDeleteDialog(
      context,
      title: 'Delete Recording?',
    );

    if (confirmed == true) {
      HapticFeedback.heavyImpact();
      try {
        // Server delete
        await Repository.deleteMeeting(meetingId);

        Console.log("DELETE LOCAL");
        // Local delete
        await DatabaseService().deleteRecording(meetingId);
      } catch (e) {
        Console.error("ERROR WHEN DELETE");
      }
    }
  }

  static Future<void> renameRecording(
    BuildContext context,
    String meetingId,
    String meetingTitle,
  ) async {
    final newName = await showRenameDialog(context, initialTitle: meetingTitle);

    if (newName != null && newName.isNotEmpty && newName != meetingTitle) {
      try {
        // Server rename
        await Repository.rename(meetingId: meetingId, name: newName);

        // Local rename

        Console.log("DELETE LOCAL");

        await DatabaseService().updateRecordingTitle(
          meetingId: meetingId,
          newTitle: newName,
        );
      } catch (e) {
        Console.log("ERROR when rename");
      }
    }
  }
}
