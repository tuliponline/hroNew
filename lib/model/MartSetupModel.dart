// To parse this JSON data, do
//
//     final martSetupModel = martSetupModelFromJson(jsonString);

import 'dart:convert';

MartSetupModel martSetupModelFromJson(String str) =>
    MartSetupModel.fromJson(json.decode(str));

String martSetupModelToJson(MartSetupModel data) => json.encode(data.toJson());

class MartSetupModel {
  MartSetupModel({
    this.maxPcs,
    this.shareForApp,
    this.costPerPcs,
    this.status,
    this.costDeliveryStart,
    this.costPerKm,
    this.costPerShop,
    this.distancsMax,
    this.distancsStart,
  });

  String maxPcs;
  String shareForApp;
  String costPerPcs;
  String status;
  String costDeliveryStart;
  String costPerKm;
  String costPerShop;
  String distancsMax;
  String distancsStart;

  factory MartSetupModel.fromJson(Map<String, dynamic> json) => MartSetupModel(
        maxPcs: json["maxPcs"],
        shareForApp: json["shareForApp"],
        costPerPcs: json["costPerPcs"],
        status: json["status"],
        costDeliveryStart: json["costDeliveryStart"],
        costPerKm: json["costPerKm"],
        costPerShop: json["costPerShop"],
        distancsMax: json["distancsMax"],
        distancsStart: json["distancsStart"],
      );

  Map<String, dynamic> toJson() => {
        "maxPcs": maxPcs,
        "shareForApp": shareForApp,
        "costPerPcs": costPerPcs,
        "status": status,
        "costDeliveryStart": costDeliveryStart,
        "costPerKm": costPerKm,
        "costPerShop": costPerShop,
        "distancsMax": distancsMax,
        "distancsStart": distancsStart,
      };
}
