// To parse this JSON data, do
//
//     final riderHistoryListModel = riderHistoryListModelFromJson(jsonString);

import 'dart:convert';

List<RiderHistoryListModel> riderHistoryListModelFromJson(String str) =>
    List<RiderHistoryListModel>.from(
        json.decode(str).map((x) => RiderHistoryListModel.fromJson(x)));

String riderHistoryListModelToJson(List<RiderHistoryListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RiderHistoryListModel {
  RiderHistoryListModel({
    this.finishTime,
    this.amount,
    this.inTime,
    this.costDelivery,
    this.customerId,
    this.comment,
    this.location,
    this.orderId,
    this.shopId,
    this.distance,
    this.startTime,
    this.status,
    this.driver,
  });

  String finishTime;
  String amount;
  String inTime;
  String costDelivery;
  String customerId;
  dynamic comment;
  String location;
  String orderId;
  String shopId;
  String distance;
  String startTime;
  String status;
  String driver;

  factory RiderHistoryListModel.fromJson(Map<String, dynamic> json) =>
      RiderHistoryListModel(
        finishTime: json["finishTime"],
        amount: json["amount"],
        inTime: json["inTime"],
        costDelivery: json["costDelivery"],
        customerId: json["customerId"],
        comment: json["comment"],
        location: json["location"],
        orderId: json["orderId"],
        shopId: json["shopId"],
        distance: json["distance"],
        startTime: json["startTime"],
        status: json["status"],
        driver: json["driver"],
      );

  Map<String, dynamic> toJson() => {
        "finishTime": finishTime,
        "amount": amount,
        "inTime": inTime,
        "costDelivery": costDelivery,
        "customerId": customerId,
        "comment": comment,
        "location": location,
        "orderId": orderId,
        "shopId": shopId,
        "distance": distance,
        "startTime": startTime,
        "status": status,
        "driver": driver,
      };
}
