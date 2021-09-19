// To parse this JSON data, do
//
//     final promoteListModel = promoteListModelFromJson(jsonString);

import 'dart:convert';

List<AdListModel> promoteListModelFromJson(String str) =>
    List<AdListModel>.from(
        json.decode(str).map((x) => AdListModel.fromJson(x)));

String promoteListModelToJson(List<AdListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AdListModel {
  AdListModel({
    this.name,
    this.status,
    this.url,
    this.id,
  });

  String name;
  String status;
  String url;
  String id;

  factory AdListModel.fromJson(Map<String, dynamic> json) => AdListModel(
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
