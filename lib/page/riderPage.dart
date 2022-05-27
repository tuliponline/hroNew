import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/GasSetupModel.dart';
import 'package:hro/model/MartSetupModel.dart';
import 'package:hro/model/UserListMudel.dart';
import 'package:hro/model/UserOneModel.dart';
import 'package:hro/model/allShopModel.dart';
import 'package:hro/model/chatListModel.dart';
import 'package:hro/model/creditTransectionModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/model/setupModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/page/showHomePage.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/addLog.dart';
import 'package:hro/utility/getTimeNow.dart';
import 'package:hro/utility/notifySend.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

import 'fireBaseFunctions.dart';

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
  bool loading = false;
  List<UserListModel> _userListModel;
  List<AllShopModel> _allShopData;

  MartSetupModel martSetupModel;
  GasSetupModel gasSetupModel;
  ProductSetupModel productSetupModel;

  _setData(AppDataModel appDataModel) async {
    var _martSetup = await dbGetDataOne("getMartSetup", "martSetup", "001");
    if (_martSetup[0]) {
      var jsonData = _martSetup[1];
      martSetupModel = martSetupModelFromJson(jsonData);
    }
    var _gasSetup = await dbGetDataOne("getMartSetup", "gasSetup", "001");
    if (_gasSetup[0]) {
      var jsonData = _gasSetup[1];
      gasSetupModel = gasSetupModelFromJson(jsonData);
    }
    var _productSetup = await dbGetDataOne("getMartSetup", "setup", "product");
    if (_productSetup[0]) {
      var jsonData = _productSetup[1];
      productSetupModel = productSetupModelFromJson(jsonData);
    }

    userOneModel = appDataModel.userOneModel;
    var _userDbResult = await dbGetDataAll("getAllUser", "users");
    if (_userDbResult[0] == true) {
      var _jsonData = setList2Json(_userDbResult[1]);
      _userListModel = userListModelFromJson(_jsonData);
    }

    var _shopDbResult = await dbGetDataAll("getAllShop", "shops");
    if (_shopDbResult[0] == true) {
      var _jsonData = setList2Json(_shopDbResult[1]);
      _allShopData = allShopModelFromJson(_jsonData);
    }

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
      loading = false;
      getDriverData = true;
      if (this.mounted) {
        setState(() {});
      }
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
        .limit(10)
        .get()
        .then((value) async {
      var _jsonData = setList2Json(value);
      orderList = orderListFromJson(_jsonData);
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

  _realTimeDB(AppDataModel appDataModel) async {
    db.collection("orders").snapshots().listen((event) async {
      if (driversModel != null) {
        await _getOrders(context.read<AppDataModel>());
        if (this.mounted) {
          // check whether the state object is in tree
          setState(() {
            // make changes here
          });
        }
      }
    });
  }

  void initState() {
    _Notififation();
    _realTimeDB(context.read<AppDataModel>());
    super.initState();
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
                      title: Style().textSizeColor(
                          'เครดิต ฿' + userOneModel.credit,
                          18,
                          Style().darkColor),
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
                  child: (driversModel == null || loading == true)
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
        int _discount = 0;
        int _customerpay = 0;
        int _costDelivery = 0;

        if (e.discount != null) {
          _discount = int.parse(e.discount);
        }
        if (e.costDelivery != null) {
          _costDelivery = int.parse(e.costDelivery);
        }
        _customerpay = int.parse(e.amount) + _costDelivery - _discount;

        OrderDetail _orderDetail = orderDetailFromJson(jsonEncode(e));

        String statusStr = '';
        switch (e.status) {
          case '1':
            {
              statusStr = 'รอRider ตอบรับ';
            }
            break;
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
            if (e.orderType == null || e.payType == "narmal") {
              Navigator.pushNamed(context, "/order2Rider-page");
            } else if (e.orderType == "mart" || e.orderType == "gas") {
              appDataModel.orderDetailSelect =
                  orderDetailFromJson(jsonEncode(e));
              Navigator.pushNamed(context, "/showOrderMart-page",
                  arguments: "rider");
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.white,
            ),
            margin: EdgeInsets.only(top: 2, left: 8, right: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    (e.orderType == "mart")
                        ? FutureBuilder<List<MartListDetailModel>>(
                            future: _getMartDetail(e.orderId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<MartListDetailModel> _martDetailListData =
                                    snapshot.data;
                                return _buildOrderMartAddress(
                                    context.read<AppDataModel>(),
                                    _orderDetail,
                                    _martDetailListData);
                              }

                              return Style().loading();
                            })
                        : _buildOrderAddress(
                            context.read<AppDataModel>(), _orderDetail),
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                          child: Column(
                            children: [
                              Container(
                                width: appDataModel.screenW * 0.35,
                                margin: EdgeInsets.only(right: 10),
                                child: Column(
                                  children: [
                                    (e.status == "0" ||
                                            e.status == "1" ||
                                            e.status == "6")
                                        ? Container()
                                        : InkWell(
                                            onTap: () {
                                              appDataModel.orderDetailSelect =
                                                  orderDetailFromJson(
                                                      jsonEncode(e));
                                              appDataModel.userTypeSelect =
                                                  "rider";
                                              appDataModel.orderIdSelected =
                                                  e.orderId;
                                              Navigator.pushNamed(
                                                  context, "/chat-page");
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(top: 5),
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                          ),
                                    Container(
                                      margin: EdgeInsets.only(top: 5),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.grey.shade300),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          (e.payType == "cash")
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Icon(
                                                        FontAwesomeIcons
                                                            .moneyBill,
                                                        size: 15,
                                                        color: Colors.red),
                                                    Style().textBlackSize(
                                                        "   เงินสด", 14),
                                                  ],
                                                )
                                              : Row(
                                                  children: [
                                                    Icon(
                                                        FontAwesomeIcons.wallet,
                                                        size: 15,
                                                        color: Colors.orange),
                                                    Style().textBlackSize(
                                                        "   เครดิต", 14),
                                                  ],
                                                ),
                                          Style().textBlackSize(
                                              (_customerpay).toString() + " ฿",
                                              14),
                                        ],
                                      ),
                                    ),
                                    (e.costDelivery4Rider == null)
                                        ? Container()
                                        : Container(
                                            margin: EdgeInsets.only(top: 5),
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.grey.shade300),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      FontAwesomeIcons
                                                          .handHoldingUsd,
                                                      size: 15,
                                                      color:
                                                          Colors.green.shade600,
                                                    ),
                                                    Style().textSizeColor(
                                                        "   รายได้ ",
                                                        16,
                                                        Colors.green.shade600),
                                                  ],
                                                ),
                                                Style().textSizeColor(
                                                    e.costDelivery4Rider + " ฿",
                                                    14,
                                                    Colors.green.shade600)
                                              ],
                                            ),
                                          ),
                                    (e.orderType == "hotShop")
                                        ? Container()
                                        : Container(
                                            margin: EdgeInsets.only(
                                                top: 5, bottom: 0),
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.grey.shade300),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Style().textBlackSize(
                                                    "$statusStr", 12),
                                              ],
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                              (e.orderType == "hotShop")
                                  ? Container(
                                      width: appDataModel.screenW * 0.35,
                                      child: Style().textFlexibleColorSize(
                                          '*เตรียมค่าสินค้า ' + e.amount + " ฿",
                                          2,
                                          14,
                                          Colors.red),
                                    )
                                  : Container(),
                              Column(
                                children: [
                                  (e.status == '2')
                                      ? Container(
                                          margin: EdgeInsets.only(
                                            right: 8,
                                          ),
                                          width: appDataModel.screenW * 0.35,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              var result =
                                                  await Dialogs().confirm(
                                                context,
                                                "รับสินค้า หรือ ซื้อสินค้า",
                                                "รับสินค้า หรือ ซื้อสินค้าครบแล้ว",
                                              );
                                              print('Delivering');
                                              if (result == true) {
                                                await _delivering(
                                                    context
                                                        .read<AppDataModel>(),
                                                    e.orderId,
                                                    e.customerId);
                                              }
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                (e.orderType == null ||
                                                        e.orderType == "narmal")
                                                    ? Style().textSizeColor(
                                                        'รับสินค้า',
                                                        12,
                                                        Colors.white)
                                                    : (e.orderType == "hotShop")
                                                        ? Style().textSizeColor(
                                                            'สั่งสินค้าหน้าร้าน',
                                                            12,
                                                            Colors.white)
                                                        : Style().textSizeColor(
                                                            'ซื้อสินค้าครบแล้ว',
                                                            12,
                                                            Colors.white)
                                              ],
                                            ),
                                            style: ElevatedButton.styleFrom(
                                                primary: Style().okColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5))),
                                          ),
                                        )
                                      : Container(
                                          width: appDataModel.screenW * 0.35,
                                          margin: EdgeInsets.only(right: 5),
                                          child: Column(
                                            children: [
                                              ElevatedButton(
                                                onPressed: () async {
                                                  if (e.orderType == "mart") {
                                                    if (martSetupModel
                                                            .shareForApp !=
                                                        "0") {
                                                      int orderAmount = int
                                                              .parse(e.amount) +
                                                          int.parse(
                                                              e.costDelivery);
                                                      int riderCredit =
                                                          int.parse(appDataModel
                                                              .userOneModel
                                                              .credit);
                                                      if (riderCredit >
                                                          orderAmount) {
                                                        print('confirm');
                                                        var result =
                                                            await Dialogs()
                                                                .confirm(
                                                          context,
                                                          "รับ Order ?",
                                                          "ยืนยันรับ Order " +
                                                              e.orderId,
                                                        );
                                                        print(
                                                            "Resulr = $result");
                                                        if (result == true) {
                                                          _confirmOrder(
                                                              context.read<
                                                                  AppDataModel>(),
                                                              e);
                                                        }
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "เครดิตไม่พอสำหรับรับงานนี้",
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER,
                                                            timeInSecForIosWeb:
                                                                1,
                                                            backgroundColor:
                                                                Colors.red,
                                                            textColor:
                                                                Colors.white,
                                                            fontSize: 16.0);
                                                      }
                                                    } else {
                                                      print('confirm');
                                                      var result =
                                                          await Dialogs()
                                                              .confirm(
                                                        context,
                                                        "รับ Order ?",
                                                        "ยืนยันรับ Order " +
                                                            e.orderId,
                                                      );
                                                      print("Resulr = $result");
                                                      if (result == true) {
                                                        _confirmOrder(
                                                            context.read<
                                                                AppDataModel>(),
                                                            e);
                                                      }
                                                    }
                                                  } else if (e.orderType ==
                                                      "gas") {
                                                    if (gasSetupModel
                                                            .shareForApp !=
                                                        "0") {
                                                      int orderAmount = int
                                                              .parse(e.amount) +
                                                          int.parse(
                                                              e.costDelivery);
                                                      int riderCredit =
                                                          int.parse(appDataModel
                                                              .userOneModel
                                                              .credit);
                                                      if (riderCredit >
                                                          orderAmount) {
                                                        print('confirm');
                                                        var result =
                                                            await Dialogs()
                                                                .confirm(
                                                          context,
                                                          "รับ Order ?",
                                                          "ยืนยันรับ Order " +
                                                              e.orderId,
                                                        );
                                                        print(
                                                            "Resulr = $result");
                                                        if (result == true) {
                                                          _confirmOrder(
                                                              context.read<
                                                                  AppDataModel>(),
                                                              e);
                                                        }
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "เครดิตไม่พอสำหรับรับงานนี้",
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER,
                                                            timeInSecForIosWeb:
                                                                1,
                                                            backgroundColor:
                                                                Colors.red,
                                                            textColor:
                                                                Colors.white,
                                                            fontSize: 16.0);
                                                      }
                                                    } else {
                                                      print('confirm');
                                                      var result =
                                                          await Dialogs()
                                                              .confirm(
                                                        context,
                                                        "รับ Order ?",
                                                        "ยืนยันรับ Order " +
                                                            e.orderId,
                                                      );
                                                      print("Resulr = $result");
                                                      if (result == true) {
                                                        _confirmOrder(
                                                            context.read<
                                                                AppDataModel>(),
                                                            e);
                                                      }
                                                    }
                                                  } else {
                                                    if (productSetupModel
                                                            .shareForApp !=
                                                        "0") {
                                                      int orderAmount =
                                                          int.parse(e.amount);
                                                      int riderCredit =
                                                          int.parse(appDataModel
                                                              .userOneModel
                                                              .credit);
                                                      if (riderCredit >
                                                          orderAmount) {
                                                        print('confirm');
                                                        var result =
                                                            await Dialogs()
                                                                .confirm(
                                                          context,
                                                          "รับ Order ?",
                                                          "ยืนยันรับ Order " +
                                                              e.orderId,
                                                        );
                                                        print(
                                                            "Resulr = $result");
                                                        if (result == true) {
                                                          _confirmOrder(
                                                              context.read<
                                                                  AppDataModel>(),
                                                              e);
                                                        }
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "เครดิตไม่พอสำหรับรับงานนี้",
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER,
                                                            timeInSecForIosWeb:
                                                                1,
                                                            backgroundColor:
                                                                Colors.red,
                                                            textColor:
                                                                Colors.white,
                                                            fontSize: 16.0);
                                                      }
                                                    } else {
                                                      print('confirm');
                                                      var result =
                                                          await Dialogs()
                                                              .confirm(
                                                        context,
                                                        "รับ Order ?",
                                                        "ยืนยันรับ Order " +
                                                            e.orderId,
                                                      );
                                                      print("Resulr = $result");
                                                      if (result == true) {
                                                        _confirmOrder(
                                                            context.read<
                                                                AppDataModel>(),
                                                            e);
                                                      }
                                                    }
                                                  }
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Style().textSizeColor(
                                                        'รับ Order',
                                                        12,
                                                        Colors.white),
                                                  ],
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                    primary: Style().okColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5))),
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    Style()
                        .textBlackSize(e.startTime + " Order." + e.orderId, 12),
                  ],
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  buildOrderList(AppDataModel appDataModel) {
    return Column(
      children: orderList.map((e) {
        int _index = orderList.indexOf(e);
        Color textColors = Colors.black;
        int _discoubt = 0;
        int _amount = 0;
        int _costDelivery = 0;
        int _costDelivery4Rider = 0;

        if (e.discount != null) _discoubt = int.parse(e.discount);
        if (e.amount != null) _amount = int.parse(e.amount);
        if (e.costDelivery != null) _costDelivery = int.parse(e.costDelivery);
        if (e.costDelivery4Rider != null)
          _costDelivery4Rider = int.parse(e.costDelivery4Rider);

        OrderDetail _orderDetail = orderDetailFromJson(jsonEncode(e));
        String statusStr = '';
        switch (e.status) {
          case '0':
            {
              statusStr = 'ยกเลิก';
              textColors = Colors.red;
            }
            break;

          case '1':
            {
              statusStr = 'รับOrder';
            }
            break;

          case '2':
            {
              statusStr = 'Riderกำลังไปรับสินค้า';
              if (e.orderType == "mart") statusStr = 'Rider กำลังออกซื้อของ';
              if (e.orderType == "gas") statusStr = 'Riderกำลังไปรับถังแกส';
            }
            break;

          case '3':
            {
              statusStr = 'ร้านค้ากำลังเตรียมสินค้า';
            }
            break;

          case '4':
            {
              statusStr = 'Rider กำลังออกจัดส่ง';
            }
            break;
          case '5':
            {
              statusStr = 'ส่งสำเร็จ';
            }
            break;
          case '6':
            {
              statusStr = 'ส่งไม่สำเร็จ';
              textColors = Colors.red;
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
            if (e.orderType == null || e.orderType == "narmal") {
              Navigator.pushNamed(context, "/order2Rider-page");
            } else if (e.orderType == "mart") {
              appDataModel.orderDetailSelect =
                  orderDetailFromJson(jsonEncode(e));
              Navigator.pushNamed(context, "/showOrderMart-page",
                  arguments: "rider");
            } else if (e.orderType == "gas") {
              appDataModel.orderDetailSelect =
                  orderDetailFromJson(jsonEncode(e));
              Navigator.pushNamed(context, "/showOrderGas-page",
                  arguments: "rider");
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: (e.status == '9' ||
                      e.status == '1' ||
                      e.status == '2' ||
                      e.status == '3' ||
                      e.status == '4')
                  ? Colors.white
                  : Colors.white,
            ),
            margin: EdgeInsets.only(top: 2, left: 8, right: 8),
            child: (e.status == "0" || e.status == "5" || e.status == "6")
                ? Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (e.location == null)
                                ? Container()
                                : Style()
                                    .textBlackSize("Order." + e.orderId, 14),
                            Style().textBlackSize(e.startTime, 12),
                          ],
                        ),
                        Style().textBlackSize(statusStr, 14),
                      ],
                    ))
                : Column(
                    children: [
                      Row(
                        children: [
                          (e.orderType == "mart")
                              ? FutureBuilder<List<MartListDetailModel>>(
                                  future: _getMartDetail(e.orderId),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      List<MartListDetailModel>
                                          _martDetailListData = snapshot.data;
                                      return _buildOrderMartAddress(
                                          context.read<AppDataModel>(),
                                          _orderDetail,
                                          _martDetailListData);
                                    }

                                    return Style().loading();
                                  })
                              : _buildOrderAddress(
                                  context.read<AppDataModel>(), _orderDetail),
                          (e.status == '1')
                              ? Container()
                              : (e.status == '2' || e.status == '4')
                                  ? Container(
                                      margin: EdgeInsets.only(
                                          right: 8, top: 8, bottom: 8),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: appDataModel.screenW * 0.35,
                                            margin: EdgeInsets.only(right: 10),
                                            child: Column(
                                              children: [
                                                (e.status == "0" ||
                                                        e.status == "1" ||
                                                        e.status == "6")
                                                    ? Container()
                                                    : InkWell(
                                                        onTap: () {
                                                          appDataModel
                                                                  .orderDetailSelect =
                                                              orderDetailFromJson(
                                                                  jsonEncode(
                                                                      e));
                                                          appDataModel
                                                                  .userTypeSelect =
                                                              "rider";
                                                          appDataModel
                                                                  .orderIdSelected =
                                                              e.orderId;
                                                          Navigator.pushNamed(
                                                              context,
                                                              "/chat-page");
                                                        },
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 5),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              (e.chatRider !=
                                                                          null &&
                                                                      e.chatRider ==
                                                                          "1")
                                                                  ? Badge(
                                                                      badgeColor:
                                                                          Colors
                                                                              .red,
                                                                      position: BadgePosition.topEnd(
                                                                          top:
                                                                              -5,
                                                                          end:
                                                                              -5),
                                                                      shape: BadgeShape
                                                                          .circle,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              100),
                                                                      child: Icon(FontAwesomeIcons.facebookMessenger,
                                                                          size:
                                                                              30,
                                                                          color: Colors
                                                                              .blue),
                                                                      badgeContent:
                                                                          null)
                                                                  : Icon(
                                                                      FontAwesomeIcons
                                                                          .facebookMessenger,
                                                                      size: 30,
                                                                      color: Colors
                                                                          .blue),
                                                              Style().textBlackSize(
                                                                  " แชทกับลูกค้า"
                                                                      .toString(),
                                                                  14),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 5),
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color:
                                                          Colors.grey.shade300),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      (e.payType == "cash")
                                                          ? Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                Icon(
                                                                    FontAwesomeIcons
                                                                        .moneyBill,
                                                                    size: 15,
                                                                    color: Colors
                                                                        .red),
                                                                Style().textBlackSize(
                                                                    "   เงินสด",
                                                                    14),
                                                              ],
                                                            )
                                                          : Row(
                                                              children: [
                                                                Icon(
                                                                    FontAwesomeIcons
                                                                        .wallet,
                                                                    size: 15,
                                                                    color: Colors
                                                                        .orange),
                                                                Style().textBlackSize(
                                                                    "   เครดิต",
                                                                    14),
                                                              ],
                                                            ),
                                                      Style().textBlackSize(
                                                          ((int.parse(e.amount) +
                                                                      int.parse(e
                                                                          .costDelivery) -
                                                                      int.parse(
                                                                          e.discount)))
                                                                  .toString() +
                                                              " ฿",
                                                          14),
                                                    ],
                                                  ),
                                                ),
                                                (e.costDelivery4Rider == null)
                                                    ? Container()
                                                    : Container(
                                                        margin: EdgeInsets.only(
                                                            top: 5),
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: Colors
                                                                .grey.shade300),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  FontAwesomeIcons
                                                                      .handHoldingUsd,
                                                                  size: 15,
                                                                  color: Colors
                                                                      .green
                                                                      .shade600,
                                                                ),
                                                                Style().textSizeColor(
                                                                    "   รายได้ ",
                                                                    16,
                                                                    Colors.green
                                                                        .shade600),
                                                              ],
                                                            ),
                                                            Style().textSizeColor(
                                                                e.costDelivery4Rider +
                                                                    " ฿",
                                                                14,
                                                                Colors.green
                                                                    .shade600)
                                                          ],
                                                        ),
                                                      ),
                                                (e.orderType == "hotShop")
                                                    ? Container()
                                                    : Container(
                                                        margin: EdgeInsets.only(
                                                            top: 5, bottom: 0),
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            color: Colors
                                                                .grey.shade300),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Style()
                                                                .textSizeColor(
                                                                    "$statusStr",
                                                                    12,
                                                                    textColors),
                                                          ],
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                          (e.orderType == "hotShop")
                                              ? Container(
                                                  width: appDataModel.screenW *
                                                      0.35,
                                                  child: Style()
                                                      .textFlexibleColorSize(
                                                          '*เตรียมค่าสินค้า ' +
                                                              e.amount +
                                                              " ฿",
                                                          2,
                                                          14,
                                                          Colors.red),
                                                )
                                              : Container(),
                                          Column(
                                            children: [
                                              (e.status == '2')
                                                  ? Container(
                                                      margin: EdgeInsets.only(
                                                        right: 8,
                                                      ),
                                                      width:
                                                          appDataModel.screenW *
                                                              0.35,
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          String _title =
                                                              "รับสินค้า หรือ ซื้อสินค้า";
                                                          String _body =
                                                              "รับสินค้า หรือ ซื้อสินค้าครบแล้ว";
                                                          if (e.orderType ==
                                                              "gas") {
                                                            _title =
                                                                "เติมแก๊สแล้ว";
                                                            _body =
                                                                "เติมแก๊สเต็ม และ กำลังส่งถังแก๊สกลับ ";
                                                          }
                                                          var result =
                                                              await Dialogs()
                                                                  .confirm(
                                                            context,
                                                            _title,
                                                            _body,
                                                          );
                                                          print('Delivering');
                                                          if (result == true) {
                                                            await _delivering(
                                                                context.read<
                                                                    AppDataModel>(),
                                                                e.orderId,
                                                                e.customerId);
                                                          }
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            (e.orderType ==
                                                                        null ||
                                                                    e.orderType ==
                                                                        "narmal")
                                                                ? Style().textSizeColor(
                                                                    'รับสินค้า',
                                                                    12,
                                                                    Colors
                                                                        .white)
                                                                : (e.orderType ==
                                                                        "hotShop")
                                                                    ? Style().textSizeColor(
                                                                        'สั่งสินค้าหน้าร้าน',
                                                                        12,
                                                                        Colors
                                                                            .white)
                                                                    : (e.orderType ==
                                                                            "gas")
                                                                        ? Style().textSizeColor(
                                                                            'เติมแก๊สเต็มแล้ว',
                                                                            12,
                                                                            Colors
                                                                                .white)
                                                                        : Style().textSizeColor(
                                                                            'ซื้อสินค้าครบแล้ว',
                                                                            12,
                                                                            Colors.white)
                                                          ],
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                            primary:
                                                                Style().okColor,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5))),
                                                      ),
                                                    )
                                                  : Container(
                                                      width:
                                                          appDataModel.screenW *
                                                              0.35,
                                                      margin: EdgeInsets.only(
                                                          right: 5),
                                                      child: Column(
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              var result = await Dialogs()
                                                                  .confirm(
                                                                      context,
                                                                      "จัดส่งสินค้า",
                                                                      "ยืนยันการส่งมอบสินค้า");
                                                              print("resule = " +
                                                                  result
                                                                      .toString());
                                                              if (result ==
                                                                  true) {
                                                                await _orderSuccess(
                                                                    context.read<
                                                                        AppDataModel>(),
                                                                    e.orderId,
                                                                    e.distance,
                                                                    e.payType,
                                                                    e.discount,
                                                                    e.customerId);
                                                              }
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Style().textSizeColor(
                                                                    'จัดส่งสำเร็จ',
                                                                    12,
                                                                    Colors
                                                                        .white),
                                                              ],
                                                            ),
                                                            style: ElevatedButton.styleFrom(
                                                                primary: Style()
                                                                    .okColor,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5))),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                              Container(
                                                width:
                                                    appDataModel.screenW * 0.35,
                                                margin:
                                                    EdgeInsets.only(right: 8),
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    print(
                                                        'cancelOrder By Driver');
                                                    _cancelOrder(
                                                        context.read<
                                                            AppDataModel>(),
                                                        e.orderId,
                                                        e.customerId,
                                                        e.shopId,
                                                        e.orderType);
                                                  },
                                                  child: Style().textSizeColor(
                                                      'ยกเลิก',
                                                      12,
                                                      Colors.white),
                                                  style: ElevatedButton.styleFrom(
                                                      primary: Colors.redAccent,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5))),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  : (e.status == '3')
                                      ? Column(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  right: 8, top: 8, bottom: 8),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width:
                                                        appDataModel.screenW *
                                                            0.35,
                                                    margin: EdgeInsets.only(
                                                        right: 10),
                                                    child: Column(
                                                      children: [
                                                        (e.status == "0" ||
                                                                e.status ==
                                                                    "1" ||
                                                                e.status == "6")
                                                            ? Container()
                                                            : InkWell(
                                                                onTap: () {
                                                                  appDataModel
                                                                          .orderDetailSelect =
                                                                      orderDetailFromJson(
                                                                          jsonEncode(
                                                                              e));
                                                                  appDataModel
                                                                          .userTypeSelect =
                                                                      "rider";
                                                                  appDataModel
                                                                          .orderIdSelected =
                                                                      e.orderId;
                                                                  Navigator.pushNamed(
                                                                      context,
                                                                      "/chat-page");
                                                                },
                                                                child:
                                                                    Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              5),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                          FontAwesomeIcons
                                                                              .facebookMessenger,
                                                                          size:
                                                                              30,
                                                                          color:
                                                                              Colors.blue),
                                                                      Style().textBlackSize(
                                                                          " แชทกับลูกค้า",
                                                                          14),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 5),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: Colors.grey
                                                                  .shade300),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              (e.payType ==
                                                                      "cash")
                                                                  ? Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceAround,
                                                                      children: [
                                                                        Icon(
                                                                            FontAwesomeIcons
                                                                                .moneyBill,
                                                                            size:
                                                                                15,
                                                                            color:
                                                                                Colors.red),
                                                                        Style().textBlackSize(
                                                                            "   เงินสด",
                                                                            14),
                                                                      ],
                                                                    )
                                                                  : Row(
                                                                      children: [
                                                                        Icon(
                                                                            FontAwesomeIcons
                                                                                .wallet,
                                                                            size:
                                                                                15,
                                                                            color:
                                                                                Colors.orange),
                                                                        Style().textBlackSize(
                                                                            "   เครดิต",
                                                                            14),
                                                                      ],
                                                                    ),
                                                              Style().textBlackSize(
                                                                  ((int.parse(e.amount) +
                                                                              int.parse(e.costDelivery) -
                                                                              int.parse(e.discount)))
                                                                          .toString() +
                                                                      " ฿",
                                                                  14),
                                                            ],
                                                          ),
                                                        ),
                                                        (e.costDelivery4Rider ==
                                                                null)
                                                            ? Container()
                                                            : Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 5),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                5),
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          FontAwesomeIcons
                                                                              .handHoldingUsd,
                                                                          size:
                                                                              15,
                                                                          color: Colors
                                                                              .green
                                                                              .shade600,
                                                                        ),
                                                                        Style().textSizeColor(
                                                                            "   รายได้ ",
                                                                            16,
                                                                            Colors.green.shade600),
                                                                      ],
                                                                    ),
                                                                    Style().textSizeColor(
                                                                        e.costDelivery4Rider +
                                                                            " ฿",
                                                                        14,
                                                                        Colors
                                                                            .green
                                                                            .shade600)
                                                                  ],
                                                                ),
                                                              ),
                                                        (e.orderType ==
                                                                "hotShop")
                                                            ? Container()
                                                            : Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 5,
                                                                        bottom:
                                                                            0),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                5),
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Style().textSizeColor(
                                                                        "$statusStr",
                                                                        12,
                                                                        textColors),
                                                                  ],
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                  (e.orderType == "hotShop")
                                                      ? Container(
                                                          width: appDataModel
                                                                  .screenW *
                                                              0.35,
                                                          child: Style()
                                                              .textFlexibleColorSize(
                                                                  '*เตรียมค่าสินค้า ' +
                                                                      e.amount +
                                                                      " ฿",
                                                                  2,
                                                                  14,
                                                                  Colors.red),
                                                        )
                                                      : Container(),
                                                  Column(
                                                    children: [
                                                      (e.status == '2')
                                                          ? Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                right: 8,
                                                              ),
                                                              width: appDataModel
                                                                      .screenW *
                                                                  0.35,
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed:
                                                                    () async {
                                                                  String
                                                                      _title =
                                                                      "รับสินค้า หรือ ซื้อสินค้า";
                                                                  String _body =
                                                                      "รับสินค้า หรือ ซื้อสินค้าครบแล้ว";
                                                                  if (e.orderType ==
                                                                      "gas") {
                                                                    _title =
                                                                        "เติมแก๊สแล้ว";
                                                                    _body =
                                                                        "เติมแก๊สเต็ม และ กำลังส่งถังแก๊สกลับ ";
                                                                  }
                                                                  var result =
                                                                      await Dialogs()
                                                                          .confirm(
                                                                    context,
                                                                    _title,
                                                                    _body,
                                                                  );
                                                                  print(
                                                                      'Delivering');
                                                                  if (result ==
                                                                      true) {
                                                                    await _delivering(
                                                                        context.read<
                                                                            AppDataModel>(),
                                                                        e.orderId,
                                                                        e.customerId);
                                                                  }
                                                                },
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    (e.orderType ==
                                                                                null ||
                                                                            e.orderType ==
                                                                                "narmal")
                                                                        ? Style().textSizeColor(
                                                                            'รับสินค้า',
                                                                            12,
                                                                            Colors
                                                                                .white)
                                                                        : (e.orderType ==
                                                                                "hotShop")
                                                                            ? Style().textSizeColor(
                                                                                'สั่งสินค้าหน้าร้าน',
                                                                                12,
                                                                                Colors.white)
                                                                            : Style().textSizeColor('ซื้อสินค้าครบแล้ว', 12, Colors.white)
                                                                  ],
                                                                ),
                                                                style: ElevatedButton.styleFrom(
                                                                    primary: Style()
                                                                        .okColor,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5))),
                                                              ),
                                                            )
                                                          : Container(
                                                              width: appDataModel
                                                                      .screenW *
                                                                  0.35,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      right: 5),
                                                              child: Column(
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      var result =
                                                                          await Dialogs()
                                                                              .confirm(
                                                                        context,
                                                                        "รับสินค้า",
                                                                        "รับสินค้าที่ร้านค้า",
                                                                      );
                                                                      if (result ==
                                                                          true) {
                                                                        print(
                                                                            'Delivering');
                                                                        _delivering(
                                                                            context.read<AppDataModel>(),
                                                                            e.orderId,
                                                                            e.customerId);
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
                                                                            Colors.white),
                                                                      ],
                                                                    ),
                                                                    style: ElevatedButton.styleFrom(
                                                                        primary:
                                                                            Style()
                                                                                .okColor,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(5))),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  right: 8, top: 8, bottom: 8),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width:
                                                        appDataModel.screenW *
                                                            0.35,
                                                    margin: EdgeInsets.only(
                                                        right: 10),
                                                    child: Column(
                                                      children: [
                                                        (e.status == "0" ||
                                                                e.status == "1")
                                                            ? Container()
                                                            : (e.status == "0")
                                                                ? Container()
                                                                : InkWell(
                                                                    onTap: () {
                                                                      appDataModel
                                                                              .orderDetailSelect =
                                                                          orderDetailFromJson(
                                                                              jsonEncode(e));
                                                                      appDataModel
                                                                              .userTypeSelect =
                                                                          "rider";
                                                                      appDataModel
                                                                              .orderIdSelected =
                                                                          e.orderId;
                                                                      Navigator.pushNamed(
                                                                          context,
                                                                          "/chat-page");
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      margin: EdgeInsets
                                                                          .only(
                                                                              top: 5),
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              10),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5),
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Icon(
                                                                              FontAwesomeIcons.facebookMessenger,
                                                                              size: 30,
                                                                              color: Colors.blue),
                                                                          Style().textBlackSize(
                                                                              " แชทกับลูกค้า",
                                                                              14),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 5),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: Colors.grey
                                                                  .shade300),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              (e.payType ==
                                                                      "cash")
                                                                  ? Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceAround,
                                                                      children: [
                                                                        Icon(
                                                                            FontAwesomeIcons
                                                                                .moneyBill,
                                                                            size:
                                                                                15,
                                                                            color:
                                                                                Colors.red),
                                                                        Style().textBlackSize(
                                                                            "   เงินสด",
                                                                            14),
                                                                      ],
                                                                    )
                                                                  : Row(
                                                                      children: [
                                                                        Icon(
                                                                            FontAwesomeIcons
                                                                                .wallet,
                                                                            size:
                                                                                15,
                                                                            color:
                                                                                Colors.orange),
                                                                        Style().textBlackSize(
                                                                            "   เครดิต",
                                                                            14),
                                                                      ],
                                                                    ),
                                                              Style().textBlackSize(
                                                                  ((_amount +
                                                                              _costDelivery -
                                                                              _discoubt))
                                                                          .toString() +
                                                                      " ฿",
                                                                  14),
                                                            ],
                                                          ),
                                                        ),
                                                        (e.costDelivery4Rider ==
                                                                null)
                                                            ? Container()
                                                            : Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 5),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                5),
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Icon(
                                                                          FontAwesomeIcons
                                                                              .handHoldingUsd,
                                                                          size:
                                                                              15,
                                                                          color: Colors
                                                                              .green
                                                                              .shade600,
                                                                        ),
                                                                        Style().textSizeColor(
                                                                            "   รายได้ ",
                                                                            16,
                                                                            Colors.green.shade600),
                                                                      ],
                                                                    ),
                                                                    Style().textSizeColor(
                                                                        _costDelivery4Rider.toString() +
                                                                            " ฿",
                                                                        14,
                                                                        Colors
                                                                            .green
                                                                            .shade600)
                                                                  ],
                                                                ),
                                                              ),
                                                        (e.orderType ==
                                                                "hotShop")
                                                            ? Container()
                                                            : Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 5,
                                                                        bottom:
                                                                            0),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                5),
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Style().textSizeColor(
                                                                        "$statusStr",
                                                                        12,
                                                                        textColors),
                                                                  ],
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                  (e.orderType == "hotShop")
                                                      ? Container(
                                                          width: appDataModel
                                                                  .screenW *
                                                              0.35,
                                                          child: Style()
                                                              .textFlexibleColorSize(
                                                                  '*เตรียมค่าสินค้า ' +
                                                                      e.amount +
                                                                      " ฿",
                                                                  2,
                                                                  14,
                                                                  Colors.red),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                        ],
                      ),
                      Row(
                        children: [
                          Style().textBlackSize(
                              e.startTime + " Order." + e.orderId, 12),
                        ],
                      )
                    ],
                  ),
          ),
        );
      }).toList(),
    );
  }

  _buildOrderAddress(AppDataModel appDataModel, OrderDetail e) {
    String _shopName = "";
    String _shopAddress = "";
    String _userName = "";

    for (var shop in _allShopData) {
      if (shop.shopUid == e.shopId) {
        _shopName = shop.shopName;
        _shopAddress = shop.shopAddress;
        break;
      }
    }

    for (var user in _userListModel) {
      if (user.uid == e.customerId) {
        _userName = user.name;
        break;
      }
    }
    return Container(
      width: appDataModel.screenW * 0.55,
      padding: EdgeInsets.only(left: 5, right: 5),
      child: Column(
        children: [
          Container(
              height: 220,
              child: Column(
                children: [
                  TimelineTile(
                    alignment: TimelineAlign.manual,
                    lineXY: 0.1,
                    isFirst: true,
                    indicatorStyle: IndicatorStyle(
                      width: 30,
                      color: Colors.green.shade800,
                      padding: const EdgeInsets.all(2),
                      iconStyle: IconStyle(
                        color: Colors.white,
                        iconData: (e.orderType == "gas")
                            ? Icons.local_gas_station
                            : Icons.store,
                      ),
                    ),
                    endChild: Container(
                        constraints: const BoxConstraints(
                          minHeight: 40,
                        ),
                        child: Container(
                          margin: EdgeInsets.only(left: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (e.orderType == "gas")
                                  ? Style().textBlackSize("เติมแก๊ส", 16)
                                  : Style().textBlackSize(_shopName, 16),
                              (_shopAddress == "")
                                  ? Container()
                                  : Style().textSizeColor(
                                      _shopAddress, 14, Colors.grey),
                            ],
                          ),
                        )),
                  ),
                  TimelineTile(
                    alignment: TimelineAlign.manual,
                    lineXY: 0.1,
                    indicatorStyle: IndicatorStyle(
                      width: 10,
                      color: Colors.black,
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                    ),
                    startChild: Container(
                      height: 10,
                    ),
                    endChild: Container(
                      child: Style().textBlackSize(e.distance + " กม.", 12),
                    ),
                  ),
                  TimelineTile(
                    alignment: TimelineAlign.manual,
                    lineXY: 0.1,
                    isLast: true,
                    indicatorStyle: IndicatorStyle(
                      width: 30,
                      color: Style().darkColor,
                      padding: const EdgeInsets.all(1),
                      iconStyle: IconStyle(
                          color: Colors.white,
                          iconData: Icons.location_history),
                    ),
                    endChild: Container(
                        constraints: const BoxConstraints(
                          minHeight: 30,
                        ),
                        child: Container(
                          margin: EdgeInsets.only(left: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Style().textBlackSize(_userName, 16),
                              (e.locationName == null)
                                  ? Container()
                                  : Style().textSizeColor(
                                      e.locationName, 14, Colors.grey),
                              (e.comment == null)
                                  ? Container()
                                  : Style()
                                      .textSizeColor(e.comment, 12, Colors.red),
                            ],
                          ),
                        )),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Future<List<MartListDetailModel>> _getMartDetail(String orderId) async {
    List<MartListDetailModel> _martDetailListData;
    if (_martDetailListData == null)
      await db
          .collection("orders")
          .doc(orderId)
          .collection("martDetail")
          .get()
          .then((value) {
        var jsonData = setList2Json(value);
        _martDetailListData = martListDetailModelFromJson(jsonData);
      });
    return _martDetailListData;
  }

  _buildOrderMartAddress(AppDataModel appDataModel, OrderDetail e,
      List<MartListDetailModel> martDetailList) {
    double boxSize = 250;
    double lineSize = (boxSize - 50) / (martDetailList.length + 2);
    String _userName = "";
    for (var user in _userListModel) {
      if (user.uid == e.customerId) {
        _userName = user.name;
        break;
      }
    }

    return Container(
      width: appDataModel.screenW * 0.55,
      padding: EdgeInsets.only(left: 5, right: 5),
      child: Column(
        children: [
          Container(
              height: boxSize,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TimelineTile(
                      alignment: TimelineAlign.manual,
                      lineXY: 0.1,
                      isFirst: true,
                      indicatorStyle: IndicatorStyle(
                        width: 30,
                        color: Colors.green.shade800,
                        padding: const EdgeInsets.all(1),
                        iconStyle: IconStyle(
                            color: Colors.white, iconData: Icons.motorcycle),
                      ),
                      startChild: Container(
                        height: lineSize,
                      ),
                      endChild: Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Style().textBlackSize(e.distance + " กม.", 14),
                      ),
                    ),
                    Column(
                      children: martDetailList.map((e) {
                        return TimelineTile(
                          alignment: TimelineAlign.manual,
                          lineXY: 0.1,
                          indicatorStyle: IndicatorStyle(
                            width: 10,
                            color: Colors.black,
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                          ),
                          startChild: Container(
                            height: lineSize,
                          ),
                          endChild: Container(
                            height: 20,
                            child: Style().textBlackSize(e.name, 12),
                          ),
                        );
                      }).toList(),
                    ),
                    TimelineTile(
                      alignment: TimelineAlign.manual,
                      lineXY: 0.1,
                      isLast: true,
                      indicatorStyle: IndicatorStyle(
                        width: 30,
                        color: Style().darkColor,
                        padding: const EdgeInsets.all(1),
                        iconStyle: IconStyle(
                            color: Colors.white,
                            iconData: Icons.location_history),
                      ),
                      startChild: Container(
                        height: lineSize,
                      ),
                      endChild: Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Style().textBlackSize(_userName, 14),
                            (e.locationName == null)
                                ? Container()
                                : Style().textBlackSize(e.locationName, 14)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  _orderSuccess(AppDataModel appDataModel, String orderId, distancs, payType,
      discount, customerId) async {
    setState(() {
      loading = true;
    });
    String finishTime = await getTimeStringNow();
    await db
        .collection("orders")
        .doc(orderId)
        .update({'status': '5', 'finishTime': finishTime}).then((value) async {
      String onlineTime = await getTimeStampNow();
      addLog(orderId, '5', 'driver', userOneModel.uid, '').then((value) async {
        await db.collection('drivers').doc(userOneModel.uid).update(
            {'driverStatus': '1', 'onlineTime': onlineTime}).then((value) {});
      });

      print("discountttt $discount");
      if (discount != "0") {
        var _riderCredit = await dbGetDataOne(
            "getRiderOne", "users", appDataModel.userOneModel.uid);
        if (_riderCredit[0]) {
          UserOneModel _driversModel = userOneModelFromJson(_riderCredit[1]);
          int _finalCredit =
              int.parse(_driversModel.credit) + int.parse(discount);
          await db
              .collection("users")
              .doc(appDataModel.userOneModel.uid)
              .update({"credit": _finalCredit.toString()});

          String _timeStamp = await getTimeStampNow();
          String _timeNow = await getTimeStringNow();
          CreditTransactionOneModel creditTransactionOneModel =
              CreditTransactionOneModel(
                  userId: appDataModel.userOneModel.uid,
                  date: _timeNow,
                  cmd: "add",
                  value: discount,
                  text: "ชดเชยส่วนลด order" + orderId);
          Map<String, dynamic> data = creditTransactionOneModel.toJson();
          await dbAddData(
              "addTranSection", "creditTransaction", _timeStamp, data);
        }
      }
    });

    await db.collection("users").doc(customerId).get().then((value) async {
      UserOneModel userOneModel =
          userOneModelFromJson(jsonEncode(value.data()));

      await notifySend(
          userOneModel.token, "จัดส่งสำเร็จ", "โปรดให้คะแนนร้านค้า และ Rider");
    });

    _setData(context.read<AppDataModel>());
  }

  _delivering(AppDataModel appDataModel, String orderId, customerId) async {
    setState(() {
      loading = true;
    });
    await db
        .collection('orders')
        .doc(orderId)
        .update({'status': '4'}).then((value) {
      addLog(orderId, '4', 'driver', userOneModel.uid, '').then((value) {});
    });
    await db.collection("users").doc(customerId).get().then((value) async {
      UserOneModel userOneModel =
          userOneModelFromJson(jsonEncode(value.data()));

      await notifySend(
          userOneModel.token, "Rider กำลังออกส่งสินค้า", "โปรดเตรียมรับสินค้า");
    });
    _setData(context.read<AppDataModel>());
  }

  _cancelOrder(AppDataModel appDataModel, String orderId, customerId, shopId,
      orderType) async {
    var result = await dialogs.inputDialog(
        context,
        Style().textSizeColor('เหตุผล', 16, Style().textColor),
        'ระบุเหตุผลที่ยกเลิก');
    if (result != null && result[0] == true) {
      setState(() {
        loading = true;
      });
      String onlineTime = await getTimeStampNow();
      String userToken;
      String shopToken;
      await db.collection("users").doc(customerId).get().then((value) {
        UserOneModel userOneModel =
            userOneModelFromJson(jsonEncode(value.data()));
        userToken = userOneModel.token;
      });
      if (orderType == null || orderType == "narmal")
        await db.collection("shops").doc(shopId).get().then((value) {
          ShopModel shopModel = shopModelFromJson(jsonEncode(value.data()));
          shopToken = shopModel.token;
        });
      await db.collection('orders').doc(orderId).get().then((value) async {
        OrderDetail orderDetail = orderDetailFromJson(jsonEncode(value.data()));
        if (orderDetail.status == '2' || orderDetail.status == '4') {
          if (result != null && result[0] == true) {
            await db
                .collection('orders')
                .doc(orderId)
                .update({'status': '6'}).then((value) async {
              addLog(orderId, '6', 'driver', userOneModel.uid, result[1])
                  .then((value) async {
                await db.collection('drivers').doc(userOneModel.uid).update({
                  'driverStatus': '1',
                  'onlineTime': onlineTime
                }).then((value) async {
                  await notifySend(shopToken, "Order ถูกยกเลิกโดย Rider",
                      "เหตุผล: " + result[1]);
                  await notifySend(userToken, "Order ถูกยกเลิกโดย Rider",
                      "เหตุผล: " + result[1]);
                  getDriverData = false;
                  _setData(context.read<AppDataModel>());
                });
              });
            });
          }
        } else {
          await dialogs.information(
              context,
              Style().textSizeColor('ผิดพลาด', 14, Style().textColor),
              Style().textSizeColor('ไม่สามารถยกเลิกได้โปรดลองใหม่ภายหลัง', 12,
                  Style().textColor));
          getDriverData = false;
          _setData(context.read<AppDataModel>());
        }
      });
    }
  }

  _confirmOrder(AppDataModel appDataModel, OrderList orderList) async {
    OrderDetail _orderOneDetail = orderDetailFromJson(jsonEncode(orderList));
    setState(() {
      loading = true;
    });
    int _finalRemovrCreditRider = 0;
    int _removeDelivery = 0;
    int _removeGp = 0;
    if (_orderOneDetail.orderType == "mart") {
      _removeDelivery = int.parse(_orderOneDetail.costDelivery) -
          int.parse(_orderOneDetail.costDelivery4Rider);
    } else if (_orderOneDetail.orderType == "gas") {
      _removeDelivery = int.parse(_orderOneDetail.costDelivery) -
          int.parse(_orderOneDetail.costDelivery4Rider);
    } else {
      if (productSetupModel.shareForApp != "0") {
        _removeDelivery = int.parse(_orderOneDetail.costDelivery) -
            int.parse(_orderOneDetail.costDelivery4Rider);
      }

      if (productSetupModel.gp != "0") {
        _removeGp = int.parse(_orderOneDetail.amount) -
            int.parse(_orderOneDetail.amountOri);
        String _timeStamp = await getTimeStampNow();
        String _timeNow = await getTimeStringNow();
        CreditTransactionOneModel creditTransactionOneModel =
            CreditTransactionOneModel(
                userId: appDataModel.userOneModel.uid,
                date: _timeNow,
                cmd: "remove",
                value: _removeGp.toString(),
                text: "GPสินค้า order." + _orderOneDetail.orderId);
        Map<String, dynamic> data = creditTransactionOneModel.toJson();
        await dbAddData(
            "addTranSection", "creditTransaction", _timeStamp, data);
      }
      _finalRemovrCreditRider = _removeDelivery + _removeGp;
    }

    print("order Id = " + _orderOneDetail.orderId);
    String userToken;
    String shopToken;

    await db
        .collection("users")
        .doc(_orderOneDetail.customerId)
        .get()
        .then((value) async {
      UserOneModel userOneModel =
          userOneModelFromJson(jsonEncode(value.data()));
      userToken = userOneModel.token;

      int _finalCredit =
          int.parse(userOneModel.credit) - _finalRemovrCreditRider;
      await db
          .collection("users")
          .doc(appDataModel.userOneModel.uid)
          .update({"credit": _finalCredit.toString()});

      String _timeStamp = await getTimeStampNow();
      String _timeNow = await getTimeStringNow();
      CreditTransactionOneModel creditTransactionOneModel =
          CreditTransactionOneModel(
              userId: appDataModel.userOneModel.uid,
              date: _timeNow,
              cmd: "remove",
              value: _removeDelivery.toString(),
              text: "%ค่าส่ง order." + _orderOneDetail.orderId);
      Map<String, dynamic> data = creditTransactionOneModel.toJson();
      await dbAddData("addTranSection", "creditTransaction", _timeStamp, data);
    });
    if (_orderOneDetail.orderType == null ||
        _orderOneDetail.orderType == "narmal") {
      await db
          .collection("shops")
          .doc(_orderOneDetail.shopId)
          .get()
          .then((value) {
        ShopModel shopModel = shopModelFromJson(jsonEncode(value.data()));
        shopToken = shopModel.token;
      });
    }

    await db
        .collection('drivers')
        .doc(appDataModel.userOneModel.uid)
        .get()
        .then((value) async {
      driversModel = driversModelFromJson(jsonEncode(value.data()));
      print('DriverStatusBefor Confirm = ' + driversModel.driverStatus);

      if (driversModel.driverStatus == "1" || appDataModel.loginLevel == "3") {
        db
            .collection('orders')
            .doc(_orderOneDetail.orderId)
            .get()
            .then((value) async {
          OrderDetail orderDetail =
              orderDetailFromJson(jsonEncode(value.data()));
          print('status = ' + orderDetail.status);
          if (orderDetail.status == '1') {
            print('change Status Success');
            await db
                .collection('orders')
                .doc(_orderOneDetail.orderId)
                .update({'status': '2', 'driver': userOneModel.uid}).then(
                    (value) async {
              await db
                  .collection("drivers")
                  .doc(userOneModel.uid)
                  .update({"driverStatus": "2"}).then((value) async {
                await addLog(_orderOneDetail.orderId, '2', 'driver',
                        userOneModel.uid, '')
                    .then((value) async {
                  inWork = true;
                  getDriverData = false;
                  await notifySend(
                      shopToken,
                      "ร้านค้า Order ใหม่โปรดเตรียมสินค้า",
                      "Order:" + _orderOneDetail.orderId);
                  await notifySend(userToken, "Riderตอบรับออเดอร์แล้ว ",
                      "Rider: " + driversModel.driverName);

                  _setData(context.read<AppDataModel>());
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
            _setData(context.read<AppDataModel>());
          }
        });
      } else {
        await Dialogs().information(
            context,
            Style().textBlackSize("รับ Order ไม่ได้", 14),
            Style().textBlackSize("คุณกำลังส่ง Order อื่นอยู่", 12));
        getDriverData = false;
        _setData(context.read<AppDataModel>());
      }
    });
  }

  _getTineNow() {
    String dateString = DateTime.now().millisecondsSinceEpoch.toString();
    return dateString;
  }
}
