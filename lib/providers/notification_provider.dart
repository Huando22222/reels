// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:reels/models/notification.dart';
import 'package:reels/models/user.dart';

class NotificationProvider extends ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  List<NotificationModel> notifications = [];
  StreamSubscription<QuerySnapshot>? _notificationSubscription;

  void listenForNotification() async {
    _notificationSubscription = firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('notifications')
        .snapshots(includeMetadataChanges: true)
        .listen(
      (item) {
        notifications = item.docs.map((doc) {
          final data = doc.data();
          return NotificationModel(
            id: doc.id,
            type: NotificationType.fromJson(data['type']),
            sender: UserModel.fromJson(data['sender']),
            sentTime: (data['sentTime'] as Timestamp).toDate(),
            isRead: data['isRead'] ?? false,
          );
        }).toList();
        notifyListeners();
      },
    );
  }

  Future<bool> addNotification({
    required NotificationType type,
    required UserModel sender,
    required DateTime sentTime,
    required String receiverId,
    bool isRead = false,
  }) async {
    try {
      firestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .add({
        'type': type.toJson(),
        'sender': sender.toJson(),
        'sentTime': sentTime,
        'isRead': isRead,
      });
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  void cancelNotificationSubscription() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
  }

  @override
  void dispose() {
    cancelNotificationSubscription();
    super.dispose();
  }
}
