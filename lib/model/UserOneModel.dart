// To parse this JSON data, do
//
//     final userOneModel = userOneModelFromJson(jsonString);

import 'dart:convert';

UserOneModel userOneModelFromJson(String str) =>
    UserOneModel.fromJson(json.decode(str));

String userOneModelToJson(UserOneModel data) => json.encode(data.toJson());

class UserOneModel {
  UserOneModel({
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
    this.os,
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
  String os;

  factory UserOneModel.fromJson(Map<String, dynamic> json) => UserOneModel(
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
        os: json["os"],
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
        "os": os,
      };
}
