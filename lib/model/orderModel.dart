// To parse this JSON data, do
//
//     final orderdetail = orderdetailFromJson(jsonString);

import 'dart:convert';

List<OrderList> orderListFromJson(String str) =>
    List<OrderList>.from(json.decode(str).map((x) => OrderList.fromJson(x)));

String orderListToJson(List<OrderList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrderList {
  OrderList({
    this.finishTime,
    this.amount,
    this.amountOri,
    this.distance,
    this.orderId,
    this.costDelivery,
    this.costDelivery4Rider,
    this.inTime,
    this.driver,
    this.customerId,
    this.comment,
    this.startTime,
    this.location,
    this.shopId,
    this.status,
    this.discount,
    this.orderType,
    this.locationName,
    this.payType,
    this.chatRider,
    this.chatUser,
  });

  String finishTime;
  String amount;
  String amountOri;
  String distance;
  String orderId;
  String costDelivery;
  String costDelivery4Rider;
  String inTime;
  String driver;
  String customerId;
  String comment;
  String startTime;
  String location;
  String shopId;
  String status;
  String discount;
  String orderType;
  String locationName;
  String payType;
  String chatRider;
  String chatUser;

  factory OrderList.fromJson(Map<String, dynamic> json) => OrderList(
        finishTime: json["finishTime"],
        amount: json["amount"],
        amountOri: json["amountOri"],
        distance: json["distance"],
        orderId: json["orderId"],
        costDelivery: json["costDelivery"],
        costDelivery4Rider: json["costDelivery4Rider"],
        inTime: json["inTime"],
        driver: json["driver"],
        customerId: json["customerId"],
        comment: json["comment"],
        startTime: json["startTime"],
        location: json["location"],
        shopId: json["shopId"],
        status: json["status"],
        discount: json["discount"],
        orderType: json["orderType"],
        locationName: json["locationName"],
        payType: json["payType"],
        chatRider: json["chatRider"],
        chatUser: json["chatUser"],
      );

  Map<String, dynamic> toJson() => {
        "finishTime": finishTime,
        "amount": amount,
        "amountOri": amountOri,
        "distance": distance,
        "orderId": orderId,
        "costDelivery": costDelivery,
        "costDelivery4Rider": costDelivery4Rider,
        "inTime": inTime,
        "driver": driver,
        "customerId": customerId,
        "comment": comment,
        "startTime": startTime,
        "location": location,
        "shopId": shopId,
        "status": status,
        "discount": discount,
        "orderType": orderType,
        "locationName": locationName,
        "payType": payType,
        "chatRider": chatRider,
        "chatUser": chatUser,
      };
}

OrderDetail orderDetailFromJson(String str) =>
    OrderDetail.fromJson(json.decode(str));
String orderDetailToJson(OrderDetail data) => json.encode(data.toJson());

class OrderDetail {
  OrderDetail({
    this.finishTime,
    this.amount,
    this.amountOri,
    this.distance,
    this.orderId,
    this.costDelivery,
    this.costDelivery4Rider,
    this.inTime,
    this.driver,
    this.customerId,
    this.comment,
    this.startTime,
    this.location,
    this.shopId,
    this.status,
    this.discount,
    this.orderType,
    this.locationName,
    this.payType,
    this.chatRider,
    this.chatUser,
  });

  String finishTime;
  String amount;
  String amountOri;
  String distance;
  String orderId;
  String costDelivery;
  String costDelivery4Rider;
  String inTime;
  String driver;
  String customerId;
  String comment;
  String startTime;
  String location;
  String shopId;
  String status;
  String discount;
  String orderType;
  String locationName;
  String payType;
  String chatRider;
  String chatUser;

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
        finishTime: json["finishTime"],
        amount: json["amount"],
        amountOri: json["amountOri"],
        distance: json["distance"],
        orderId: json["orderId"],
        costDelivery: json["costDelivery"],
        costDelivery4Rider: json["costDelivery4Rider"],
        inTime: json["inTime"],
        driver: json["driver"],
        customerId: json["customerId"],
        comment: json["comment"],
        startTime: json["startTime"],
        location: json["location"],
        shopId: json["shopId"],
        status: json["status"],
        discount: json["discount"],
        orderType: json["orderType"],
        locationName: json["locationName"],
        payType: json["payType"],
        chatRider: json["chatRider"],
        chatUser: json["chatUser"],
      );

  Map<String, dynamic> toJson() => {
        "finishTime": finishTime,
        "amount": amount,
        "amountOri": amountOri,
        "distance": distance,
        "orderId": orderId,
        "costDelivery": costDelivery,
        "costDelivery4Rider": costDelivery4Rider,
        "inTime": inTime,
        "driver": driver,
        "customerId": customerId,
        "comment": comment,
        "startTime": startTime,
        "location": location,
        "shopId": shopId,
        "status": status,
        "discount": discount,
        "orderType": orderType,
        "locationName": locationName,
        "payType": payType,
        "chatRider": chatRider,
        "chatUser": chatUser,
      };
}

