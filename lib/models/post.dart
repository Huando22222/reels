import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reels/models/user.dart';

class PostModel {
  final String id;
  final UserModel owner;
  final String? content;
  final String image;
  final List<String> visibleTo;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.owner,
    this.content,
    required this.image,
    required this.visibleTo,
    required this.createdAt,
  });

  PostModel copyWith({
    String? id,
    UserModel? owner,
    String? content,
    String? image,
    List<String>? visibleTo,
    DateTime? createdAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      content: content ?? this.content,
      image: image ?? this.image,
      visibleTo: visibleTo ?? this.visibleTo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'owner': owner.toJson(),
      'content': content,
      'image': image,
      'visibleTo': visibleTo,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      owner: UserModel.fromJson(json['owner']),
      content: json['content'] ?? "",
      image: json['image'],
      visibleTo: List<String>.from(json['visibleTo'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  @override
  String toString() {
    return 'PostModel(id: $id, owner: $owner, content: $content, image: $image, '
        'visibleTo: ${visibleTo.length} users, createdAt: $createdAt)';
  }
}
