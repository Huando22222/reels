import 'package:flutter/material.dart';

class SurfaceWidget extends StatelessWidget {
  final double? width;
  final Widget child;
  const SurfaceWidget({super.key, this.width = 2, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface,
          width: width!,
        ),
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
