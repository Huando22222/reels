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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: child),
    );
  }
}
