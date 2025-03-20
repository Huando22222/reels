import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reels/models/notification.dart';
import 'package:reels/providers/notification_provider.dart';
import 'package:reels/widgets/friend_request_card_widget.dart';

import 'package:reels/widgets/screen_wrapper_widget.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapperWidget(
      extendBodyBehindAppBar: false,
      showBackButton: true,
      child: Container(
        decoration: BoxDecoration(),
        child: Consumer<NotificationProvider>(
          builder: (context, value, child) {
            return ListView.separated(
              itemBuilder: (context, index) {
                if (value.notifications[index].type ==
                    NotificationType.friendRequest) {
                  return FriendRequestCardWidget(
                    notification: value.notifications[index],
                  );
                }
                return SizedBox();
              },
              separatorBuilder: (context, index) {
                return SizedBox();
              },
              itemCount: value.notifications.length,
            );
          },
        ),
      ),
    );
  }
}
