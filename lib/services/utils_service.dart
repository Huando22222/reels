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
    // final effectiveBackgroundColor =
    //     backgroundColor ?? (isError ? Colors.redAccent : Colors.grey.shade800);
    final effectiveBackgroundColor = backgroundColor ??
        (isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.surface);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isError
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                content,
                style: isError
                    ? Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onError,
                        )
                    : Theme.of(context).textTheme.bodyMedium,
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

  static Future<void> showConfirmationDialog({
    required BuildContext context,
    required String title,
    String? content,
    String confirmText = "Yes",
    String declineText = "No",
    required VoidCallback onConfirm,
    required VoidCallback onDecline,
    TextStyle? titleStyle,
    TextStyle? contentStyle,
    TextStyle? confirmStyle,
    TextStyle? declineStyle,
    Color? backgroundColor,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            title,
            style: titleStyle ?? Theme.of(context).textTheme.bodyLarge,
          ),
          content: content != null
              ? Text(
                  content,
                  style: contentStyle ?? Theme.of(context).textTheme.bodyMedium,
                )
              : null,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text(
                confirmText,
                style: confirmStyle ?? Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDecline();
              },
              child: Text(
                declineText,
                style: declineStyle ??
                    Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}
