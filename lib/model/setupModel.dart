// To parse this JSON data, do
//
//     final productSetupModel = productSetupModelFromJson(jsonString);

import 'dart:convert';

ProductSetupModel productSetupModelFromJson(String str) =>
    ProductSetupModel.fromJson(json.decode(str));

String productSetupModelToJson(ProductSetupModel data) =>
    json.encode(data.toJson());

class ProductSetupModel {
  ProductSetupModel({
    this.gp,
    this.shareForApp,
  });

  String gp;
  String shareForApp;

  factory ProductSetupModel.fromJson(Map<String, dynamic> json) =>
      ProductSetupModel(
        gp: json["gp"],
        shareForApp: json["shareForApp"],
      );

  Map<String, dynamic> toJson() => {
        "gp": gp,
        "shareForApp": shareForApp,
      };
}

AppSetupModel appSetupModelFromJson(String str) =>
    AppSetupModel.fromJson(json.decode(str));

String appSetupModelToJson(AppSetupModel data) => json.encode(data.toJson());

class AppSetupModel {
  AppSetupModel({
    this.status,
  });

  bool status;

  factory AppSetupModel.fromJson(Map<String, dynamic> json) => AppSetupModel(
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
      };
}
