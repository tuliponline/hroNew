import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/UserListMudel.dart';
import 'package:hro/model/UserOneModel.dart';
import 'package:hro/model/allShopModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/page/showHomePage.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/addLog.dart';
import 'package:hro/utility/getTimeNow.dart';
import 'package:hro/utility/notifySend.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class RiderPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RiderState();
  }
}

class RiderState extends State<RiderPage> {
  Dialogs dialogs = Dialogs();
  bool driverStatus = false;
  String timeNow;
  DriversModel driversModel;
  bool getDriverData = false;
  List<OrderList> orderList;
  UserOneModel userOneModel;

  List<OrderList> orderWaiteList;

  bool inWork = false;

  FirebaseFirestore db = FirebaseFirestore.instance;

  _setData(AppDataModel appDataModel) async {
    userOneModel = appDataModel.userOneModel;

    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(userOneModel.uid)
        .update({'token': appDataModel.token});
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(userOneModel.uid)
        .get()
        .then((value) async {
      print("driverData = " + jsonEncode(value.data()));
      driversModel = driversModelFromJson(jsonEncode(value.data()));
      appDataModel.driverData = driversModel;
      if (driversModel.driverStatus == "1") {
        inWork = false;
      } else {
        inWork = true;
      }
      print('drivers Status =  ' + driversModel.driverStatus);
      print('inwork = ' + inWork.toString());

      print('location ' + driversModel.driverStatus);
      await _getOrders(context.read<AppDataModel>());

      (driversModel.driverStatus != '0')
          ? driverStatus = true
          : driverStatus = false;
      setState(() {
        // print('status=' + driverStatus.toString());
        getDriverData = true;
      });
    });
  }

  _getOrders(AppDataModel appDataModel) async {
    await db.collection("drivers").get().then((value) {
      var jsonData = setList2Json(value);
      appDataModel.allRiderData = driversListModelFromJson(jsonData);
    });
    await db.collection("users").get().then((value) {
      var jsonData = setList2Json(value);
      appDataModel.alluserData = userListModelFromJson(jsonData);
    });

    await db.collection("shops").get().then((value) {
      var jsonData = setList2Json(value);
      appDataModel.allShopData = allShopModelFromJson(jsonData);
    });
    await db
        .collection('orders')
        .where('driver', isEqualTo: driversModel.driverId)
        .orderBy("orderId", descending: true)
        .limit(50)
        .get()
        .then((value) async {
      print('valueType=' + value.runtimeType.toString());

      List<DocumentSnapshot> templist;
      List list = [];
      templist = value.docs;
      list = templist.map((DocumentSnapshot docSnapshot) {
        return docSnapshot.data();
      }).toList();
      print('ListType=' + list.runtimeType.toString());

      var jsonData = jsonEncode(list);
      print('jsonDataType=' + jsonData.runtimeType.toString());
      print('OrdersList' + jsonData.toString());
      orderList = orderListFromJson(jsonData);
    });

    await db
        .collection('orders')
        .where('status', isEqualTo: "1")
        .orderBy("orderId", descending: true)
        .get()
        .then((valueWaite) async {
      var jsonData = await setList2Json(valueWaite);
      orderWaiteList = orderListFromJson(jsonData);
      print("orderWait = " + orderWaiteList.length.toString());
    });
  }

