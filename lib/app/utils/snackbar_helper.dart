import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarHelper {
  static void _show(
    String title,
    String message,
    Color color,
  ) {
    final context = Get.context;

    if (context == null) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  static void info(String title, String message) {
    _show(title, message, Colors.blue.shade700);
  }

  static void error(String title, String message) {
    _show(title, message, Colors.red.shade700);
  }

  static void success(String title, String message) {
    _show(title, message, Colors.green.shade700);
  }
}