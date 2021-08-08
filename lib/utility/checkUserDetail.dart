import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hro/model/UserOneModel.dart';

Future<bool> checkUserDetail(String uid) async {
  bool result = false;
  await FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .get()
      .then((value) {
    var jsonData = jsonEncode(value.data());
    UserOneModel userModel = userOneModelFromJson(jsonData);
    if ((userModel.name?.isEmpty ?? true) ||
        (userModel.email?.isEmpty ?? true) ||
        (userModel.phone?.isEmpty ?? true) ||
        (userModel.location?.isEmpty ?? true)) {
      result = false;
    } else {
      result = true;
    }
  });

  return result;
}
