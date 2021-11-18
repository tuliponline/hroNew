import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hro/model/versionModel.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<String> checkAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String appVersion;

  String app = packageInfo.version;
  print('ProjectVersion = $app');
  appVersion = app.toString();
  return appVersion;
}

Future<String> checkAppVersionOnServer() async {
  var db = FirebaseFirestore.instance;
  String appVersionNow;
  await db.collection("version").doc("001").get().then((value) {
    VersionOneModel versionOneModel =
        versionOneModelFromJson(jsonEncode(value.data()));
    appVersionNow = versionOneModel.versionNow;
  });
  return appVersionNow;
}

Future<String> checkAndroidLink() async {
  var db = FirebaseFirestore.instance;
  String android;
  await db.collection("version").doc("001").get().then((value) {
    VersionOneModel versionOneModel =
        versionOneModelFromJson(jsonEncode(value.data()));
    android = versionOneModel.androidLink;
  });
  return android;
}

Future<String> checkIosLink() async {
  var db = FirebaseFirestore.instance;
  String ios;
  await db.collection("version").doc("001").get().then((value) {
    VersionOneModel versionOneModel =
        versionOneModelFromJson(jsonEncode(value.data()));
    ios = versionOneModel.iosLink;
  });
  return ios;
}
