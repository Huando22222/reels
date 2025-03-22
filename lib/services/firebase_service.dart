import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reels/models/notification.dart';
import 'package:reels/models/post.dart';
import 'package:reels/models/response.dart';
import 'package:reels/models/user.dart';

class FirebaseService {
  FirebaseService._internal();
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() {
    return _instance;
  }

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<ResponseModel> upsertUser({required UserModel user}) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.name,
        'email': user.email,
        'lastActive': user.lastActive,
        'isOnline': user.isOnline,
        'image': user.image,
      });
      return ResponseModel(success: true, msg: 'update successfully');
    } on FirebaseException catch (e) {
      log("error upsertUser : ${e.code}");
      return ResponseModel.error(code: e.code, message: e.message);
    }
  }

  Future<UserModel?> getUserData({required String uid}) async {
    try {
      final data = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(const GetOptions(source: Source.server));
      if (data.exists) {
        return UserModel.fromJson(data.data()!);
      }
      return null;
    } on FirebaseException catch (e, stackTrace) {
      log("error getUserData : ${e.code} ==$stackTrace");
      return null;
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    return await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<bool> isVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    return FirebaseAuth.instance.currentUser!.emailVerified;
  }

  Future<void> sendEmailVerification() async {
    return await FirebaseAuth.instance.currentUser!.sendEmailVerification();
  }

  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      return userCredential;
    } on FirebaseAuthException catch (e, stacktrace) {
      log("${e.code} - $email - $password - $stacktrace");
      return null;
      // throw Exception(e.code);
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      upsertUser(
        user: UserModel(
          uid: userCredential.user!.uid,
          name: email,
          email: email,
          image: '',
          isOnline: true,
          friends: [],
          friendRequests: [],
          token: '',
          lastActive: DateTime.now(),
        ),
      );
      return userCredential;
    } on FirebaseAuthException catch (e, stacktrace) {
      log("${e.code} - $email - $password - $stacktrace ");
      return null;
      // throw Exception(e.code);
    }
  }

  Future<List<UserModel>> searchUser({required String name}) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("name", isGreaterThanOrEqualTo: name)
        .get();
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }

  Future<void> signOut() async {
    //offline set later
    return await FirebaseAuth.instance.signOut();
  }

  Future<bool> addOrRemoveFriend({
    required FriendType friendType,
    required String otherUserId,
  }) async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final otherUserRef =
          FirebaseFirestore.instance.collection('users').doc(otherUserId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final otherUserSnapshot = await transaction.get(otherUserRef);

        if (!otherUserSnapshot.exists) {
          // throw Exception("User not found");
          return false;
        }

        final List<String> otherUserFriends =
            (otherUserSnapshot.data()?['friends'] as List?)?.cast<String>() ??
                [];
        final List<String> otherUserRequests =
            (otherUserSnapshot.data()?['friendRequests'] as List?)
                    ?.cast<String>() ??
                [];

        if (friendType == FriendType.friendRequest) {
          otherUserRequests.remove(currentUserId);
        } else if (friendType == FriendType.friend) {
          otherUserFriends.remove(currentUserId);
        } else {
          if (!otherUserRequests.contains(currentUserId)) {
            otherUserRequests.add(currentUserId);
          }
        }

        transaction.update(otherUserRef, {
          'friends': otherUserFriends,
          'friendRequests': otherUserRequests,
        });
      });

      return true;
    } catch (e) {
      log("$e");
      return false;
    }
  }

  Future<void> updateNotificationStatus({
    required String notificationId,
    required bool isRead,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': isRead});
  }

  Future<bool> handleFriendRequest({
    required String requesterUserId,
    required bool accept,
  }) async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserId);
      final requesterUserRef =
          FirebaseFirestore.instance.collection('users').doc(requesterUserId);

      return await FirebaseFirestore.instance
          .runTransaction((transaction) async {
        final currentUserSnapshot = await transaction.get(currentUserRef);
        final requesterUserSnapshot = await transaction.get(requesterUserRef);

        if (!currentUserSnapshot.exists || !requesterUserSnapshot.exists) {
          return false;
        }

        final List<String> currentUserFriends =
            (currentUserSnapshot.data()?['friends'] as List?)?.cast<String>() ??
                [];
        final List<String> currentUserRequests =
            (currentUserSnapshot.data()?['friendRequests'] as List?)
                    ?.cast<String>() ??
                [];
        final List<String> requesterUserFriends =
            (requesterUserSnapshot.data()?['friends'] as List?)
                    ?.cast<String>() ??
                [];

        if (!currentUserRequests.contains(requesterUserId)) {
          return false;
        }

        currentUserRequests.remove(requesterUserId);

        if (accept) {
          if (!currentUserFriends.contains(requesterUserId)) {
            currentUserFriends.add(requesterUserId);
          }
          if (!requesterUserFriends.contains(currentUserId)) {
            requesterUserFriends.add(currentUserId);
          }

          transaction.update(currentUserRef, {
            'friends': currentUserFriends,
            'friendRequests': currentUserRequests,
          });

          transaction.update(requesterUserRef, {
            'friends': requesterUserFriends,
          });
        } else {
          transaction.update(currentUserRef, {
            'friendRequests': currentUserRequests,
          });
        }

        return true;
      });
    } catch (e) {
      log("Error handling friend request: $e");
      return false;
    }
  }

  Future<List<UserModel>> getListUser(List<String> listUserId) async {
    if (listUserId.isEmpty) {
      return [];
    }

    const int batchSize = 10;
    List<UserModel> returnList = [];

    for (int i = 0; i < listUserId.length; i += batchSize) {
      final batch = listUserId.sublist(
        i,
        i + batchSize > listUserId.length ? listUserId.length : i + batchSize,
      );

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      final usersBatch = querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();

      returnList.addAll(usersBatch);
    }

    return returnList;
  }

  Future<List<PostModel>> getListPostFriend({required String uidFriend}) async {
    log("getListPostFriend");
    final querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('owner.uid', isEqualTo: uidFriend)
        .where('visibleTo',
            arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .get();
    return querySnapshot.docs.map(
      (e) {
        log("$e");
        return PostModel.fromJson(e.data());
      },
    ).toList();
  }
}
