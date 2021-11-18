// To parse this JSON data, do
//
//     final chatListModel = chatListModelFromJson(jsonString);

import 'dart:convert';

List<ChatListModel> chatListModelFromJson(String str) =>
    List<ChatListModel>.from(
        json.decode(str).map((x) => ChatListModel.fromJson(x)));

String chatListModelToJson(List<ChatListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatListModel {
  ChatListModel({
    this.author,
    this.createdAt,
    this.id,
    this.status,
    this.text,
    this.type,
  });

  Author author;
  int createdAt;
  String id;
  String status;
  String text;
  String type;

  factory ChatListModel.fromJson(Map<String, dynamic> json) => ChatListModel(
        author: Author.fromJson(json["author"]),
        createdAt: json["createdAt"],
        id: json["id"],
        status: json["status"],
        text: json["text"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "author": author.toJson(),
        "createdAt": createdAt,
        "id": id,
        "status": status,
        "text": text,
        "type": type,
      };
}

ChatOneModel chatOneModelFromJson(String str) =>
    ChatOneModel.fromJson(json.decode(str));

String chatOneModelToJson(ChatOneModel data) => json.encode(data.toJson());

class ChatOneModel {
  ChatOneModel({
    this.author,
    this.createdAt,
    this.id,
    this.status,
    this.text,
    this.type,
  });

  Author author;
  int createdAt;
  String id;
  String status;
  String text;
  String type;

  factory ChatOneModel.fromJson(Map<String, dynamic> json) => ChatOneModel(
        author: Author.fromJson(json["author"]),
        createdAt: json["createdAt"],
        id: json["id"],
        status: json["status"],
        text: json["text"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "author": author.toJson(),
        "createdAt": createdAt,
        "id": id,
        "status": status,
        "text": text,
        "type": type,
      };
}

class Author {
  Author({
    this.firstName,
    this.id,
    this.imageUrl,
  });

  String firstName;
  String id;
  String imageUrl;

  factory Author.fromJson(Map<String, dynamic> json) => Author(
        firstName: json["firstName"],
        id: json["id"],
        imageUrl: json["imageUrl"],
      );

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "id": id,
        "imageUrl": imageUrl,
      };
}
