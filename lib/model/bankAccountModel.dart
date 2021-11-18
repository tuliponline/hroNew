// To parse this JSON data, do
//
//     final bankAccountModel = bankAccountModelFromJson(jsonString);

import 'dart:convert';

BankAccountModel bankAccountModelFromJson(String str) =>
    BankAccountModel.fromJson(json.decode(str));

String bankAccountModelToJson(BankAccountModel data) =>
    json.encode(data.toJson());

class BankAccountModel {
  BankAccountModel({
    this.status,
    this.number,
    this.bank,
    this.name,
  });

  String status;
  String number;
  String bank;
  String name;

  factory BankAccountModel.fromJson(Map<String, dynamic> json) =>
      BankAccountModel(
        status: json["status"],
        number: json["number"],
        bank: json["bank"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "number": number,
        "bank": bank,
        "name": name,
      };
}
