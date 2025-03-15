import 'package:reels/models/message.dart';
import 'package:reels/models/user.dart';

class ChatListModel {
  final UserModel user;
  final MessageModel message;

  ChatListModel({
    required this.user,
    required this.message,
  });
}
