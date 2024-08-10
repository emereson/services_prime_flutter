import 'package:flutter/material.dart';

class AppSnackbar {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        backgroundColor: const Color.fromARGB(255, 234, 234, 234),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        backgroundColor: const Color.fromARGB(255, 234, 234, 234),
      ),
    );
  }

  static void showMin(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color.fromARGB(255, 59, 59, 59),
      ),
    );
  }
}
