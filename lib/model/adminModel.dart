// To parse this JSON data, do
//
//     final adminListModel = adminListModelFromJson(jsonString);

import 'dart:convert';

List<AdminListModel> adminListModelFromJson(String str) =>
    List<AdminListModel>.from(
        json.decode(str).map((x) => AdminListModel.fromJson(x)));

String adminListModelToJson(List<AdminListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AdminListModel {
  AdminListModel({
    this.status,
    this.email,
  });

  String status;
  String email;

  factory AdminListModel.fromJson(Map<String, dynamic> json) => AdminListModel(
        status: json["status"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "email": email,
      };
}
