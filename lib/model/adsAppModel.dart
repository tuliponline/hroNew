// To parse this JSON data, do
//
//     final promoteListModel = promoteListModelFromJson(jsonString);

import 'dart:convert';

List<AdsAppListModel> adsAppListModelFromJson(String str) =>
    List<AdsAppListModel>.from(
        json.decode(str).map((x) => AdsAppListModel.fromJson(x)));

String adsAppListModelToJson(List<AdsAppListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AdsAppListModel {
  AdsAppListModel({
    this.name,
    this.status,
    this.url,
    this.id,
  });

  String name;
  String status;
  String url;
  String id;

  factory AdsAppListModel.fromJson(Map<String, dynamic> json) =>
      AdsAppListModel(
        name: json["name"],
        status: json["status"],
        url: json["url"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "status": status,
        "url": url,
        "id": id,
      };
}
