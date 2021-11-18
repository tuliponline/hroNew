import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hro/utility/addErrorLog.dart';

Future<bool> dbAddData(
    String comment, collection, doc, Map<String, dynamic> data) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool _status = false;
  await db
      .collection(collection)
      .doc(doc)
      .set(data)
      .then((value, {merge: true}) {
    _status = true;
    print("$comment OK");
  }).catchError((onError) {
    _status = false;
    addErrorLog("$comment $onError");
    print("$comment $onError");
  });
  return _status;
}

Future<bool> dbUpdate(
    String comment, collection, doc, Map<String, dynamic> data) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool _status = false;
  await db.collection(collection).doc(doc).update(data).then((value) {
    _status = true;
    print("$comment OK");
  }).catchError((onError) {
    _status = false;
    addErrorLog("$comment $onError");
    print("$comment $onError");
  });
  return _status;
}

Future<bool> dbDeleteData(String comment, collection, doc) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool _status = false;
  await db.collection(collection).doc(doc).delete().then((value) {
    _status = true;
    print("$comment OK");
  }).catchError((onError) {
    _status = false;
    addErrorLog("$comment $onError");
    print("$comment $onError");
  });
  return _status;
}

Future<List<dynamic>> dbGetDataOne(String comment, collection, doc) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool _status = false;
  var data;
  await db.collection(collection).doc(doc).get().then((value) {
    if (value.data() != null) {
      _status = true;
      data = jsonEncode(value.data());
      print("$comment OK");
    } else {
      _status = false;
      print("$comment notHaveData");
    }
  }).catchError((onError) {
    _status = false;
    data = null;
    addErrorLog("$comment $onError");
    print("$comment $onError");
  });
  return [_status, data];
}

Future<List<dynamic>> dbGetDataAll(String comment, collection) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool _status = false;
  var data;
  await db.collection(collection).get().then((value) {
    _status = true;
    data = value;
    print("$comment OK");
  }).catchError((onError) {
    _status = false;
    data = null;
    addErrorLog("$comment $onError");
    print("$comment $onError");
  });
  return [_status, data];
}
