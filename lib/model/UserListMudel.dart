// To parse this JSON data, do
//
//     final userListModel = userListModelFromJson(jsonString);

import 'dart:convert';

List<UserListModel> userListModelFromJson(String str) =>
    List<UserListModel>.from(
        json.decode(str).map((x) => UserListModel.fromJson(x)));

String userListModelToJson(List<UserListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserListModel {
  UserListModel({
    this.uid,
    this.potin,
    this.phone,
    this.name,
    this.location,
    this.photoUrl,
    this.credit,
    this.email,
    this.status,
    this.token,
  });

  String uid;
  String potin;
  String phone;
  String name;
  String location;
  String photoUrl;
  String credit;
  String email;
  String status;
  String token;

  factory UserListModel.fromJson(Map<String, dynamic> json) => UserListModel(
        uid: json["uid"],
        potin: json["potin"],
        phone: json["phone"],
        name: json["name"],
        location: json["location"],
        photoUrl: json["photo_url"],
        credit: json["credit"],
        email: json["email"],
        status: json["status"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "potin": potin,
        "phone": phone,
        "name": name,
        "location": location,
        "photo_url": photoUrl,
        "credit": credit,
        "email": email,
        "status": status,
        "token": token,
      };
}
