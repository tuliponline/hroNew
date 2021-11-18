// To parse this JSON data, do
//
//     final creditAndPointSetupModel = creditAndPointSetupModelFromJson(jsonString);

import 'dart:convert';

CreditAndPointSetupModel creditAndPointSetupModelFromJson(String str) =>
    CreditAndPointSetupModel.fromJson(json.decode(str));

String creditAndPointSetupModelToJson(CreditAndPointSetupModel data) =>
    json.encode(data.toJson());

class CreditAndPointSetupModel {
  CreditAndPointSetupModel({
    this.newRegisterPoint,
    this.creditValue,
    this.newRegisterCredit,
    this.transferMinimum,
    this.vat,
    this.bankAccount,
    this.bankName,
    this.bankUserName,
    this.addCreditStatus,
    this.payCash,
    this.payCredit,
  });

  String newRegisterPoint;
  String creditValue;
  String newRegisterCredit;
  String transferMinimum;
  String vat;
  String bankAccount;
  String bankName;
  String bankUserName;
  String addCreditStatus;
  String payCash;
  String payCredit;

  factory CreditAndPointSetupModel.fromJson(Map<String, dynamic> json) =>
      CreditAndPointSetupModel(
        newRegisterPoint: json["newRegisterPoint"],
        creditValue: json["creditValue"],
        newRegisterCredit: json["newRegisterCredit"],
        transferMinimum: json["transferMinimum"],
        vat: json["vat"],
        bankAccount: json["bankAccount"],
        bankName: json["bankName"],
        bankUserName: json["bankUserName"],
        addCreditStatus: json["addCreditStatus"],
        payCash: json["payCash"],
        payCredit: json["payCredit"],
      );

  Map<String, dynamic> toJson() => {
        "newRegisterPoint": newRegisterPoint,
        "creditValue": creditValue,
        "newRegisterCredit": newRegisterCredit,
        "transferMinimum": transferMinimum,
        "vat": vat,
        "bankAccount": bankAccount,
        "bankName": bankName,
        "bankUserName": bankUserName,
        "addCreditStatus": addCreditStatus,
        "payCash": payCash,
        "payCredit": payCredit,
      };
}
