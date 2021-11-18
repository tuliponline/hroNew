// To parse this JSON data, do
//
//     final cartModel = cartModelFromJson(jsonString);

import 'dart:convert';

List<CartModel> cartModelFromJson(String str) =>
    List<CartModel>.from(json.decode(str).map((x) => CartModel.fromJson(x)));

String cartModelToJson(List<CartModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CartModel {
  CartModel({
    this.productId,
    this.productName,
    this.pcs,
    this.price,
    this.oriPrice,
    this.comment,
    this.time,
    this.shopId,
  });

  String productId;
  String productName;
  String pcs;
  String price;
  String oriPrice;
  String comment;
  String time;
  String shopId;

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
        productId: json["productId"],
        productName: json["productName"],
        pcs: json["pcs"],
        price: json["price"],
        oriPrice: json["oriPrice"],
        comment: json["comment"],
        time: json["time"],
        shopId: json["shopId"],
      );

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "productName": productName,
        "pcs": pcs,
        "price": price,
        "oriPrice": oriPrice,
        "comment": comment,
        "time": time,
        "shopId": shopId,
      };
}
