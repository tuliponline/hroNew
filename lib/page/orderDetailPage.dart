import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/appStatusModel.dart';
import 'package:hro/model/cartModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/locationSetupModel.dart';

import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/addLog.dart';
import 'package:hro/utility/checkDriverOnline.dart';
import 'package:hro/utility/checkLocation.dart';
import 'package:hro/utility/getAddressName.dart';
import 'package:hro/utility/notifySend.dart';

import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class OrderDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OrderDetailState();
  }
}

class OrderDetailState extends State<OrderDetailPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  Dialogs dialogs = Dialogs();
  String addressComment;
  String addressName;

  int costDelivery;
  int amount;
  double lat, lng;

  String token;

  int riderOnline = 0;
  int riderFree = 0;

  bool checkRiderOnline = false;
  List<DriversListModel> driverListModel;

  AppStatusModel appStatusModel;
  bool customerOpen = false;
  String dateOpen = '';

  bool inService;
  LocationSetupModel locationSetup;
  double distanceFinal;
  String distanceString;

  String orderId;

  bool addingOrder = false;

  _getRiderOnline(AppDataModel appDataModel) async {
    riderOnline = 0;
    riderFree = 0;
    await FirebaseFirestore.instance
        .collection('appstatus')
        .doc('001')
        .get()
        .then((value) async {
      appStatusModel = appStatusModelFromJson(jsonEncode(value.data()));
      print("date Open = " + appStatusModel.dateopen);
      DateTime dateOpenRow = DateTime.parse(appStatusModel.dateopen);
      dateOpen = dateOpenRow.day.toString() +
          "/" +
          dateOpenRow.month.toString() +
          "/" +
          dateOpenRow.year.toString();

      (appStatusModel.customerOpen == "1")
          ? customerOpen = true
          : customerOpen = false;

      riderOnline = 0;
      await FirebaseFirestore.instance
          .collection('drivers')
          .get()
          .then((value) async {
        var jsonData = await setList2Json(value);
        driverListModel = driversListModelFromJson(jsonData);

        driverListModel.forEach((element) {
          DriversModel driversModel = driversModelFromJson(jsonEncode(element));
          if (driversModel.driverStatus == "1" ||
              driversModel.driverStatus == "2" ||
              driversModel.driverStatus == "9") {
            riderOnline += 1;
            if (driversModel.driverStatus == "1") riderFree += 1;
          }
        });

        print("riderOnline " + riderOnline.toString());
        print("riderFree " + riderFree.toString());

        _calData(context.read<AppDataModel>());
      });
    });
  }

  Future<Null> _calData(AppDataModel appDataModel) async {
    await _getLocationSetup(context.read<AppDataModel>());
    print("startCallData");

    lat = appDataModel.userLat;
    lng = appDataModel.userLng;

    addressName = await getAddressName(lat, lng);
    print("Get Now LocationCallData");
    inService = await checkLocationLimit(appDataModel.latStart,
        appDataModel.lngStart, lat, lng, appDataModel.distanceLimit);
    print("inService = " + inService.toString());
    amount = appDataModel.allPrice;
    int costPerKm;
    List<String> distanceAndCost = await calDistanceAndCostDelivery(
        appDataModel.latShop,
        appDataModel.lngShop,
        lat,
        lng,
        int.parse(locationSetup.distanceStart),
        int.parse(locationSetup.costDeliveryMin),
        int.parse(locationSetup.costDeliveryPerKm));
    distanceFinal = double.parse(distanceAndCost[0]);
    costPerKm = int.parse(distanceAndCost[1]);
    var distanceFormat = NumberFormat('#0.0#', 'en_US');
    distanceString = distanceFormat.format(distanceFinal);

    if (appDataModel.allPcs == 1) {
      costDelivery = costPerKm;
    } else {
      int pcs;
      int addCost;

      pcs = appDataModel.allPcs - 1;
      addCost =
          pcs * int.parse(appDataModel.locationSetupModel.costDeliveryPerPcs);
      costDelivery = costPerKm + addCost;
    }
    setState(() {
      checkRiderOnline = true;
    });
  }

  _getLocationSetup(AppDataModel appDataModel) async {
    await db.collection('appstatus').doc('locationSetup').get().then((value) {
      print("locationSetup" + jsonEncode(value.data()));
      var jsonData = jsonEncode(value.data());
      appDataModel.locationSetupModel = locationSetupModelFromJson(jsonData);
      List<String> locationLatLng =
          appDataModel.locationSetupModel.centerLocation.split(",");
      appDataModel.latStart = double.parse(locationLatLng[0]);
      appDataModel.lngStart = double.parse(locationLatLng[1]);
      appDataModel.distanceLimit =
          double.parse(appDataModel.locationSetupModel.distanceMax);
      locationSetup = appDataModel.locationSetupModel;
    });
  }

  _onlyCalData(AppDataModel appDataModel) async {
    int _allPcs = 0;
    int _allAmount = 0;

    appDataModel.currentOrder.forEach((element) {
      _allPcs += int.parse(element.pcs);
      _allAmount += (int.parse(element.pcs) * int.parse(element.price));
    });

    appDataModel.allPcs = _allPcs;
    appDataModel.allPrice = _allAmount;

    amount = appDataModel.allPrice;
    int costPerKm;
    List<String> distanceAndCost = await calDistanceAndCostDelivery(
        appDataModel.latShop,
        appDataModel.lngShop,
        lat,
        lng,
        int.parse(locationSetup.distanceStart),
        int.parse(locationSetup.costDeliveryMin),
        int.parse(locationSetup.costDeliveryPerKm));
    distanceFinal = double.parse(distanceAndCost[0]);
    costPerKm = int.parse(distanceAndCost[1]);
    var distanceFormat = NumberFormat('#0.0#', 'en_US');
    distanceString = distanceFormat.format(distanceFinal);

    if (appDataModel.allPcs == 1) {
      costDelivery = costPerKm;
    } else {
      int pcs;
      int addCost;

      pcs = appDataModel.allPcs - 1;
      addCost =
          pcs * int.parse(appDataModel.locationSetupModel.costDeliveryPerPcs);
      costDelivery = costPerKm + addCost;
    }
    if (_allPcs < 1) Navigator.pop(context);
    setState(() {
      checkRiderOnline = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (checkRiderOnline == false)
      _getRiderOnline(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Style().darkColor,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              body: Container(
                child: (addressName == null || addingOrder == true)
                    ? Center(child: Style().loading())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            buildAddressDetail(context.read<AppDataModel>()),
                            buildOrderDetail(context.read<AppDataModel>()),
                            Container(
                              width: appDataModel.screenW * 0.9,
                              child: (inService == false)
                                  ? ElevatedButton(
                                      onPressed: () async {
                                        //_getOrder(context.read<AppDataModel>());
                                      },
                                      child: Style().textBlackSize(
                                          "นอกพื้นที่ให้บริการ เกิน " +
                                              appDataModel.distanceLimit
                                                  .toString() +
                                              " กม. จากอากาศ",
                                          14),
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.yellow,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5))),
                                    )
                                  : (customerOpen == false)
                                      ? ElevatedButton(
                                          onPressed: () async {
                                            await checkDriverOnlineFunction()
                                                .then((value) {
                                              print(value);
                                            });
                                          },
                                          child: Style()
                                              .titleH3('ปิดให้บริการชั่วคราว'),
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.grey,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5))),
                                        )
                                      : (appDataModel.shopOpen == true)
                                          ? (riderOnline == 0)
                                              ? ElevatedButton(
                                                  onPressed: () {},
                                                  child: Style().textSizeColor(
                                                      'ไม่มี Rider Online โปรดสั่งใหม่ภายหลัง',
                                                      14,
                                                      Colors.white),
                                                  style: ElevatedButton.styleFrom(
                                                      primary: Colors.red,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5))),
                                                )
                                              : ElevatedButton(
                                                  onPressed: () async {
                                                    await checkDriverOnlineFunction()
                                                        .then((value) async {
                                                      if (value == true) {
                                                        if (riderFree > 0) {
                                                          var result = await Dialogs()
                                                              .confirm(
                                                                  context,
                                                                  "ยืนยันการสั่งซ์้อ",
                                                                  "ยืนยันการสั่งซื้อ Order ของคุณ");
                                                          if (result == true)
                                                            _addOrder(context.read<
                                                                AppDataModel>());
                                                        } else {
                                                          var result =
                                                              await Dialogs()
                                                                  .confirm(
                                                            context,
                                                            "Rider คิวเต็ม",
                                                            "ใช้เวลานานกว่าปกติ",
                                                          );
                                                          if (result != null &&
                                                              result == true)
                                                            _addOrder(context.read<
                                                                AppDataModel>());
                                                        }
                                                      } else {
                                                        dialogs.information(
                                                            context,
                                                            Style().textBlackSize(
                                                                "ไม่มี Rider Online",
                                                                16),
                                                            Style().textBlackSize(
                                                                "โปรดสั่งใหม่ภายหลัง",
                                                                16));
                                                      }
                                                    });

                                                    //_getOrder(context.read<AppDataModel>());
                                                  },
                                                  child: Style().titleH3(
                                                      'สั่งซื้อ ' +
                                                          (amount +
                                                                  costDelivery)
                                                              .toString() +
                                                          ' ฿'),
                                                  style: ElevatedButton.styleFrom(
                                                      primary:
                                                          Style().primaryColor,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5))),
                                                )
                                          : ElevatedButton(
                                              onPressed: () {},
                                              child: Style().titleH3(
                                                  'ร้านปิด ไม่สามารถสั่งอาหารได้'),
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors.grey,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5))),
                                            ),
                            ),
                          ],
                        ),
                      ),
              ),
            ));
  }

  Container buildOrderDetail(AppDataModel appDataModel) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 3),
      child: Column(
        children: [
          Container(
            child: Style().textSizeColor('สรุปรายการ', 16, Style().textColor),
          ),
          Container(
              margin: EdgeInsets.all(1),
              child: Divider(
                color: Colors.grey,
                height: 0,
              )),
          Column(
            children: appDataModel.currentOrder.map((e) {
              int index = appDataModel.currentOrder.indexOf(e);
              int pcs = int.parse(e.pcs);
              print('e = ' + e.productName);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      ListTile(
                        title: (e.productName?.isEmpty ?? true)
                            ? Text('')
                            : Style().textFlexibleBackSize(
                                (index + 1).toString() + ". " + e.productName,
                                2,
                                14,
                              ),
                        subtitle: (e.comment?.isEmpty ?? true)
                            ? null
                            : Style().textSizeColor(
                                e.comment, 12, Style().textColor),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(Icons.remove_circle,
                                      color: Colors.red, size: 20),
                                  onPressed: () => setState(() {
                                    if (pcs > 1) {
                                      final newValue = pcs - 1;
                                      appDataModel.currentOrder[index].pcs =
                                          newValue.clamp(1, 50).toString();
                                      _onlyCalData(appDataModel)(
                                          context.read<AppDataModel>());
                                    }
                                  }),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                  child: Style().textSizeColor(
                                      pcs.toString(), 12, Style().textColor),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() {
                                    final newValue = pcs + 1;
                                    appDataModel.currentOrder[index].pcs =
                                        newValue.clamp(1, 50).toString();
                                    _onlyCalData(appDataModel)(
                                        context.read<AppDataModel>());
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
                  Column(
                    children: [
                      Style().textSizeColor(
                          (int.parse(e.price) * int.parse(e.pcs)).toString() +
                              ' ฿',
                          14,
                          Style().textColor),
                      Style().textSizeColor(e.price + ' ฿/จำนวน x ' + e.pcs, 12,
                          Style().darkColor)
                    ],
                  ),
                  IconButton(
                      onPressed: () async {
                        var result = await Dialogs().confirm(
                            context, "ลบสินค้า", "ลบสิ้นค้าออกจาก Order");
                        if (result == true) {
                          appDataModel.currentOrder.removeAt(index);
                          _onlyCalData(context.read<AppDataModel>());
                        }
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.orange,
                        size: 20,
                      ))
                ],
              );
            }).toList(),
          ),
          Container(
              margin: EdgeInsets.all(1),
              child: Divider(
                color: Colors.grey,
                height: 0,
              )),
          Container(
            margin: EdgeInsets.only(top: 5),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Style().textSizeColor('ค่าสินค้า', 14, Style().textColor),
                    Style().textSizeColor('$amount ฿', 14, Style().textColor)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Style().textSizeColor('ค่าส่ง', 14, Style().textColor),
                        Style().textSizeColor(" (" + distanceString + ' กม.)',
                            10, Style().darkColor)
                      ],
                    ),
                    Style()
                        .textSizeColor('$costDelivery ฿', 14, Style().textColor)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Style().textSizeColor('รวม', 16, Style().textColor),
                    Style().textSizeColor(
                        (amount + costDelivery).toString() + ' ฿',
                        16,
                        Style().darkColor)
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Container buildAddressDetail(AppDataModel appDataModel) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 3),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Style().textSizeColor('จัดส่งที่', 16, Style().textColor),
          Row(
            children: [
              Icon(
                FontAwesomeIcons.mapMarkerAlt,
                color: Style().darkColor,
              ),
              Expanded(
                  child: ListTile(
                title: (addressName?.isEmpty ?? true)
                    ? Text('')
                    : Style().textFlexibleBackSize(addressName, 2, 14),
                subtitle: Style().textFlexibleBackSize(addressName, 2, 10),
              )),
              // IconButton(icon: Icon(Icons.navigate_next), onPressed: () {})
            ],
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Style()
                      .textSizeColor('ที่อยู่เพิ่มเติม', 14, Style().textColor),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                width: appDataModel.screenW * 0.9,
                height: 40,
                child: TextField(
                  style: TextStyle(fontSize: 14),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Style().labelColor)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Style().labelColor)),
                      hintText: 'ไม่ระบุก็ได้',
                      hintStyle: TextStyle(fontSize: 10, fontFamily: "prompt")),
                  onChanged: (value) {
                    addressComment = value;
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  _addOrder(AppDataModel appDataModel) async {
    addingOrder = true;
    setState(() {});

    List<CartModel> currentOrder;
    currentOrder = appDataModel.currentOrder;

    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('orders');

    var now = DateTime.now();
    String dateString = now.year.toString() +
        "/" +
        now.month.toString() +
        "/" +
        now.day.toString() +
        " " +
        now.hour.toString() +
        ':' +
        now.minute.toString();
    orderId = await _getTimeStamp();
    await collectionRef.doc(orderId).set({
      'comment': addressComment,
      'customerId': appDataModel.profileUid,
      'driver': '0',
      'location':
          appDataModel.latYou.toString() + ',' + appDataModel.lngYou.toString(),
      'orderId': orderId,
      'shopId': appDataModel.storeSelectId,
      'startTime': dateString,
      'inTime': '30',
      'finishTime': dateString,
      'status': '1',
      'distance': appDataModel.distanceDelivery,
      'amount': (amount).toString(),
      'costDelivery': (costDelivery).toString()
    }).then((value) async {
      int allTime = 0;
      int finalTime = 0;

      for (int i = 0; i < currentOrder.length; i++) {
        allTime +=
            (int.parse(currentOrder[i].time) * int.parse(currentOrder[i].pcs));
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .collection('product')
            .doc(currentOrder[i].productId)
            .set({
          'productId': currentOrder[i].productId,
          'comment': currentOrder[i].comment,
          'pcs': currentOrder[i].pcs,
          'price': currentOrder[i].price,
          'name': currentOrder[i].productName
        }).then((value) async {
          await addLog(orderId, '1', 'user', appDataModel.profileUid, '');
        });
      }

      await _getRider(context.read<AppDataModel>());

      finalTime = allTime + 15;
      await dialogs.information(
          context,
          Style().textSizeColor('สั่งสินค้าแล้ว', 16, Style().textColor),
          Style().textSizeColor(
              'โปรดรอรับการติดต่อจาก Rider', 14, Style().textColor));
      appDataModel.currentOrder = [];
      Navigator.pushNamedAndRemoveUntil(
          context, '/showHome-page', (route) => false);
    });
  }

  _getTimeStamp() {
    String dateString = DateTime.now().millisecondsSinceEpoch.toString();
    return dateString;
  }

  _getRider(AppDataModel appDataModel) async {
    db
        .collection("drivers")
        .where("driverStatus", isEqualTo: "1")
        .get()
        .then((value) async {
      var jsonData = setList2Json(value);
      List<DriversListModel> driversListModel =
          driversListModelFromJson(jsonData);
      driversListModel.forEach((element) async {
        await notifySend(
            element.token, "มี Order ใหม่ Rider", "Order:" + orderId);
      });
    });
  }
}
