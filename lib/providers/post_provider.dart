import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reels/models/post.dart';
import 'package:reels/providers/user_provider.dart';
import 'package:reels/services/image_service.dart';
import 'package:reels/services/push_notification_service.dart';

class PostProvider extends ChangeNotifier {
  List<PostModel> listPosts = [];
  StreamSubscription<DocumentSnapshot>? _postSubscription;
  void listenForPost() async {
    FirebaseFirestore.instance
        .collection('posts')
        .where('visibleTo',
            arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen(
      (snapshot) {
        List<PostModel> tempList =
            snapshot.docs.map((doc) => PostModel.fromJson(doc.data())).toList();

        tempList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        listPosts = tempList;
        notifyListeners();
      },
    );
  }

  void cancelPostSubscription() {
    _postSubscription?.cancel();
    _postSubscription = null;
  }

  @override
  void dispose() {
    cancelPostSubscription();
    super.dispose();
  }

  Future<bool> createPost({
    String? content,
    required String imagePath,
    required BuildContext context,
  }) async {
    try {
      ImageService imageService = ImageService();
      PushNotificationService pushNotificationService =
          PushNotificationService();
      final urlBucket = await imageService.uploadImage(
        filePath: imagePath,
        folderPath: 'posts/${context.read<UserProvider>().userData!.email}',
      );
      if (urlBucket == null || urlBucket.isEmpty) return false;
      final data = context.read<UserProvider>().userData!;

      PostModel post = PostModel(
        id: FirebaseFirestore.instance.collection('posts').doc().id,
        owner: data,
        content: content ?? "",
        image: urlBucket,
        visibleTo: [...data.friends, data.uid],
        createdAt: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(post.id)
          .set(post.toJson());
      // for (var friend in data.friends) {
      //   pushNotificationService.sendNotificationToSelectedUser(
      //     //id
      //     context: context,
      //     title: 'New Post',
      //     body: "${data.name} has new status",
      //     data: {},
      //   );
      // }

      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
