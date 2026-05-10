import 'package:flutter/material.dart';
import 'package:pomocnik_wokalisty/l10n/generated/app_localizations.dart';

enum ExitAction { saveAndExit, exitWithoutSaving, cancel }

class UIHelper {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmLabel,
    String? cancelLabel,
  }) {
    final localizations = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelLabel ?? localizations.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmLabel ?? localizations.ok),
              ),
            ],
          ),
    );
  }

  static Future<ExitAction> showExitConfirmationDialog(
    BuildContext context,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    final result = await showDialog<ExitAction>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.unsavedChanges),
            content: Text(localizations.areYouSureYouWantToExitWithoutSaving),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(ExitAction.cancel),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed:
                    () =>
                        Navigator.of(context).pop(ExitAction.exitWithoutSaving),
                child: Text(localizations.exit),
              ),
              TextButton(
                onPressed:
                    () => Navigator.of(context).pop(ExitAction.saveAndExit),
                child: Text(localizations.saveAndExit),
              ),
            ],
          ),
    );
    return result ?? ExitAction.cancel;
  }

  static Future<bool?> showSaveBeforeActionDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return showConfirmDialog(
      context: context,
      title: localizations.unsavedChanges,
      content: localizations.unsavedChangesInPlaylist,
      confirmLabel: localizations.saveAndContinue,
      cancelLabel: localizations.cancel,
    );
  }
}
