import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String image;
  final List<String> friends;
  final List<String> friendRequests;
  final String token;
  final DateTime lastActive;
  final bool isOnline;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.image,
    required this.friends,
    required this.friendRequests,
    required this.token,
    required this.lastActive,
    this.isOnline = false,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? image,
    List<String>? friends,
    List<String>? friendRequests,
    String? token,
    DateTime? lastActive,
    bool? isOnline,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
      token: token ?? this.token,
      lastActive: lastActive ?? this.lastActive,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'image': image,
      'friends': friends,
      'friendRequests': friendRequests,
      'token': token,
      'lastActive': Timestamp.fromDate(lastActive),
      'isOnline': isOnline,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      image: json['image'] ?? "",
      friends: List<String>.from(json['friends'] ?? []),
      friendRequests: List<String>.from(json['friendRequests'] ?? []),
      token: json['token'] ?? "",
      lastActive: (json['lastActive'] as Timestamp).toDate(),
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, image: $image, '
        'friends: ${friends.length} friends, token: $token, '
        'lastActive: $lastActive, isOnline: $isOnline)';
  }
}
