import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ScreenWrapperWidget extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final Widget? leadingWidget;
  final Widget? bottomSheet;
  final String? title;
  final List<Widget>? actions;

  const ScreenWrapperWidget({
    super.key,
    required this.child,
    this.showBackButton = true,
    this.leadingWidget,
    this.bottomSheet,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;

    return Scaffold(
      bottomSheet: bottomSheet,
      extendBody: false,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.red,
              ],
            ),
          ),
        ),
        leading: showBackButton
            ? (Navigator.canPop(context)
                ? GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedLinkBackward,
                      color: Colors.black,
                      size: 24.0,
                    ),
                  )
                : null)
            : leadingWidget ?? SizedBox.shrink(),
        centerTitle: true,
        title: title != null
            ? Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium,
              )
            : null,
        actions: actions,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      const Color.fromARGB(118, 0, 0, 0),
                      Colors.red,
                    ],
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: child),
        ],
      ),
    );
  }
}
