// To parse this JSON data, do
//
//     final appConfigModel = appConfigModelFromJson(jsonString);

import 'dart:convert';

AppConfigModel appConfigModelFromJson(String str) =>
    AppConfigModel.fromJson(json.decode(str));

String appConfigModelToJson(AppConfigModel data) => json.encode(data.toJson());

class AppConfigModel {
  AppConfigModel({
    this.dateopen,
    this.projectVersion,
    this.costDelivery,
    this.status,
    this.customerOpen,
    this.emailLogin,
  });

  DateTime dateopen;
  String projectVersion;
  String costDelivery;
  String status;
  String customerOpen;
  String emailLogin;

  factory AppConfigModel.fromJson(Map<String, dynamic> json) => AppConfigModel(
        dateopen: DateTime.parse(json["dateopen"]),
        projectVersion: json["projectVersion"],
        costDelivery: json["costDelivery"],
        status: json["status"],
        customerOpen: json["customerOpen"],
        emailLogin: json["emailLogin"],
      );

  Map<String, dynamic> toJson() => {
        "dateopen": dateopen.toIso8601String(),
        "projectVersion": projectVersion,
        "costDelivery": costDelivery,
        "status": status,
        "customerOpen": customerOpen,
        "emailLogin": emailLogin,
      };
}
