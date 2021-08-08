// To parse this JSON data, do
//
//     final allShopModel = allShopModelFromJson(jsonString);

import 'dart:convert';

List<AllShopModel> allShopModelFromJson(String str) => List<AllShopModel>.from(
    json.decode(str).map((x) => AllShopModel.fromJson(x)));

String allShopModelToJson(List<AllShopModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AllShopModel {
  AllShopModel({
    this.shopPhotoUrl,
    this.shopStatus,
    this.shopUid,
    this.shopType,
    this.shopLocation,
    this.shopPhone,
    this.shopDistanceService,
    this.shopName,
    this.shopTime,
    this.shopAddress,
    this.token,
  });

  String shopPhotoUrl;
  String shopStatus;
  String shopUid;
  String shopType;
  String shopLocation;
  String shopPhone;
  String shopDistanceService;
  String shopName;
  String shopTime;
  String shopAddress;
  String token;

  factory AllShopModel.fromJson(Map<String, dynamic> json) => AllShopModel(
        shopPhotoUrl: json["shop_photo_Url"],
        shopStatus: json["shop_status"],
        shopUid: json["shop_uid"],
        shopType: json["shop_type"],
        shopLocation: json["shop_location"],
        shopPhone: json["shop_phone"],
        shopDistanceService: json["shopDistanceService"],
        shopName: json["shop_name"],
        shopTime: json["shop_time"],
        shopAddress: json["shop_address"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "shop_photo_Url": shopPhotoUrl,
        "shop_status": shopStatus,
        "shop_uid": shopUid,
        "shop_type": shopType,
        "shop_location": shopLocation,
        "shop_phone": shopPhone,
        "shopDistanceService": shopDistanceService,
        "shop_name": shopName,
        "shop_time": shopTime,
        "shop_address": shopAddress,
        "token": token,
      };
}
