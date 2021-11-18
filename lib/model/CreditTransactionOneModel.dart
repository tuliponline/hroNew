// To parse this JSON data, do
//
//     final creditTransactionOneModel = creditTransactionOneModelFromJson(jsonString);

import 'dart:convert';

CreditTransactionOneModel creditTransactionOneModelFromJson(String str) =>
    CreditTransactionOneModel.fromJson(json.decode(str));

String creditTransactionOneModelToJson(CreditTransactionOneModel data) =>
    json.encode(data.toJson());

class CreditTransactionOneModel {
  CreditTransactionOneModel({
    this.date,
    this.comment,
    this.from,
    this.id,
    this.to,
    this.cmd,
    this.text,
    this.type,
    this.value,
    this.userId,
  });

  String date;
  String comment;
  String from;
  String id;
  String to;
  String cmd;
  String text;
  String type;
  String value;
  String userId;

  factory CreditTransactionOneModel.fromJson(Map<String, dynamic> json) =>
      CreditTransactionOneModel(
        date: json["date"],
        comment: json["comment"],
        from: json["from"],
        id: json["id"],
        to: json["to"],
        cmd: json["cmd"],
        text: json["text"],
        type: json["type"],
        value: json["value"],
        userId: json["userId"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "comment": comment,
        "from": from,
        "id": id,
        "to": to,
        "cmd": cmd,
        "text": text,
        "type": type,
        "value": value,
        "userId": userId,
      };
}
