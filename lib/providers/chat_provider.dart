import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reels/models/message.dart';
import 'package:reels/services/image_service.dart';
import 'package:reels/services/push_notification_service.dart';

class ChatProvider extends ChangeNotifier {
  ScrollController scrollController = ScrollController();
  List<MessageModel> messages = [];
  StreamSubscription<DocumentSnapshot>? _chatSubscription;
  final PushNotificationService _pushNotificationService =
      PushNotificationService();
  void listenForMessage({required String receiverId}) async {
    log("start listening for message !!!!!!!!!!!!!!!");
    _chatSubscription?.cancel();
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("chat")
        .doc(receiverId)
        .collection('messages')
        .orderBy('sentTime', descending: false)
        .snapshots(includeMetadataChanges: true)
        .listen(
      (messages) {
        this.messages = messages.docs
            .map((doc) => MessageModel.fromJson(doc.data()))
            .toList();
        notifyListeners();

        scrollDown();
      },
    );
  }

  void _cancelChatSubscription() {
    _chatSubscription?.cancel();
    _chatSubscription = null;
  }

  @override
  void dispose() {
    _cancelChatSubscription();
    scrollController.dispose();
    super.dispose();
  }

  Future<bool> addTextMessage({
    required String content,
    required String receiverId,
  }) async {
    try {
      final message = MessageModel(
        content: content.trim(),
        sentTime: DateTime.now(),
        receiverId: receiverId,
        messageType: MessageType.text,
        senderId: FirebaseAuth.instance.currentUser!.uid,
      );

      await _addMessageToChat(receiverId, message);
      scrollDown();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addImageMessage({
    required String filePath,
    required String receiverId,
    required String receiverEmail,
  }) async {
    try {
      final ImageService imageService = ImageService();
      final imageURL = await imageService.uploadImage(
        filePath: filePath,
        folderPath:
            'chats/${FirebaseAuth.instance.currentUser!.email}_$receiverEmail',
      );
      if (imageURL == null || imageURL.isEmpty) return false;
      final message = MessageModel(
        content: imageURL,
        sentTime: DateTime.now(),
        receiverId: receiverId,
        messageType: MessageType.image,
        senderId: FirebaseAuth.instance.currentUser!.uid,
      );

      await _addMessageToChat(receiverId, message);
      scrollDown();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addTextReactPost({
    required String content,
    required String contentReactPost,
    required String receiverId,
  }) async {
    try {
      final message = MessageModel(
        content: content,
        contentReactPost: contentReactPost,
        sentTime: DateTime.now(),
        receiverId: receiverId,
        messageType: MessageType.reactPost,
        senderId: FirebaseAuth.instance.currentUser!.uid,
      );

      await _addMessageToChat(receiverId, message);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _addMessageToChat(
    String receiverId,
    MessageModel message,
  ) async {
    final senderId = FirebaseAuth.instance.currentUser!.uid;
    final senderRef = FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .collection('chat')
        .doc(receiverId);

    final receiverRef = FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chat')
        .doc(senderId);

    final senderMessagesRef = senderRef.collection('messages').doc();
    final receiverMessagesRef = receiverRef.collection('messages').doc();

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        senderRef,
        {'latestMessage': message.toJson()},
        SetOptions(merge: true),
      );
      transaction.set(
        senderMessagesRef,
        message.toJson(),
      );

      transaction.set(
        receiverRef,
        {'latestMessage': message.toJson()},
        SetOptions(merge: true),
      );
      transaction.set(
        receiverMessagesRef,
        message.toJson(),
      );
    });
  }

  void scrollDown() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
}
