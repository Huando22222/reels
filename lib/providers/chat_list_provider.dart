import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reels/models/chat_list.dart';
import 'package:reels/models/message.dart';
import 'package:reels/models/user.dart';

class ChatListProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<ChatListModel> chatList = [];

  StreamSubscription<QuerySnapshot>? _chatCollectionSubscription;
  Map<String, StreamSubscription<DocumentSnapshot>> _chatDocSubscriptions = {};

  void listenForNewChats() async {
    _chatCollectionSubscription?.cancel();

    if (_auth.currentUser == null) return;

    _chatCollectionSubscription = _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('chat')
        .snapshots()
        .listen((chatSnapshots) {
      Set<String> currentChats =
          chatSnapshots.docs.map((doc) => doc.id).toSet();

      _chatDocSubscriptions.keys
          .where((id) => !currentChats.contains(id))
          .toList()
          .forEach((id) {
        _chatDocSubscriptions[id]?.cancel();
        _chatDocSubscriptions.remove(id);
      });

      for (var chatDoc in chatSnapshots.docs) {
        String receiverId = chatDoc.id;
        _listenForChatUpdates(receiverId);
      }

      if (chatSnapshots.docs.isEmpty) {
        chatList = [];
        notifyListeners();
      }
    });
  }

  void _listenForChatUpdates(String receiverId) {
    _chatDocSubscriptions[receiverId]?.cancel();

    _chatDocSubscriptions[receiverId] = _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('chat')
        .doc(receiverId)
        .snapshots()
        .listen((chatDoc) async {
      if (!chatDoc.exists || chatDoc.data() == null) return;

      await _updateChatList();
    });
  }

  Future<void> _updateChatList() async {
    if (_auth.currentUser == null) return;

    try {
      QuerySnapshot chatSnapshots = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('chat')
          .get();

      List<ChatListModel> updatedChatList = [];

      for (var chatDoc in chatSnapshots.docs) {
        String receiverId = chatDoc.id;
        Map<String, dynamic> chatData = chatDoc.data() as Map<String, dynamic>;

        if (!chatData.containsKey('latestMessage')) continue;

        try {
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(receiverId).get();

          if (!userDoc.exists || userDoc.data() == null) {
            log("404 user : $receiverId");
            continue;
          }

          UserModel user =
              UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
          MessageModel latestMessage =
              MessageModel.fromJson(chatData['latestMessage']);

          updatedChatList.add(ChatListModel(
            user: user,
            message: latestMessage,
          ));
        } catch (e) {
          log("Error getting user data for $receiverId: $e");
        }
      }

      updatedChatList
          .sort((a, b) => b.message.sentTime.compareTo(a.message.sentTime));

      chatList = updatedChatList;
      notifyListeners();
    } catch (e) {
      log("Error updating chat list: $e");
    }
  }

  void cancelChatListSubscription() {
    _chatCollectionSubscription?.cancel();

    for (var subscription in _chatDocSubscriptions.values) {
      subscription.cancel();
    }
    _chatDocSubscriptions.clear();
  }

  @override
  void dispose() {
    cancelChatListSubscription();
    super.dispose();
  }
}
