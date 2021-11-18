// To parse this JSON data, do
//
//     final creditTicketModel = creditTicketModelFromJson(jsonString);

import 'dart:convert';

CreditTicketModel creditTicketModelFromJson(String str) =>
    CreditTicketModel.fromJson(json.decode(str));

String creditTicketModelToJson(CreditTicketModel data) =>
    json.encode(data.toJson());

class CreditTicketModel {
  CreditTicketModel({
    this.date,
    this.uid,
    this.photoUrl,
    this.comfirmBy,
    this.comment,
    this.id,
    this.status,
    this.cmd,
    this.value,
    this.bankAccount,
    this.bankUserName,
    this.bankName,
    this.dateBank,
    this.timeBank,
    this.befor,
    this.after,
  });

  String date;
  String uid;
  String photoUrl;
  String comfirmBy;
  String comment;
  String id;
  String status;
  String cmd;
  String value;
  String bankAccount;
  String bankUserName;
  String bankName;
  String dateBank;
  String timeBank;
  String befor;
  String after;

  factory CreditTicketModel.fromJson(Map<String, dynamic> json) =>
      CreditTicketModel(
        date: json["date"],
        uid: json["uid"],
        photoUrl: json["photoUrl"],
        comfirmBy: json["comfirmBy"],
        comment: json["comment"],
        id: json["id"],
        status: json["status"],
        cmd: json["cmd"],
        value: json["value"],
        bankAccount: json["bankAccount"],
        bankUserName: json["bankUserName"],
        bankName: json["bankName"],
        dateBank: json["dateBank"],
        timeBank: json["timeBank"],
        befor: json["befor"],
        after: json["after"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "uid": uid,
        "photoUrl": photoUrl,
        "comfirmBy": comfirmBy,
        "comment": comment,
        "id": id,
        "status": status,
        "cmd": cmd,
        "value": value,
        "bankAccount": bankAccount,
        "bankUserName": bankUserName,
        "bankName": bankName,
        "dateBank": dateBank,
        "timeBank": timeBank,
        "befor": befor,
        "after": after,
      };
}
