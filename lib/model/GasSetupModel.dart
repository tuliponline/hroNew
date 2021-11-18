// To parse this JSON data, do
//
//     final gasSetupModel = gasSetupModelFromJson(jsonString);

import 'dart:convert';

GasSetupModel gasSetupModelFromJson(String str) =>
    GasSetupModel.fromJson(json.decode(str));

String gasSetupModelToJson(GasSetupModel data) => json.encode(data.toJson());

class GasSetupModel {
  GasSetupModel({
    this.gasLocation,
    this.shareForApp,
    this.maxDistancs,
    this.status,
    this.startDistancs,
    this.costServiceBigStart,
    this.costPerKm,
    this.costServiceSmallStartl,
  });

  String gasLocation;
  String shareForApp;
  String maxDistancs;
  String status;
  String startDistancs;
  String costServiceBigStart;
  String costPerKm;
  String costServiceSmallStartl;

  factory GasSetupModel.fromJson(Map<String, dynamic> json) => GasSetupModel(
        gasLocation: json["gasLocation"],
        shareForApp: json["shareForApp"],
        maxDistancs: json["maxDistancs"],
        status: json["status"],
        startDistancs: json["startDistancs"],
        costServiceBigStart: json["costServiceBigStart"],
        costPerKm: json["costPerKm"],
        costServiceSmallStartl: json["costServiceSmallStartl"],
      );

  Map<String, dynamic> toJson() => {
        "gasLocation": gasLocation,
        "shareForApp": shareForApp,
        "maxDistancs": maxDistancs,
        "status": status,
        "startDistancs": startDistancs,
        "costServiceBigStart": costServiceBigStart,
        "costPerKm": costPerKm,
        "costServiceSmallStartl": costServiceSmallStartl,
      };
}