List<OrderProduct> orderProductFromJson(String str) => List<OrderProduct>.from(
    json.decode(str).map((x) => OrderProduct.fromJson(x)));
String orderProductToJson(List<OrderProduct> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrderProduct {
  OrderProduct({
    this.pcs,
    this.productId,
    this.price,
    this.oriPrice,
    this.name,
    this.comment,
    this.time,
  });

  String pcs;
  String productId;
  String price;
  String oriPrice;
  String name;
  String comment;
  String time;

  factory OrderProduct.fromJson(Map<String, dynamic> json) => OrderProduct(
        pcs: json["pcs"],
        productId: json["productId"],
        price: json["price"],
        oriPrice: json["oriPrice"],
        name: json["name"],
        comment: json["comment"],
        time: json["time"],
      );

  Map<String, dynamic> toJson() => {
        "pcs": pcs,
        "productId": productId,
        "price": price,
        "oriPrice": oriPrice,
        "name": name,
        "comment": comment,
        "time": time,
      };
}

MartDetailModel martDetailModelFromJson(String str) =>
    MartDetailModel.fromJson(json.decode(str));

String martDetailModelToJson(MartDetailModel data) =>
    json.encode(data.toJson());

class MartDetailModel {
  MartDetailModel({
    this.name,
    this.location,
    this.distanc,
    this.cost,
    this.id,
  });

  String name;
  String location;
  String distanc;
  String cost;
  String id;

  factory MartDetailModel.fromJson(Map<String, dynamic> json) =>
      MartDetailModel(
        name: json["name"],
        location: json["location"],
        distanc: json["distanc"],
        cost: json["cost"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "location": location,
        "distanc": distanc,
        "cost": cost,
        "id": id,
      };
}

List<MartListDetailModel> martListDetailModelFromJson(String str) =>
    List<MartListDetailModel>.from(
        json.decode(str).map((x) => MartListDetailModel.fromJson(x)));

String martListDetailModelToJson(List<MartListDetailModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MartListDetailModel {
  MartListDetailModel({
    this.name,
    this.location,
    this.distanc,
    this.cost,
    this.id,
  });

  String name;
  String location;
  String distanc;
  String cost;
  String id;

  factory MartListDetailModel.fromJson(Map<String, dynamic> json) =>
      MartListDetailModel(
        name: json["name"],
        location: json["location"],
        distanc: json["distanc"],
        cost: json["cost"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "location": location,
        "distanc": distanc,
        "cost": cost,
        "id": id,
      };
}

MartItemOneModel martItemOneModelFromJson(String str) =>
    MartItemOneModel.fromJson(json.decode(str));

String martItemOneModelToJson(MartItemOneModel data) =>
    json.encode(data.toJson());

class MartItemOneModel {
  MartItemOneModel({
    this.pcs,
    this.itemName,
  });

  String pcs;
  String itemName;

  factory MartItemOneModel.fromJson(Map<String, dynamic> json) =>
      MartItemOneModel(
        pcs: json["pcs"],
        itemName: json["itemName"],
      );

  Map<String, dynamic> toJson() => {
        "pcs": pcs,
        "itemName": itemName,
      };
}

List<MartItemListModel> martItemListModelFromJson(String str) =>
    List<MartItemListModel>.from(
        json.decode(str).map((x) => MartItemListModel.fromJson(x)));

String martItemListModelToJson(List<MartItemListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MartItemListModel {
  MartItemListModel({
    this.pcs,
    this.itemName,
  });

  String pcs;
  String itemName;

  factory MartItemListModel.fromJson(Map<String, dynamic> json) =>
      MartItemListModel(
        pcs: json["pcs"],
        itemName: json["itemName"],
      );

  Map<String, dynamic> toJson() => {
        "pcs": pcs,
        "itemName": itemName,
      };
}
