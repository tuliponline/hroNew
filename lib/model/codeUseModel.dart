// To parse this JSON data, do
//
//     final codeUseListModel = codeUseListModelFromJson(jsonString);

import 'dart:convert';

List<CodeUseListModel> codeUseListModelFromJson(String str) =>
    List<CodeUseListModel>.from(
        json.decode(str).map((x) => CodeUseListModel.fromJson(x)));

String codeUseListModelToJson(List<CodeUseListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CodeUseListModel {
  CodeUseListModel({
    this.code,
    this.orderId,
    this.id,
    this.time,
    this.userId,
    this.disCountValue,
  });

  String code;
  String orderId;
  String id;
  String time;
  String userId;
  String disCountValue;

  factory CodeUseListModel.fromJson(Map<String, dynamic> json) =>
      CodeUseListModel(
        code: json["code"],
        orderId: json["orderId"],
        id: json["id"],
        time: json["time"],
        userId: json["userId"],
        disCountValue: json["disCountValue"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "orderId": orderId,
        "id": id,
        "time": time,
        "userId": userId,
        "disCountValue": disCountValue,
      };
}

CodeUseOneModel codeUseOneModelFromJson(String str) =>
    CodeUseOneModel.fromJson(json.decode(str));

String codeUseOneModelToJson(CodeUseOneModel data) =>
    json.encode(data.toJson());

class CodeUseOneModel {
  CodeUseOneModel({
    this.code,
    this.orderId,
    this.id,
    this.time,
    this.userId,
    this.disCountValue,
  });

  String code;
  String orderId;
  String id;
  String time;
  String userId;
  String disCountValue;

  factory CodeUseOneModel.fromJson(Map<String, dynamic> json) =>
      CodeUseOneModel(
        code: json["code"],
        orderId: json["orderId"],
        id: json["id"],
        time: json["time"],
        userId: json["userId"],
        disCountValue: json["disCountValue"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "orderId": orderId,
        "id": id,
        "time": time,
        "userId": userId,
        "disCountValue": disCountValue,
      };
}
