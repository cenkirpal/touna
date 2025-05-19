import 'package:flutter/material.dart';

showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(32, 32, 32, 8),
        content: Text(message),
      ),
    );
}
