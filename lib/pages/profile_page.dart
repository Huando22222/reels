import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:reels/config/app_route.dart';
import 'package:reels/models/notification.dart';
import 'package:reels/models/user.dart';
import 'package:reels/providers/notification_provider.dart';
import 'package:reels/providers/user_provider.dart';
import 'package:reels/services/firebase_service.dart';
import 'package:reels/services/push_notification_service.dart';
import 'package:reels/widgets/avatar_widget.dart';
import 'package:reels/widgets/icon_button_widget.dart';
import 'package:reels/widgets/screen_wrapper_widget.dart';
import 'package:reels/widgets/screen_wrapper_widget.dart';

enum FriendType {
  friend,
  notFriend,
  friendRequest,
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel? otherUserData =
        ModalRoute.of(context)?.settings.arguments as UserModel?;
    final userProvider = Provider.of<UserProvider>(context, listen: true);

    FriendType friend = FriendType.notFriend;
    if (otherUserData != null) {
      if (otherUserData.friendRequests
          .contains(context.read<UserProvider>().userData!.uid)) {
        friend = FriendType.friendRequest;
      } else if (otherUserData.friends
          .contains(context.read<UserProvider>().userData!.uid)) {
        friend = FriendType.friend;
      } else {
        friend = FriendType.notFriend;
      }
    }

    return ScreenWrapperWidget(
      showBackButton: true,
      title: "Profile",
      actions: [
        if (otherUserData == null) ...[
          IconButtonWidget(
            hugeIcon: HugeIcons.strokeRoundedAccountSetting02,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoute.editProfile);
            },
          ),
          IconButtonWidget(
            hugeIcon: HugeIcons.strokeRoundedLogout05,
            onTap: () {
              userProvider.signOut(context);
            },
          ),
        ] else ...[
          IconButtonWidget(
            hugeIcon: HugeIcons.strokeRoundedSent,
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoute.chat,
                arguments: otherUserData,
              );
            },
          ),
          IconButtonWidget(
            hugeIcon: friend == FriendType.friendRequest
                ? HugeIcons.strokeRoundedMailSend02
                : (friend == FriendType.friend
                    ? HugeIcons.strokeRoundedUserMultiple02
                    : HugeIcons.strokeRoundedAddTeam),
            onTap: () async {
              FirebaseService firebaseService = FirebaseService();

              if (friend == FriendType.friend) {
                //unfriend
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("are you sure to unfriend?"),
                      // content: Text("content"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text("No"),
                        ),
                        TextButton(
                          onPressed: () {
                            firebaseService.addOrRemoveFriend(
                              friendType: friend,
                              otherUserId: otherUserData.uid,
                            );
                            Navigator.of(context).pop();
                          }, // Yes
                          child: Text("Yes"),
                        ),
                      ],
                    );
                  },
                );
              } else {
                //request- cancel req
                final result = await firebaseService.addOrRemoveFriend(
                  friendType: friend,
                  otherUserId: otherUserData.uid,
                );
                if (result) {
                  if (friend == FriendType.notFriend) {
                    final PushNotificationService pushNotificationService =
                        PushNotificationService();
                    pushNotificationService.sendNotificationToSelectedUser(
                      context: context,
                      title: "Reels",
                      body:
                          "Friend Request from ${userProvider.userData!.name}",
                      data: {},
                    );
                    context.read<NotificationProvider>().addNotification(
                          sender: userProvider.userData!,
                          sentTime: DateTime.now(),
                          type: NotificationType.friendRequest,
                          receiverId: otherUserData.uid,
                        );
                  }
                }
              }
            },
          ),
        ],
      ],
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (otherUserData == null)
              Consumer<UserProvider>(
                builder: (context, value, child) {
                  if (value.userData == null) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return _buildProfileContent(value.userData!);
                },
              )
            else
              _buildProfileContent(otherUserData),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(UserModel user) {
    return Column(
      children: [
        AvatarWidget(
          pathImage: user.image,
          size: 150,
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedTag01,
                color: Colors.black,
                size: 24.0,
              ),
              SizedBox(width: 10),
              Text(user.name),
            ],
          ),
        ),
      ],
    );
  }
}
