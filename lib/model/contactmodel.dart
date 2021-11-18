// To parse this JSON data, do
//
//     final contactModel = contactModelFromJson(jsonString);

import 'dart:convert';

ContactModel contactModelFromJson(String str) =>
    ContactModel.fromJson(json.decode(str));

String contactModelToJson(ContactModel data) => json.encode(data.toJson());

class ContactModel {
  ContactModel({
    this.phone,
    this.line,
  });

  String phone;
  String line;

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
        phone: json["phone"],
        line: json["line"],
      );

  Map<String, dynamic> toJson() => {
        "phone": phone,
        "line": line,
      };
}
