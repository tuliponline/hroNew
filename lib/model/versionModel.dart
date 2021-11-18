// To parse this JSON data, do
//
//     final versionOneModel = versionOneModelFromJson(jsonString);

import 'dart:convert';

VersionOneModel versionOneModelFromJson(String str) =>
    VersionOneModel.fromJson(json.decode(str));

String versionOneModelToJson(VersionOneModel data) =>
    json.encode(data.toJson());

class VersionOneModel {
  VersionOneModel({
    this.androidLink,
    this.versionNow,
    this.iosLink,
  });

  String androidLink;
  String versionNow;
  String iosLink;

  factory VersionOneModel.fromJson(Map<String, dynamic> json) =>
      VersionOneModel(
        androidLink: json["androidLink"],
        versionNow: json["versionNow"],
        iosLink: json["iosLink"],
      );

  Map<String, dynamic> toJson() => {
        "androidLink": androidLink,
        "versionNow": versionNow,
        "iosLink": iosLink,
      };
}
