import 'package:flutter/material.dart';
import 'package:reels/config/app_route.dart';
import 'package:reels/models/notification.dart';
import 'package:reels/services/firebase_service.dart';
import 'package:reels/services/utils_service.dart';
import 'package:reels/widgets/avatar_widget.dart';

class FriendRequestCardWidget extends StatelessWidget {
  final NotificationModel notification;

  const FriendRequestCardWidget({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    // String formatTime(DateTime sentTime) {
    //   final now = DateTime.now();
    //   final difference = now.difference(sentTime);

    //   if (difference.inMinutes < 60) {
    //     return "${difference.inMinutes} m ago";
    //   } else if (difference.inHours < 24) {
    //     return "${difference.inHours} h ago";
    //   } else {
    //     return "${difference.inDays} d ago";
    //   }
    // }

    Future<void> handleAddFriend() async {
      try {
        final success = await firebaseService.handleFriendRequest(
          requesterUserId: notification.sender.uid,
          accept: true,
        );
        if (success) {
          await firebaseService.updateNotificationStatus(
            notificationId: notification.id,
            isRead: true,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Friend request accepted!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to accept request")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to accept request")),
        );
      }
    }

    Future<void> handleCancel() async {
      try {
        final success = await firebaseService.handleFriendRequest(
          requesterUserId: notification.sender.uid,
          accept: false,
        );
        if (success) {
          await firebaseService.updateNotificationStatus(
              isRead: true, notificationId: notification.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to decline request")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to decline request")),
        );
      }
    }

    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed(AppRoute.profile, arguments: notification.sender);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AvatarWidget(
              pathImage: notification.sender.image,
              size: 50,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.sender.name,
                          maxLines: 2,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        UtilsService.formatTime(notification.sentTime),
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  if (!notification.isRead)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () => handleAddFriend(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          child: const Text(
                            "Add",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        OutlinedButton(
                          onPressed: () => handleCancel(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          child: Text(
                            "Decline",
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ),
                      ],
                    )
                  else
                    const Text(
                      "Processed",
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
