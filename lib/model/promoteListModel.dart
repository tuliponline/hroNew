// To parse this JSON data, do
//
//     final promoteListModel = promoteListModelFromJson(jsonString);

import 'dart:convert';

List<PromoteListModel> promoteListModelFromJson(String str) =>
    List<PromoteListModel>.from(
        json.decode(str).map((x) => PromoteListModel.fromJson(x)));

String promoteListModelToJson(List<PromoteListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PromoteListModel {
  PromoteListModel({
    this.name,
    this.status,
    this.url,
    this.id,
    this.link,
    this.shopId,
    this.shopType,
  });

  String name;
  String status;
  String url;
  String id;
  String link;
  String shopId;
  String shopType;

  factory PromoteListModel.fromJson(Map<String, dynamic> json) =>
      PromoteListModel(
        name: json["name"],
        status: json["status"],
        url: json["url"],
        id: json["id"],
        link: json["link"],
        shopId: json["shopId"],
        shopType: json["shopType"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "status": status,
        "url": url,
        "id": id,
        "link": link,
        "shopId": shopId,
        "shopType": shopType,
      };
}

PromoteOneModel promoteOneModelFromJson(String str) =>
    PromoteOneModel.fromJson(json.decode(str));

String promoteOneModelToJson(PromoteOneModel data) =>
    json.encode(data.toJson());

class PromoteOneModel {
  PromoteOneModel({
    this.name,
    this.status,
    this.url,
    this.id,
    this.link,
    this.shopId,
    this.shopType,
  });

  String name;
  String status;
  String url;
  String id;
  String link;
  String shopId;
  String shopType;

  factory PromoteOneModel.fromJson(Map<String, dynamic> json) =>
      PromoteOneModel(
        name: json["name"],
        status: json["status"],
        url: json["url"],
        id: json["id"],
        link: json["link"],
        shopId: json["shopId"],
        shopType: json["shopType"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "status": status,
        "url": url,
        "id": id,
        "link": link,
        "shopId": shopId,
        "shopType": shopType,
      };
}
