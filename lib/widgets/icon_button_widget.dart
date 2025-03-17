// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class IconButtonWidget extends StatelessWidget {
  final IconData hugeIcon;
  final VoidCallback? onTap;
  final Color? color;
  final double? size;
  final double? padding;
  final BoxDecoration? boxDecoration;
  const IconButtonWidget({
    super.key,
    required this.hugeIcon,
    this.onTap,
    this.color,
    this.size,
    this.padding,
    this.boxDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final double paddingValue = padding ?? 10.0;
    final double iconSize = size ?? 24.0;
    final double buttonSize = iconSize + (paddingValue * 2);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(buttonSize / 2),
      child: Container(
        padding: EdgeInsets.all(paddingValue),
        decoration: boxDecoration?.copyWith(
              shape: BoxShape.circle,
            ) ??
            const BoxDecoration(
              shape: BoxShape.circle,
            ),
        child: HugeIcon(
          icon: hugeIcon,
          color: color ?? Colors.black,
          size: iconSize,
        ),
      ),
    );
  }
}
