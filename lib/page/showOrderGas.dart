import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/GasSetupModel.dart';
import 'package:hro/model/UserOneModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/addLog.dart';
import 'package:hro/utility/calPercen.dart';
import 'package:hro/utility/callNumber.dart';
import 'package:hro/utility/finrRider.dart';

import 'package:hro/utility/fireBaseFunction.dart';
import 'package:hro/utility/getAddressName.dart';
import 'package:hro/utility/getTimeNow.dart';
import 'package:hro/utility/notifySend.dart';
import 'package:hro/utility/style.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:url_launcher/url_launcher.dart';

class ShowOrderGasPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ShowOrderGasState();
  }
}

class ShowOrderGasState extends State<ShowOrderGasPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  double _allDistancs = 0;
  int _costDelivery = 0;
  int _discount = 0;
  int _total = 0;

  double userlat, userlng;
  String addressName;
  double screenW;
  String addressComment;
  bool loading = false;
  List finrRiderData;
  String gasSizeSelect;

  OrderDetail orderDetail;
  List<MartListDetailModel> martListDetailModel;

  String whoUse = "user";

  DriversModel riderDetail;
  UserOneModel userDetail;

  _getConfig(AppDataModel appDataModel) async {
    screenW = appDataModel.screenW;
    orderDetail = appDataModel.orderDetailSelect;
    gasSizeSelect = "small";
    if (orderDetail.shopId != null && orderDetail.shopId == "big") {
      gasSizeSelect = "big";
    }

    if (orderDetail.driver != null && orderDetail.driver != "0") {
      await db
          .collection("drivers")
          .doc(orderDetail.driver)
          .get()
          .then((value) {
        var jsonData = jsonEncode(value.data());
        riderDetail = driversModelFromJson(jsonData);
      });
    }

    await db
        .collection("users")
        .doc(orderDetail.customerId)
        .get()
        .then((value) {
      var jsonData = jsonEncode(value.data());
      userDetail = userOneModelFromJson(jsonData);
    });

    _allDistancs = double.parse(orderDetail.distance);
    _costDelivery = int.parse(orderDetail.costDelivery);
    _discount = int.parse(orderDetail.discount);
    _total = int.parse(orderDetail.amount) + _costDelivery;

    addressComment = orderDetail.comment;
    var _userLocation = appDataModel.userOneModel.location.split(",");
    userlat = double.parse(_userLocation[0]);
    userlng = double.parse(_userLocation[1]);
    addressName = await getAddressName(userlat, userlng);

    setState(() {});
  }

  @override
  void initState() {
    _getConfig(context.read<AppDataModel>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    whoUse = ModalRoute.of(context).settings.arguments;
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Style().darkColor),
              backgroundColor: Colors.white,
              bottomOpacity: 0.0,
              elevation: 0.0,
              title: Style()
                  .textSizeColor("บริการเติมแก๊ส", 18, Style().darkColor),
            ),
            body: (loading)
                ? Center(child: Style().loading())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        (whoUse == "rider")
                            ? _buildCustomer(context.read<AppDataModel>())
                            : (whoUse == "user")
                                ? _buildRider(context.read<AppDataModel>())
                                : Column(children: [
                                    _buildCustomer(
                                        context.read<AppDataModel>()),
                                    _buildRider(context.read<AppDataModel>())
                                  ]),
                        _buildGasDetail(),
                        _buildTotal()
                      ],
                    ),
                  ),
            bottomNavigationBar: (orderDetail.status != "1" ||
                    loading ||
                    whoUse != "user")
                ? null
                : Container(
                    height: 56,
                    margin: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          width: appDataModel.screenW * 0.6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Style().textBlackSize(
                                  "ค่าบริการที่ต้องชำระ (ไม่รวมค่าสินค้า)", 14),
                              Text("฿ $_total",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18))
                            ],
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              var result = await Dialogs().inputDialog(
                                  context,
                                  Style().textBlackSize('ยกเลิก Order', 14),
                                  'โปรดระบุเหตุผล');
                              print(result[0]);
                              if (result[0] == true) {
                                setState(() {
                                  loading = true;
                                });

                                await db
                                    .collection('orders')
                                    .doc(orderDetail.orderId)
                                    .update({'status': '0'}).then(
                                        (value) async {
                                  await addLog(orderDetail.orderId, '0', 'user',
                                          appDataModel.profileUid, result[1])
                                      .then((value) {
                                    Navigator.pop(context, 'reload');
                                  }).catchError((onError) {
                                    print('addLogError = $onError');
                                  });
                                }).catchError((onError) {
                                  print('ChangeStatusError = $onError');
                                });
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.red,
                              ),
                              child: Style()
                                  .textSizeColor("ยกเลิก", 16, Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )));
  }

  _buildGasDetail() {
    String gsaSize = 'ถังเล็ก (ปิคนิค)';
    if (orderDetail.shopId != null) {
      if (orderDetail.shopId == "small") {
        gsaSize = 'ถังเล็ก (ปิคนิค)';
      }
      if (orderDetail.shopId == "small") {
        gsaSize = 'ถังทั่วไป (15กก.)';
      }
    }

    return Container(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Style().textBlackSize("Order. " + orderDetail.orderId, 14)
                  ],
                ),
                Row(
                  children: [Style().textBlackSize("ขนาดถังแก๊ส", 18)],
                ),
                ListTile(
                  title: Text(gsaSize),
                  leading: Radio(
                    value: "small",
                    groupValue: gasSizeSelect,
                    onChanged: (value) {
                      gasSizeSelect = value;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildTotal() {
    String addressString = "โปรดระบุสถานที่จัดส่ง";
    if (addressName != null) addressString = addressName;

    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              _openOnGoogleMapApp(userlat, userlng);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Style().textBlackSize("สถานที่ ", 14),
                    Icon(
                      FontAwesomeIcons.mapMarkerAlt,
                      size: 15,
                      color: Colors.red,
                    ),
                    Container(
                        width: screenW * 0.7,
                        child: Style().textBlackSize(addressString, 14)),
                  ],
                ),
                Icon(FontAwesomeIcons.caretDown)
              ],
            ),
          ),
          (orderDetail.comment == null)
              ? Container()
              : Row(
                  children: [
                    Style().textSizeColor(orderDetail.comment, 14, Colors.red),
                  ],
                ),
          Style().underLine(),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Style().textBlackSize("ระยะทาง", 14),
                Style().textBlackSize("$_allDistancs กม.", 14)
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Style().textBlackSize("ค่าส่ง", 14),
              Style().textBlackSize("฿ $_costDelivery", 14)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Style().textBlackSize("ส่วนลด ", 14),
                ],
              ),
              Style().textBlackSize("- ฿ $_discount", 14)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Style().textBlackSize("รวมค่าบริการ", 16),
              Text("฿ $_total",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18))
            ],
          )
        ],
      ),
    );
  }

  _buildRider(AppDataModel appDataModel) {
    return (riderDetail == null ||
            orderDetail.driver == null ||
            orderDetail.driver == "0")
        ? Container()
        : Container(
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.only(top: 3),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.all(3),
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(riderDetail.driverPhotoUrl),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Style().textBlackSize("ช้อมูล Rider", 14),
                            Style().textBlackSize(riderDetail.driverName, 14),
                            Style().textBlackSize(riderDetail.driverPhone, 10),
                          ],
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Style().textBlackSize("โทร", 14),
                            IconButton(
                                onPressed: () {
                                  callNumber(riderDetail.driverPhone);
                                },
                                icon: Icon(
                                  Icons.call,
                                  color: Style().darkColor,
                                )),
                          ],
                        ),
                        (orderDetail.status == "1" || orderDetail.status == "1")
                            ? Container()
                            : Row(
                                children: [
                                  Style().textBlackSize("แชต", 14),
                                  IconButton(
                                      onPressed: () {
                                        appDataModel.orderDetailSelect =
                                            orderDetail;
                                        appDataModel.userTypeSelect = "user";
                                        appDataModel.orderIdSelected =
                                            orderDetail.orderId;
                                        Navigator.pushNamed(
                                            context, "/chat-page");
                                      },
                                      icon: Icon(
                                        FontAwesomeIcons.facebookMessenger,
                                        color: Style().darkColor,
                                      )),
                                ],
                              ),
                      ],
                    )
                  ],
                )
              ],
            ));
  }

  _buildCustomer(AppDataModel appDataModel) {
    return (userDetail == null)
        ? Container()
        : Container(
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.only(top: 3),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.all(3),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(userDetail.photoUrl),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Style().textBlackSize("ช้อมูล ลูกค้า", 14),
                            Style().textBlackSize(userDetail.name, 14),
                            Style().textBlackSize(userDetail.phone, 10),
                          ],
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Style().textBlackSize("โทร", 14),
                            IconButton(
                                onPressed: () {
                                  callNumber(userDetail.phone);
                                },
                                icon: Icon(
                                  Icons.call,
                                  color: Style().darkColor,
                                )),
                          ],
                        ),
                        (orderDetail.status == "1" || orderDetail.status == "1")
                            ? Container()
                            : Row(
                                children: [
                                  Style().textBlackSize("แชต", 14),
                                  IconButton(
                                      onPressed: () {
                                        appDataModel.orderDetailSelect =
                                            orderDetail;
                                        appDataModel.userTypeSelect = "rider";
                                        appDataModel.orderIdSelected =
                                            orderDetail.orderId;
                                        Navigator.pushNamed(
                                            context, "/chat-page");
                                      },
                                      icon: Icon(
                                        FontAwesomeIcons.facebookMessenger,
                                        color: Style().darkColor,
                                      )),
                                ],
                              ),
                      ],
                    )
                  ],
                )
              ],
            ));
  }

  _openOnGoogleMapApp(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      // Could not open the map.
    }
  }
}
