import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:photo_view/photo_view.dart';
import 'package:reels/widgets/icon_button_widget.dart';

class ImageViewPage extends StatelessWidget {
  const ImageViewPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = ModalRoute.of(context)!.settings.arguments!;
    return GestureDetector(
      onVerticalDragUpdate: (details) {},
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButtonWidget(
            onTap: () => Navigator.of(context).pop(),
            hugeIcon: HugeIcons.strokeRoundedLinkBackward,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: PhotoView(
            imageProvider: NetworkImage("$imagePath"),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: imagePath),
          ),
        ),
      ),
    );
  }
}