  _Notififation() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        setState(() {
          getDriverData = false;
        });
      }
    });
  }

  void initState() {
    super.initState();
    _Notififation();
  }

  Widget build(BuildContext context) {
    if (getDriverData == false) _setData(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              backgroundColor: Color.fromRGBO(18, 22, 23, 1),
              appBar: (driversModel == null)
                  ? null
                  : AppBar(
                      iconTheme: IconThemeData(color: Style().darkColor),
                      backgroundColor: Colors.white,
                      bottomOpacity: 0.0,
                      elevation: 0.0,
                      title:
                          Style().textSizeColor('Rider', 18, Style().darkColor),
                      actions: [
                        IconButton(
                            icon: Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 30,
                            ),
                            onPressed: () async {
                              Navigator.pushNamed(
                                  context, '/riderHistory-Page');
                            }),
                        IconButton(
                            icon: Icon(
                              FontAwesomeIcons.sync,
                              color: Style().darkColor,
                              size: 20,
                            ),
                            onPressed: () async {
                              await _setData(context.read<AppDataModel>());
                            }),
                        Container(
                          child: Container(
                            margin: EdgeInsets.only(right: 5),
                            padding: EdgeInsets.all(1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/editRider-Page',
                                        arguments: 'OLD');
                                  },
                                  child: Style().textSizeColor(
                                      'ข้อมูล Rider', 12, Colors.white),
                                  style: ElevatedButton.styleFrom(
                                      primary: Style().darkColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5))),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
              body: Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: (driversModel == null)
                      ? Style().loading()
                      : ListView(
                          children: [
                            Column(
                              // mainAxisAlignment: MainAxisAlignment.center,noti
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 10),
                                  child: buildShopMenu(
                                      context.read<AppDataModel>()),
                                ),
                                Container(
                                  child: SingleChildScrollView(
                                    child: (orderWaiteList.length == null ||
                                            inWork == true)
                                        ? (appDataModel.loginLevel == "3")
                                            ? buildOrderWaite(
                                                context.read<AppDataModel>())
                                            : Container()
                                        : buildOrderWaite(
                                            context.read<AppDataModel>()),
                                  ),
                                ),
                                Container(
                                  child: SingleChildScrollView(
                                    child: (orderList.length == 0)
                                        ? Container(
                                            child: Center(
                                              child: Style().textBlackSize(
                                                  "ไม่มีคิวงาน", 16),
                                            ),
                                          )
                                        : buildOrderList(
                                            context.read<AppDataModel>()),
                                  ),
                                )
                                //buildPopularProduct(),
                                //buildPopularShop((context.read<AppDataModel>()))
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ));
  }

  Row buildShopMenu(AppDataModel appDataModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        (driverStatus == true)
            ? Expanded(
                child: ListTile(
                  title: (driversModel.driverStatus == '1')
                      ? Row(
                          children: [
                            Style().textSizeColor('Online ', 16, Colors.green),
                          ],
                        )
                      : (driversModel.driverStatus == '3')
                          ? Style()
                              .textSizeColor("รอตรวจสอบ", 16, Colors.orange)
                          : (driversModel.driverStatus == '4')
                              ? Style()
                                  .textSizeColor("ถูกระงับ ", 16, Colors.red)
                              : Style().textSizeColor(
                                  "กำลังออกส่ง", 16, Colors.green),
                  subtitle:
                      Style().textSizeColor('สถานะ ', 14, Style().textColor),
                ),
              )
            : Expanded(
                child: ListTile(
                  title:
                      Style().textSizeColor('Offline', 16, Colors.deepOrange),
                  subtitle:
                      Style().textSizeColor('สถานะ ', 14, Style().textColor),
                ),
              ),
        (driversModel.driverStatus != '4')
            ? Switch(
                activeColor: Style().darkColor,
                value: driverStatus,
                onChanged: (driversModel.driverStatus == '0' ||
                        driversModel.driverStatus == '1')
                    ? (value) async {
                        if (value == true) {
                          timeNow = _getTineNow();
                          await FirebaseFirestore.instance
                              .collection('drivers')
                              .doc(userOneModel.uid)
                              .update(
                                  {'onlineTime': timeNow, 'driverStatus': '1'});
                        } else {
                          await FirebaseFirestore.instance
                              .collection('drivers')
                              .doc(userOneModel.uid)
                              .update({'driverStatus': '0'});
                        }
                        setState(() {
                          driverStatus = value;
                          getDriverData = false;
                        });
                      }
                    : null)
            : Icon(Icons.block, color: Colors.red, size: 40)
      ],
    );
  }

  Column buildOrderWaite(AppDataModel appDataModel) {
    return Column(
      children: orderWaiteList.map((e) {
        String statusStr = '';
        switch (e.status) {
          case '0':
            {
              statusStr = 'ยกเลิก';
            }
            break;

          case '1':
            {
              statusStr = 'รับOrder';
            }
            break;

          case '2':
            {
              statusStr = 'ร้านค้ารับ Order แล้ว';
            }
            break;

          case '3':
            {
              statusStr = 'ร้านค้ากำลังเตรียม';
            }
            break;

          case '4':
            {
              statusStr = 'กำลังจัดส่ง';
            }
            break;
          case '5':
            {
              statusStr = 'ส่งสำเร็จ';
            }
            break;
          case '6':
            {
              statusStr = 'ส่งไม่สำเร็จ/ยกเลิก';
            }
        }

        return InkWell(
          onTap: () async {
            appDataModel.orderIdSelected = e.orderId;
            if (e.comment != null) {
              appDataModel.orderAddressComment = e.comment;
            } else {
              appDataModel.orderAddressComment = "";
            }
            print(e.location);
            List<String> locationLatLng = e.location.split(',');
            appDataModel.latOrder = double.parse(locationLatLng[0]);
            appDataModel.lngOrder = double.parse(locationLatLng[1]);
            appDataModel.lastPage = "rider";
            Navigator.pushNamed(context, "/order2Rider-page");
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: (e.status == '9' ||
                      e.status == '1' ||
                      e.status == '2' ||
                      e.status == '3' ||
                      e.status == '4')
                  ? Color.fromRGBO(244, 67, 54, 0.5)
                  : Colors.white,
            ),
            margin: EdgeInsets.only(top: 2, left: 8, right: 8),
            child: Row(
              children: [
                Expanded(
                    child: ListTile(
                  title: Style().textFlexibleBackSize(
                      'no. ' +
                          e.orderId +
                          " (" +
                          (int.parse(e.costDelivery) + int.parse(e.amount))
                              .toString() +
                          "฿)",
                      2,
                      12),
                  subtitle: Style().textBlackSize('วันที่ ' + e.startTime, 12),
                )),
                (e.status == '1')
                    ? Container(
                        margin: EdgeInsets.only(right: 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            print('confirm');
                            var result = await Dialogs().confirm(
                              context,
                              "รับ Order ?",
                              "ยืนยันรับ Order " + e.orderId,
                            );
                            print("Resulr = $result");
                            if (result == true) {
                              _confirmOrder(context.read<AppDataModel>(),
                                  e.orderId, e.shopId, e.customerId);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Style().titleH3('รับOrder'),
                              Icon(Icons.check)
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Style().primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                        ),
                      )
                    : (e.status == '2' || e.status == '4')
                        ? Container(
                            margin:
                                EdgeInsets.only(right: 8, top: 8, bottom: 8),
                            child: Column(
                              children: [
                                Style().textBlackSize(statusStr, 12),
                                Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 5),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          print('cancelOrder By Driver');
                                          _cancelOrder(
                                              context.read<AppDataModel>(),
                                              e.orderId,
                                              e.customerId,
                                              e.shopId);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Style().textSizeColor(
                                                'ยกเลิก', 12, Colors.white),
                                          ],
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.redAccent,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5))),
                                      ),
                                    ),
                                    (e.status == '2')
                                        ? Container(
                                            margin: EdgeInsets.only(
                                                right: 8, top: 8, bottom: 8),
                                            child: Column(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      var result =
                                                          await Dialogs()
                                                              .confirm(
                                                        context,
                                                        "รับสินค้า",
                                                        "รับสินค้าที่ร้านค้า",
                                                      );
                                                      print('Delivering');
                                                      if (result == true) {
                                                        _delivering(
                                                            context.read<
                                                                AppDataModel>(),
                                                            e.orderId);
                                                      }
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Style().textSizeColor(
                                                            'รับสินค้า',
                                                            12,
                                                            Colors.white)
                                                      ],
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                        primary:
                                                            Style().darkColor,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5))),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        : Container(
                                            margin: EdgeInsets.only(right: 5),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                print('Order Success');
                                                _orderSuccess(
                                                    context
                                                        .read<AppDataModel>(),
                                                    e.orderId);
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Style().textSizeColor(
                                                      'จัดส่งสำเร็จ',
                                                      12,
                                                      Colors.white),
                                                ],
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                  primary: Style().darkColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5))),
                                            ),
                                          ),
                                  ],
                                )
                              ],
                            ),
                          )
                        : (e.status == '3')
                            ? Container(
                                margin: EdgeInsets.only(
                                    right: 8, top: 8, bottom: 8),
                                child: Column(
                                  children: [
                                    Style().textBlackSize(statusStr, 12),
                                    Container(
                                      margin: EdgeInsets.only(right: 10),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          var result = await Dialogs().confirm(
                                            context,
                                            "รับสินค้า",
                                            "รับสินค้าที่ร้านค้า",
                                          );
                                          if (result == true) {
                                            print('Delivering');
                                            _delivering(
                                                context.read<AppDataModel>(),
                                                e.orderId);
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Style().textSizeColor(
                                                'รับสินค้า', 12, Colors.white),
                                          ],
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            primary: Style().darkColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5))),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Style().textSizeColor(
                                    statusStr, 12, Style().textColor),
                              )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Column buildOrderList(AppDataModel appDataModel) {
    return Column(
      children: orderList.map((e) {
        String statusStr = '';
        switch (e.status) {
          case '0':
            {
              statusStr = 'ยกเลิก';
            }
            break;

          case '1':
            {
              statusStr = 'รับOrder';
            }
            break;

          case '2':
            {
              statusStr = 'ร้านค้ารับ Order แล้ว';
            }
            break;

          case '3':
            {
              statusStr = 'ร้านค้ากำลังเตรียม';
            }
            break;

          case '4':
            {
              statusStr = 'กำลังจัดส่ง';
            }
            break;
          case '5':
            {
              statusStr = 'ส่งสำเร็จ';
            }
            break;
          case '6':
            {
              statusStr = 'ส่งไม่สำเร็จ/ยกเลิก';
            }
        }

        return InkWell(
          onTap: () async {
            appDataModel.orderIdSelected = e.orderId;
            if (e.comment != null) appDataModel.orderAddressComment = e.comment;
            print(e.location);
            List<String> locationLatLng = e.location.split(',');
            appDataModel.latOrder = double.parse(locationLatLng[0]);
            appDataModel.lngOrder = double.parse(locationLatLng[1]);
            appDataModel.lastPage = "rider";
            Navigator.pushNamed(context, "/order2Rider-page");
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: (e.status == '9' ||
                      e.status == '1' ||
                      e.status == '2' ||
                      e.status == '3' ||
                      e.status == '4')
                  ? Color.fromRGBO(244, 67, 54, 0.5)
                  : Colors.white,
            ),
            margin: EdgeInsets.only(top: 2, left: 8, right: 8),
            child: Row(
              children: [
                Expanded(
                    child: ListTile(
                  title: Style().textFlexibleBackSize(
                      'no. ' +
                          e.orderId +
                          " (" +
                          (int.parse(e.costDelivery) + int.parse(e.amount))
                              .toString() +
                          "฿)",
                      2,
                      12),
                  subtitle: Style().textBlackSize(e.startTime, 12),
                )),
                (e.status == '1')
                    ? Container(
                        margin: EdgeInsets.only(right: 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            print('confirm');
                            var result = await Dialogs().confirm(
                              context,
                              "รับ Order ?",
                              "รับ Order " + e.orderId,
                            );
                            print("Resulr = $result");
                            if (result == true) {
                              _confirmOrder(context.read<AppDataModel>(),
                                  e.orderId, e.shopId, e.customerId);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Style().titleH3('รับOrder'),
                              Icon(Icons.check)
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Style().primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                        ),
                      )
                    : (e.status == '2' || e.status == '4')
                        ? Container(
                            margin:
                                EdgeInsets.only(right: 8, top: 8, bottom: 8),
                            child: Column(
                              children: [
                                Style().textBlackSize(statusStr, 12),
                                Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 5),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          print('cancelOrder By Driver');
                                          _cancelOrder(
                                              context.read<AppDataModel>(),
                                              e.orderId,
                                              e.customerId,
                                              e.shopId);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Style().textSizeColor(
                                                'ยกเลิก', 12, Colors.white),
                                          ],
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.redAccent,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5))),
                                      ),
                                    ),
                                    (e.status == '2')
                                        ? Container(
                                            margin: EdgeInsets.only(
                                                right: 8, top: 8, bottom: 8),
                                            child: Column(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      var result =
                                                          await Dialogs()
                                                              .confirm(
                                                        context,
                                                        "รับสินค้า",
                                                        "รับสินค้าที่ร้านค้า",
                                                      );
                                                      print('Delivering');
                                                      if (result == true) {
                                                        _delivering(
                                                            context.read<
                                                                AppDataModel>(),
                                                            e.orderId);
                                                      }
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Style().textSizeColor(
                                                            'รับสินค้า',
                                                            12,
                                                            Colors.white)
                                                      ],
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                        primary:
                                                            Style().darkColor,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5))),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        : Container(
                                            margin: EdgeInsets.only(right: 5),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                print('Order Success');
                                                _orderSuccess(
                                                    context
                                                        .read<AppDataModel>(),
                                                    e.orderId);
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Style().textSizeColor(
                                                      'จัดส่งสำเร็จ',
                                                      12,
                                                      Colors.white),
                                                ],
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                  primary: Style().darkColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5))),
                                            ),
                                          ),
                                  ],
                                )
                              ],
                            ),
                          )
                        : (e.status == '3')
                            ? Container(
                                margin: EdgeInsets.only(
                                    right: 8, top: 8, bottom: 8),
                                child: Column(
                                  children: [
                                    Style().textBlackSize(statusStr, 12),
                                    Container(
                                      margin: EdgeInsets.only(right: 10),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          var result = await Dialogs().confirm(
                                            context,
                                            "รับสินค้า",
                                            "รับสินค้าที่ร้านค้า",
                                          );
                                          if (result == true) {
                                            print('Delivering');
                                            _delivering(
                                                context.read<AppDataModel>(),
                                                e.orderId);
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Style().textSizeColor(
                                                'รับสินค้า', 12, Colors.white),
                                          ],
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            primary: Style().darkColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5))),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Style().textSizeColor(
                                    statusStr, 12, Style().textColor),
                              )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  _orderSuccess(AppDataModel appDataModel, String orderId) async {
    String finishTime = await getTimeStringNow();
    db
        .collection("orders")
        .doc(orderId)
        .update({'status': '5', 'finishTime': finishTime}).then((value) async {
      String onlineTime = await getTimeStampNow();
      addLog(orderId, '5', 'driver', userOneModel.uid, '').then((value) {
        db.collection('drivers').doc(userOneModel.uid).update(
            {'driverStatus': '1', 'onlineTime': onlineTime}).then((value) {
          setState(() {
            getDriverData = false;
          });
        });
      });
    });
  }

  _delivering(AppDataModel appDataModel, String orderId) {
    db.collection('orders').doc(orderId).update({'status': '4'}).then((value) {
      addLog(orderId, '4', 'driver', userOneModel.uid, '').then((value) {
        setState(() {
          getDriverData = false;
        });
      });
    });
  }

  _cancelOrder(
      AppDataModel appDataModel, String orderId, customerId, shopId) async {
    String onlineTime = await getTimeStampNow();
    String userToken;
    String shopToken;
    await db.collection("users").doc(customerId).get().then((value) {
      UserOneModel userOneModel =
          userOneModelFromJson(jsonEncode(value.data()));
      userToken = userOneModel.token;
    });
    await db.collection("shops").doc(shopId).get().then((value) {
      ShopModel shopModel = shopModelFromJson(jsonEncode(value.data()));
      shopToken = shopModel.token;
    });
    db.collection('orders').doc(orderId).get().then((value) async {
      OrderDetail orderDetail = orderDetailFromJson(jsonEncode(value.data()));
      if (orderDetail.status == '2' || orderDetail.status == '4') {
        var result = await dialogs.inputDialog(
            context,
            Style().textSizeColor('เหตุผล', 16, Style().textColor),
            'ระบุเหตุผลที่ยกเลิก');
        if (result != null && result[0] == true) {
          db
              .collection('orders')
              .doc(orderId)
              .update({'status': '6'}).then((value) {
            addLog(orderId, '6', 'driver', userOneModel.uid, result[1])
                .then((value) {
              db
                  .collection('drivers')
                  .doc(userOneModel.uid)
                  .update({'driverStatus': '1', 'onlineTime': onlineTime}).then(
                      (value) async {
                await notifySend(shopToken, "Order ถูกยกเลิกโดย Rider",
                    "Order:" + orderId + " เหตุผล: " + result[1]);
                await notifySend(userToken, "Order ถูกยกเลิกโดย Rider",
                    "Order:" + orderId + " เหตุผล: " + result[1]);
                getDriverData = false;
                setState(() {});
              });
            });
          });
        }
      } else {
        await dialogs.information(
            context,
            Style().textSizeColor('ผิดพลาด', 14, Style().textColor),
            Style().textSizeColor(
                'ไม่สามารถยกเลิกได้โปรดลองใหม่ภายหลัง', 12, Style().textColor));
        getDriverData = false;
        setState(() {});
      }
    });

    // print(result);
  }

  _confirmOrder(
      AppDataModel appDataModel, String orderId, shopId, customerId) async {
    print("order Id = " + orderId);
    String userToken;
    String shopToken;
    await db.collection("users").doc(customerId).get().then((value) {
      UserOneModel userOneModel =
          userOneModelFromJson(jsonEncode(value.data()));
      userToken = userOneModel.token;
    });
    await db.collection("shops").doc(shopId).get().then((value) {
      ShopModel shopModel = shopModelFromJson(jsonEncode(value.data()));
      shopToken = shopModel.token;
    });
    await db
        .collection('drivers')
        .doc(appDataModel.userOneModel.uid)
        .get()
        .then((value) async {
      driversModel = driversModelFromJson(jsonEncode(value.data()));
      print('DriverStatusBefor Confirm = ' + driversModel.driverStatus);

      if (driversModel.driverStatus == "1" || appDataModel.loginLevel == "3") {
        db.collection('orders').doc(orderId).get().then((value) async {
          OrderDetail orderDetail =
              orderDetailFromJson(jsonEncode(value.data()));
          print('status = ' + orderDetail.status);
          if (orderDetail.status == '1') {
            print('change Status Success');
            await db
                .collection('orders')
                .doc(orderId)
                .update({'status': '2', 'driver': userOneModel.uid}).then(
                    (value) async {
              await db
                  .collection("drivers")
                  .doc(userOneModel.uid)
                  .update({"driverStatus": "2"}).then((value) async {
                await addLog(orderId, '2', 'driver', userOneModel.uid, '')
                    .then((value) async {
                  inWork = true;
                  getDriverData = false;
                  await notifySend(
                      shopToken, "มี Order ใหม่ Shop", "Order:" + orderId);
                  await notifySend(userToken, "Rider ตอบรับ Orderแล้ว",
                      "Rider: " + driversModel.driverName);

                  setState(() {});
                });
              });
            });
          } else {
            await dialogs.information(
                context,
                Style().textSizeColor('ผิดพลาด', 14, Style().textColor),
                Style().textSizeColor('Order นี้ถูกจัดส่งโดยRiderท่านอื่นแล้ว',
                    12, Style().textColor));

            getDriverData = false;
            setState(() {});
          }
        });
      } else {
        await Dialogs().information(
            context,
            Style().textBlackSize("รับ Order ไม่ได้", 14),
            Style().textBlackSize("คุณกำลังส่ง Order อื่นอยู่", 12));
        getDriverData = false;
        setState(() {});
      }
    });
  }

  _getTineNow() {
    String dateString = DateTime.now().millisecondsSinceEpoch.toString();
    return dateString;
  }
}
