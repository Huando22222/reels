import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reels/models/user.dart';
import 'package:reels/providers/chat_list_provider.dart';
import 'package:reels/providers/notification_provider.dart';
import 'package:reels/providers/post_provider.dart';
import 'package:reels/services/firebase_service.dart';
import 'package:reels/services/push_notification_service.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _authService = FirebaseService();
  User? _user;
  User? get user => _user;
  UserModel? userData;
  bool isLoading = false;
  StreamSubscription<DocumentSnapshot>? _userDataSubscription;
  UserProvider() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        isLoading = true;
        notifyListeners();
        final pushNotificationService = PushNotificationService();
        await pushNotificationService.requestPermission();
        await pushNotificationService.getToken();
        await getUserData();
        _listenForUser();
        isLoading = false;
      } else {
        //
      }
      notifyListeners();
    });
  }

  void _listenForUser() async {
    if (_user == null || userData == null) return;

    _cancelUserDataSubscription();

    _userDataSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .snapshots(includeMetadataChanges: true)
        .listen(
      (snapshot) {
        if (snapshot.exists) {
          userData = UserModel.fromJson(snapshot.data()!);
          notifyListeners();
        }
      },
      onError: (error) {
        log("Error listening to user data: $error");
      },
    );
  }

  void _cancelUserDataSubscription() {
    _userDataSubscription?.cancel();
    _userDataSubscription = null;
  }

  Future<void> getUserData() async {
    final data = await _authService.getUserData(uid: _user!.uid);
    userData = data;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelUserDataSubscription();
    super.dispose();
  }

  void _cancelAllListeners({required BuildContext context}) {
    context.read<NotificationProvider>().cancelNotificationSubscription();
    context.read<ChatListProvider>().cancelChatListSubscription();
    context.read<PostProvider>().cancelPostSubscription();
    _cancelUserDataSubscription();
  }

  void addAllListeners({required BuildContext context}) {
    context.read<ChatListProvider>().listenForNewChats();
    context.read<NotificationProvider>().listenForNotification();
    context.read<PostProvider>().listenForPost();
  }

  Future<void> signOut(BuildContext context) async {
    _cancelUserDataSubscription();
    userData = null;
    Navigator.popUntil(context, (route) => route.isFirst);
    await _auth.signOut();
    _cancelAllListeners(context: context);
    notifyListeners();
  }
}
