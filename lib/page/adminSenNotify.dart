import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/UserOneModel.dart';

import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AdminSendNotifyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AdminSendNotifyState();
  }
}

class AdminSendNotifyState extends State<AdminSendNotifyPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  TextEditingController textTitle = TextEditingController();
  TextEditingController textBody = TextEditingController();

  List menu = [
    {"text": 'ส่งให้ลูกค้า', "index": 0},
    {"text": 'ส่งให้rider', "index": 1},
    {"text": 'ส่งให้ร้านค้า', "index": 3}
  ];

  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  initState() {
    super.initState();
    // flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    // var android = new AndroidInitializationSettings('@mipmap/launcher_icon');
    // var iOS = new IOSInitializationSettings();
    // var initSetttings = InitializationSettings(iOS: iOS, android: android);
    // flutterLocalNotificationsPlugin.initialize(initSetttings,
    //     onSelectNotification: _SelectNotification);
  }

  // Future _SelectNotification(String payload) {
  //   debugPrint("payload : $payload");
  //   showDialog(
  //     context: context,
  //     builder: (_) =>
  //     new AlertDialog(
  //       title: Style().textBlackSize("header Popup222", 14),
  //       content: Style().textFlexibleBackSize(
  //           payload, 5, 14),
  //       actions: [TextButton(onPressed: () {
  //         Navigator.pop(context, true);
  //       }, child: Style().textSizeColor('ดูOrder', 14, Colors.blueAccent))
  //       ],
  //     ),
  //   );
  // }

  // _showNotification() async {
  //   var android = new AndroidNotificationDetails(
  //       'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
  //       priority: Priority.high, importance: Importance.max);
  //   var iOS = new IOSNotificationDetails();
  //   var platform = new NotificationDetails(android: android, iOS: iOS);
  //   await flutterLocalNotificationsPlugin.show(
  //       0, 'New Video is out', 'Flutter Local Notification', platform,
  //       payload: 'Nitish Kumar Singh is part time Youtuber');
  // }

  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Style().darkColor),
              backgroundColor: Colors.white,
              bottomOpacity: 0.0,
              elevation: 0.0,
              title: Style().textDarkAppbar("ส่ง Notification"),
            ),
            body: Container(
              child: Column(
                children: [
                  TextButton(onPressed: () {}, child: Text("textNoti")),
                  Container(
                    child: TextField(
                      style: TextStyle(
                          fontFamily: "prompt",
                          fontSize: 16,
                          color: Style().textColor),
                      decoration: InputDecoration(
                          hintText: 'หัวข้อ',
                          hintStyle: TextStyle(
                              fontFamily: "prompt",
                              fontSize: 14,
                              color: Colors.grey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Color.fromRGBO(243, 244, 247, 1)),
                      controller: textTitle,
                    ),
                  ),
                  Container(
                    child: TextField(
                      style: TextStyle(
                          fontFamily: "prompt",
                          fontSize: 16,
                          color: Style().textColor),
                      decoration: InputDecoration(
                          hintText: 'ข้อความ',
                          hintStyle: TextStyle(
                              fontFamily: "prompt",
                              fontSize: 14,
                              color: Colors.grey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Color.fromRGBO(243, 244, 247, 1)),
                      controller: textBody,
                    ),
                  ),
                  StaggeredGridView.countBuilder(
                      shrinkWrap: true,
                      primary: false,
                      crossAxisCount: menu.length,
                      staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                      padding: EdgeInsets.only(top: 0),
                      itemCount: menu.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () async {
                            if (textTitle != null && textBody.text != null) {
                              if (textTitle.text.length > 0 &&
                                  textBody.text.length > 0) {
                                var result = await Dialogs().confirm(context,
                                    "ส่งNotify", "ยืนยันการส่ง Notify");
                                if (result != null && result == true) {
                                  if (index == 0) {
                                    _sendUser(context.read<AppDataModel>());
                                  } else if (index == 1) {
                                    _sendRider(context.read<AppDataModel>());
                                  } else if (index == 2) {
                                    _sendShop(context.read<AppDataModel>());
                                  }
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: "ข้อมูลไม่ครบ",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: "ข้อมูลไม่ครบ",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            }
                          },
                          child: Container(
                            width: 60,
                            margin: EdgeInsets.only(left: 5, right: 5, top: 5),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(28),
                                  blurRadius: 5,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Style().textSizeColor(
                                    menu[index]['text'], 12, Style().darkColor),
                              ],
                            ),
                          ),
                        );
                      }),
                ],
              ),
            )));
  }

  _sendUser(AppDataModel appDataModel) async {
    int i = 0;
    await db.collection("users").get().then((value) async {
      value.docs.forEach((element) async {
        var jsonData = (element.data());
        UserOneModel userModel = userOneModelFromJson(jsonEncode(jsonData));
        if (userModel.token != null) {
          await sendNotify(
              appDataModel, userModel.token, textTitle.text, textBody.text);
          i++;
        }
      });
    });
    await Dialogs().information(
      context,
      Text("ส่งสำเร็จ"),
      Text("ส่งจำนวน " + i.toString()),
    );
  }

  _sendRider(AppDataModel appDataModel) async {
    int i = 0;
    await db.collection("drivers").get().then((value) async {
      value.docs.forEach((element) async {
        var jsonData = (element.data());
        UserOneModel userModel = userOneModelFromJson(jsonEncode(jsonData));
        if (userModel.token != null) {
          await sendNotify(
              appDataModel, userModel.token, textTitle.text, textBody.text);
          i++;
        }
      });
    });
    await Dialogs().information(context, Text("ส่งสำเร็จ"), Text("ส่งสำเร็จ"));
  }

  _sendShop(AppDataModel appDataModel) async {
    int i = 0;
    await db.collection("shops").get().then((value) async {
      value.docs.forEach((element) async {
        var jsonData = (element.data());
        UserOneModel userModel = userOneModelFromJson(jsonEncode(jsonData));
        if (userModel.token != null) {
          await sendNotify(
              appDataModel, userModel.token, textTitle.text, textBody.text);
          i++;
        }
      });
    });
    await Dialogs().information(
      context,
      Text("ส่งสำเร็จ"),
      Text("ส่งจำนวน " + i.toString()),
    );
  }

  sendNotify(AppDataModel appDataModel, String token, String title,
      String body) async {
    print("notiserver = " + appDataModel.notifyServer);
    http.post(
      Uri.parse(appDataModel.notifyServer),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
        'title': title,
        'body': body,
        "sound": "alert.caf"
      }),
    );
  }

// Future<void> _showNotification2() async {
//   print("Start Notify");
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//   AndroidNotificationDetails(
//       'your channel id', 'your channel name', 'your channel description',
//       importance: Importance.max,
//       priority: Priority.high,
//       ticker: 'ticker');
//   const NotificationDetails platformChannelSpecifics =
//   NotificationDetails(android: androidPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//       0, 'plain title', 'plain body', platformChannelSpecifics,
//       payload: 'item x');
// }
}
