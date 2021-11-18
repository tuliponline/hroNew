// To parse this JSON data, do
//
//     final codeListModel = codeListModelFromJson(jsonString);

import 'dart:convert';

List<CodeListModel> codeListModelFromJson(String str) =>
    List<CodeListModel>.from(
        json.decode(str).map((x) => CodeListModel.fromJson(x)));

String codeListModelToJson(List<CodeListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CodeListModel {
  CodeListModel({
    this.id,
    this.code,
    this.perUser,
    this.discount,
    this.exp,
    this.stock,
    this.type,
    this.name,
    this.buyValueStart,
    this.valueLimit,
    this.useLimit,
    this.status,
  });

  String id;
  String code;
  String perUser;
  String discount;
  String exp;
  String stock;
  String type;
  String name;
  String buyValueStart;
  String valueLimit;
  String useLimit;
  String status;

  factory CodeListModel.fromJson(Map<String, dynamic> json) => CodeListModel(
        id: json["id"],
        code: json["code"],
        perUser: json["perUser"],
        discount: json["discount"],
        exp: json["exp"],
        stock: json["stock"],
        type: json["type"],
        name: json["name"],
        buyValueStart: json["buyValueStart"],
        valueLimit: json["valueLimit"],
        useLimit: json["useLimit"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "perUser": perUser,
        "discount": discount,
        "exp": exp,
        "stock": stock,
        "type": type,
        "name": name,
        "buyValueStart": buyValueStart,
        "valueLimit": valueLimit,
        "useLimit": useLimit,
        "status": status,
      };
}

CodeOneModel codeOneModelFromJson(String str) =>
    CodeOneModel.fromJson(json.decode(str));

String codeOneModelToJson(CodeOneModel data) => json.encode(data.toJson());

class CodeOneModel {
  CodeOneModel({
    this.id,
    this.code,
    this.perUser,
    this.discount,
    this.exp,
    this.stock,
    this.type,
    this.name,
    this.buyValueStart,
    this.valueLimit,
    this.useLimit,
    this.status,
  });

  String id;
  String code;
  String perUser;
  String discount;
  String exp;
  String stock;
  String type;
  String name;
  String buyValueStart;
  String valueLimit;
  String useLimit;
  String status;

  factory CodeOneModel.fromJson(Map<String, dynamic> json) => CodeOneModel(
        id: json["id"],
        code: json["code"],
        perUser: json["perUser"],
        discount: json["discount"],
        exp: json["exp"],
        stock: json["stock"],
        type: json["type"],
        name: json["name"],
        buyValueStart: json["buyValueStart"],
        valueLimit: json["valueLimit"],
        useLimit: json["useLimit"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "perUser": perUser,
        "discount": discount,
        "exp": exp,
        "stock": stock,
        "type": type,
        "name": name,
        "buyValueStart": buyValueStart,
        "valueLimit": valueLimit,
        "useLimit": useLimit,
        "status": status,
      };
}
