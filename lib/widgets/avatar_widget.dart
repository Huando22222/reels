import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:reels/widgets/icon_button_widget.dart';

class AvatarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final double? size;
  final String? pathImage;
  final File? imageFile;
  const AvatarWidget({
    super.key,
    this.onTap,
    this.size,
    this.pathImage,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    final dv = MediaQuery.of(context).size;
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius:
            BorderRadius.all(Radius.circular(size ?? dv.width * 0.08)),
        child: imageFile != null
            ? Image.file(
                imageFile!,
                fit: BoxFit.cover,
                height: size ?? dv.width * 0.08,
                width: size ?? dv.width * 0.08,
              )
            : (pathImage != null
                ? Image.network(
                    pathImage!,
                    fit: BoxFit.cover,
                    height: size ?? dv.width * 0.08,
                    width: size ?? dv.width * 0.08,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar(dv: dv, context: context);
                    },
                  )
                : _buildDefaultAvatar(dv: dv, context: context)),
      ),
    );
  }

  Widget _buildDefaultAvatar(
      {required Size dv, required BuildContext context}) {
    return HugeIcon(
      icon: HugeIcons.strokeRoundedUser,
      // icon: HugeIcons.strokeRoundedUserSquare,
      color: Theme.of(context).colorScheme.onSurface,
      size: size ?? dv.width * 0.08,
    );
  }
}
