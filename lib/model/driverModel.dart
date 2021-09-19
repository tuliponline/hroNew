// To parse this JSON data, do
//
//     final driversListModel = driversListModelFromJson(jsonString);

import 'dart:convert';

List<DriversListModel> driversListModelFromJson(String str) =>
    List<DriversListModel>.from(
        json.decode(str).map((x) => DriversListModel.fromJson(x)));

String driversListModelToJson(List<DriversListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DriversListModel {
  DriversListModel({
    this.qrcode,
    this.driverName,
    this.driverStatus,
    this.driverLocation,
    this.driverPhone,
    this.driverAddress,
    this.driverId,
    this.onlineTime,
    this.token,
    this.driverPhotoUrl,
  });

  String qrcode;
  String driverName;
  String driverStatus;
  String driverLocation;
  String driverPhone;
  String driverAddress;
  String driverId;
  String onlineTime;
  String token;
  String driverPhotoUrl;

  factory DriversListModel.fromJson(Map<String, dynamic> json) =>
      DriversListModel(
        qrcode: json["qrcode"],
        driverName: json["driverName"],
        driverStatus: json["driverStatus"],
        driverLocation: json["driverLocation"],
        driverPhone: json["driverPhone"],
        driverAddress: json["driverAddress"],
        driverId: json["driverId"],
        onlineTime: json["onlineTime"],
        token: json["token"],
        driverPhotoUrl: json["driverPhotoUrl"],
      );

  Map<String, dynamic> toJson() => {
        "qrcode": qrcode,
        "driverName": driverName,
        "driverStatus": driverStatus,
        "driverLocation": driverLocation,
        "driverPhone": driverPhone,
        "driverAddress": driverAddress,
        "driverId": driverId,
        "onlineTime": onlineTime,
        "token": token,
        "driverPhotoUrl": driverPhotoUrl,
      };
}

// To parse this JSON data, do
//
//     final driversModel = driversModelFromJson(jsonString);

// To parse this JSON data, do
//
//     final driversModel = driversModelFromJson(jsonString);

DriversModel driversModelFromJson(String str) =>
    DriversModel.fromJson(json.decode(str));

String driversModelToJson(DriversModel data) => json.encode(data.toJson());

class DriversModel {
  DriversModel({
    this.qrcode,
    this.driverName,
    this.driverStatus,
    this.driverLocation,
    this.driverPhone,
    this.driverAddress,
    this.driverId,
    this.onlineTime,
    this.token,
    this.driverPhotoUrl,
  });

  String qrcode;
  String driverName;
  String driverStatus;
  String driverLocation;
  String driverPhone;
  String driverAddress;
  String driverId;
  String onlineTime;
  String token;
  String driverPhotoUrl;

  factory DriversModel.fromJson(Map<String, dynamic> json) => DriversModel(
        qrcode: json["qrcode"],
        driverName: json["driverName"],
        driverStatus: json["driverStatus"],
        driverLocation: json["driverLocation"],
        driverPhone: json["driverPhone"],
        driverAddress: json["driverAddress"],
        driverId: json["driverId"],
        onlineTime: json["onlineTime"],
        token: json["token"],
        driverPhotoUrl: json["driverPhotoUrl"],
      );

  Map<String, dynamic> toJson() => {
        "qrcode": qrcode,
        "driverName": driverName,
        "driverStatus": driverStatus,
        "driverLocation": driverLocation,
        "driverPhone": driverPhone,
        "driverAddress": driverAddress,
        "driverId": driverId,
        "onlineTime": onlineTime,
        "token": token,
        "driverPhotoUrl": driverPhotoUrl,
      };
}
