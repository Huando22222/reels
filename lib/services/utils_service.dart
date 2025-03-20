import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

class UtilsService {
  static String formatTime(DateTime sentTime) {
    final now = DateTime.now();
    final difference = now.difference(sentTime);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} h ago";
    } else {
      return "${difference.inDays} d ago";
    }
  }

  static void showSnackBar({
    required BuildContext context,
    required String content,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    IconData? icon,
    SnackBarAction? action,
    bool isError = false,
  }) {
    final effectiveBackgroundColor =
        backgroundColor ?? (isError ? Colors.redAccent : Colors.grey.shade800);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        duration: duration,
        backgroundColor: effectiveBackgroundColor,
        action: action,
        behavior: SnackBarBehavior.floating,
        // showCloseIcon: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  static void saveImage({
    required BuildContext context,
    required File file,
  }) async {
    try {
      await Gal.putImage(file.path).then(
        (value) {
          showSnackBar(context: context, content: "saved image");
        },
      );
    } on GalException catch (e) {
      log(e.toString());
      showSnackBar(
        context: context,
        content: "error when trying save image",
        isError: true,
      );
    }
  }

  static void saveImageFromUrl({
    required BuildContext context,
    required String url,
  }) async {
    try {
      final imagePath = '${Directory.systemTemp.path}/image.jpg';
      await Dio().download(url, imagePath);
      await Gal.putImage(imagePath).then(
        (value) {
          showSnackBar(context: context, content: "saved image");
        },
      );
    } on GalException catch (e) {
      log(e.toString());
      showSnackBar(
        context: context,
        content: "error when trying save image",
        isError: true,
      );
    }
  }
}
