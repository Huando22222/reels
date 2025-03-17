// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reels/models/post.dart';
import 'package:reels/providers/user_provider.dart';
import 'package:reels/services/utils_service.dart';
import 'package:reels/widgets/avatar_widget.dart';

class PostWidget extends StatelessWidget {
  final PostModel post;
  const PostWidget({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final paddingHorizontal = 20.0;
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: paddingHorizontal,
        right: paddingHorizontal,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: size.height * 0.1,
          ),
          Container(
            decoration: BoxDecoration(),
            height: MediaQuery.of(context).size.width - 2 * paddingHorizontal,
            width: MediaQuery.of(context).size.width - 2 * paddingHorizontal,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                post.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            width: size.width * 0.5,
            child: Row(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AvatarWidget(
                  isCircle: true,
                  size: 50,
                  pathImage: post.owner.image,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        context.read<UserProvider>().userData!.uid ==
                                post.owner.uid
                            ? "you"
                            : post.owner.name,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                      Text(
                        UtilsService.formatTime(post.createdAt),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
