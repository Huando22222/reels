import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:reels/const/app_colors.dart';

class GradientBackground extends StatefulWidget {
  const GradientBackground({super.key});

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientBackgroundPainter(context: context),
    );
  }
}

class _GradientBackgroundPainter extends CustomPainter {
  final BuildContext context;

  _GradientBackgroundPainter({required this.context});
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.height / 6, size.height / 6);
    final paint = Paint();
    paint.blendMode = BlendMode.overlay;
    paint.shader = (Theme.of(context).brightness == Brightness.light
            ? AppColors.lightBackgroundGradient
            : AppColors.darkBackgroundGradient)
        .createShader(rect);
    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 82);
    canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.1), size.width / 4, paint);
    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.9), size.width / 4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
