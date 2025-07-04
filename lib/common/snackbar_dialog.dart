import 'package:flutter/material.dart';
import 'package:yv_counter/l10n/app_localizations.dart';

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 2000),
    ),
  );
}

Future<void> showAlertDialog(BuildContext context, String massage) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Alert'),
        content: SingleChildScrollView(
          child: ListBody(children: <Widget>[Text(massage)]),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> showDeleteConfirmationDialog(
  BuildContext context,
  String massage,
  void Function() confirmPressed,
) async {
  final localizations = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(localizations.alert),
        content: Text(massage),
        actions: <Widget>[
          TextButton(
            onPressed: confirmPressed,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(localizations.delete),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(localizations.cancel),
          ),
        ],
      );
    },
  );
}

void showProgressIndicator(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [const CircularProgressIndicator(), Text(message)],
          ),
        ),
      );
    },
  );
}

void hideProgressIndicator(BuildContext context) {
  Navigator.pop(context);
}
