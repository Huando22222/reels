import 'package:reels/models/user.dart';

class NotificationModel {
  final String id;
  final NotificationType type;
  final UserModel sender;
  final DateTime sentTime;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.sender,
    required this.sentTime,
    this.isRead = false,
  });

  // factory NotificationModel.fromJson(Map<String, dynamic> json) =>
  //     NotificationModel(
  //       sender: UserModel.fromJson(json['sender']),
  //       sentTime: json['sentTime'].toDate(),
  //       type: NotificationType.fromJson(json['type']),
  //       isRead: json['isRead'] ?? false,
  //     );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sender': sender.toJson(),
      'sentTime': sentTime,
      'type': type.toJson(),
      'isRead': isRead,
    };
  }
}

enum NotificationType {
  friendRequest,
  postReaction;

  String toJson() => name;
  factory NotificationType.fromJson(String json) => values.byName(json);
}

enum FriendType {
  friend,
  notFriend,
  friendRequest,
}
