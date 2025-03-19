class MessageModel {
  final String senderId;
  final String receiverId;
  final String content;
  final String? contentReactPost;
  final DateTime sentTime;
  final MessageType messageType;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.contentReactPost,
    required this.sentTime,
    required this.messageType,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        receiverId: json['receiverId'],
        senderId: json['senderId'],
        sentTime: json['sentTime'].toDate(),
        content: json['content'],
        contentReactPost: json['contentReactPost'] ?? "",
        messageType: MessageType.fromJson(json['messageType']),
      );
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'contentReactPost': contentReactPost,
      'sentTime': sentTime,
      'messageType': messageType.toJson(),
    };
  }
}

enum MessageType {
  text,
  image,
  reactPost;

  String toJson() => name;
  factory MessageType.fromJson(String json) => values.byName(json);
}
