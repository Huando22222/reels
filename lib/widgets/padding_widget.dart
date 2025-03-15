import 'package:flutter/material.dart';
import 'package:reels/const/app_value.dart';

class PaddingWidget extends StatelessWidget {
  final Widget child;
  const PaddingWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppValue.padding.horizontal,
        vertical: AppValue.padding.vertical,
      ),
      child: child,
    );
  }
}
