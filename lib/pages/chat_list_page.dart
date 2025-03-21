import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reels/config/app_route.dart';
import 'package:reels/models/message.dart';
import 'package:reels/providers/chat_list_provider.dart';
import 'package:reels/providers/user_provider.dart';
import 'package:reels/widgets/avatar_widget.dart';
import 'package:reels/widgets/surface_widget.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = context.read<UserProvider>().userData;
    return Consumer<ChatListProvider>(
      builder: (context, value, child) {
        if (value.chatList.isNotEmpty) {
          return ListView.separated(
            itemBuilder: (context, index) {
              String content =
                  value.chatList[index].message.messageType == MessageType.text
                      ? value.chatList[index].message.content
                      : value.chatList[index].message.messageType ==
                              MessageType.text
                          ? "Sent a image"
                          : "sent a react post";
              if (userData!.uid == value.chatList[index].message.senderId) {
                content = "You: $content";
              }
              return ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoute.chat,
                    arguments: value.chatList[index].user,
                  );
                },
                title: Text(
                  value.chatList[index].user.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                leading: SurfaceWidget(
                  child: AvatarWidget(
                    pathImage: value.chatList[index].user.image,
                    size: 50,
                  ),
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${value.chatList[index].message.sentTime.hour.toString().padLeft(2, '0')}:${value.chatList[index].message.sentTime.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox();
            },
            itemCount: value.chatList.length,
          );
        } else {
          return Center(
            child: Text(
              "dont have any message yet!",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
      },
    );
  }
}
