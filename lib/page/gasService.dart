import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/CodeModel.dart';
import 'package:hro/model/GasSetupModel.dart';
import 'package:hro/model/codeUseModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/calPercen.dart';
import 'package:hro/utility/finrRider.dart';

import 'package:hro/utility/fireBaseFunction.dart';
import 'package:hro/utility/getAddressName.dart';
import 'package:hro/utility/getTimeNow.dart';
import 'package:hro/utility/notifySend.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GasServicePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GasServiceState();
  }
}

enum SingingCharacter { lafayette, jefferson }

class GasServiceState extends State<GasServicePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  double _allDistancs = 0;
  int _costDelivery = 0;
  int _total = 0;
  GasSetupModel gasSetupData;
  double userlat, userlng;
  String addressName;
  double screenW;
  String addressComment;
  bool loading = false;
  List finrRiderData;
  String gasSizeSelect;

  bool codeDiscountStatus = false;
  String codeString = "ใส่โค้ดส่วนลด";
  int _discount = 0;
  CodeOneModel codeOneModel;

  _getConfig(AppDataModel appDataModel) async {
    screenW = appDataModel.screenW;
    var _userLocation = appDataModel.userOneModel.location.split(",");
    userlat = double.parse(_userLocation[0]);
    userlng = double.parse(_userLocation[1]);
    addressName = await getAddressName(userlat, userlng);
    var _gasSetup = await dbGetDataOne("getGasSetup", "gasSetup", "001");
    if (_gasSetup[0]) {
      var jsonData = _gasSetup[1];
      gasSetupData = gasSetupModelFromJson(jsonData);
    }
  }

  @override
  void initState() {
    _getConfig(context.read<AppDataModel>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                      children: [_buildGasDetail(), _buildTotal()],
                    ),
                  ),
            bottomNavigationBar: (gasSizeSelect == null || loading == true)
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
                              Style().textBlackSize("ค่าบริการที่ต้องชำระ", 14),
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
                              if (gasSizeSelect != null) {
                                if (addressName != null) {
                                  var _conFirmOrder = await Dialogs().confirm(
                                      context,
                                      "เติมแก๊ส",
                                      "ยืนยันใช้บริการเติมแก็ส ?");
                                  if (_conFirmOrder != null && _conFirmOrder) {
                                    finrRiderData =
                                        await fineRiderOnlineStatus();

                                    if (finrRiderData[0] == 'offline') {
                                      Dialogs().information(
                                          context,
                                          Style()
                                              .textBlackSize("ไม่พบRider", 16),
                                          Style().textBlackSize(
                                              "ไม่มีRiderในพื้นที่ โปรดลองใหม่ภายหลัง",
                                              14));
                                    } else if (finrRiderData[0] == 'inwork') {
                                      var _confirmResult = await Dialogs().confirm(
                                          context,
                                          "ใช้เวลานานกว่าปกติ",
                                          "ขณะนี้มีคำสั่งซื้อจำนวนมาก การจัดส่งอาจล่าช้า");
                                      if (_confirmResult != null &&
                                          _confirmResult) {
                                        _addToOrder(
                                            context.read<AppDataModel>());
                                      }
                                    } else {
                                      _addToOrder(context.read<AppDataModel>());
                                    }
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "โปรดระบบสถานที่จัดส่ง",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: "โปรดเลือกขนาดถังแก๊ส",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Style().darkColor,
                              ),
                              child: Style()
                                  .textSizeColor("ยืนยัน", 16, Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )));
  }

  _buildGasDetail() {
    return Container(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            child: Column(
              children: [
                Row(
                  children: [Style().textBlackSize("เลือกขนาดถังแก๊ส", 18)],
                ),
                ListTile(
                  title: const Text('ถังเล็ก (ปิคนิค)'),
                  leading: Radio(
                    value: "small",
                    groupValue: gasSizeSelect,
                    onChanged: (value) {
                      gasSizeSelect = value;
                      _calTotol();
                    },
                  ),
                ),
                ListTile(
                  title: const Text('ถังทั่วไป (15กก.)'),
                  leading: Radio(
                    value: "big",
                    groupValue: gasSizeSelect,
                    onChanged: (value) {
                      gasSizeSelect = value;
                      _calTotol();
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
              var result =
                  await Navigator.pushNamed(context, "/googleMap-page");
              if (result != null) {
                List latlngNew = result;
                userlat = latlngNew[0];
                userlng = latlngNew[1];
                addressName = await getAddressName(userlat, userlng);
                await _calTotol();
                setState(() {});
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Style().textBlackSize("จัดส่งที่ ", 14),
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
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
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
                      hintText: 'ที่อยู่เพิ่มเติม (ไม่ระบุก็ได้)',
                      hintStyle: TextStyle(fontSize: 10, fontFamily: "Prompt")),
                  onChanged: (value) {
                    addressComment = value;
                  },
                ),
              )
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
          InkWell(
            onTap: () async {
              var _codeResult = await Dialogs().inputDialog(context,
                  Style().textBlackSize("โค้ดส่วนลด", 16), "กรอกโค้ดส่วนลด");
              if (_codeResult != null && _codeResult[0] == true) {
                _checkCode(_codeResult[1], context.read<AppDataModel>());
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Style().textBlackSize("$codeString ", 14),
                    Icon(
                      FontAwesomeIcons.tags,
                      size: 15,
                      color: Colors.orange,
                    )
                  ],
                ),
                Style().textBlackSize("- ฿ $_discount", 14)
              ],
            ),
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

  _calTotol() async {
    setState(() {
      loading = true;
    });
    var distancsAndCost;

    int costDeliveryStart = int.parse(gasSetupData.costServiceSmallStartl);

    (gasSizeSelect == "small")
        ? costDeliveryStart = int.parse(gasSetupData.costServiceSmallStartl)
        : costDeliveryStart = int.parse(gasSetupData.costServiceBigStart);

    var _gasLocation = gasSetupData.gasLocation.split(",");
    double _gasLat = double.parse(_gasLocation[0]);
    double _gasLng = double.parse(_gasLocation[1]);
    var _calCost = await calDistanceAndCostDelivery(
        userlat,
        userlng,
        _gasLat,
        _gasLng,
        int.parse(gasSetupData.startDistancs),
        costDeliveryStart,
        int.parse(gasSetupData.costPerKm));
    distancsAndCost = _calCost;

    var distanceFinal = double.parse(distancsAndCost[0]);
    var distanceFormat = NumberFormat('#0.0#', 'en_US');
    var distanceString = distanceFormat.format(distanceFinal);
    _allDistancs = double.parse(distanceString);
    _costDelivery = int.parse(distancsAndCost[1]);

    _total = _costDelivery - _discount;

    setState(() {
      loading = false;
    });
  }

  _addToOrder(AppDataModel appDataModel) async {
    setState(() {
      loading = true;
    });

    int _costPercen =
        calPercen(_costDelivery, int.parse(gasSetupData.shareForApp));
    int _costDelivery4Rider = _costDelivery - _costPercen;

    String _timeStamp = await getTimeStampNow();
    String _timeNow = getTimeStringNow();
    String _userLocation = "$userlat,$userlng";

    OrderDetail orderDetail = OrderDetail(
        finishTime: _timeNow,
        amount: "0",
        distance: _allDistancs.toString(),
        orderId: _timeStamp,
        costDelivery: _costDelivery.toString(),
        costDelivery4Rider: _costDelivery4Rider.toString(),
        inTime: "0",
        driver: "0",
        customerId: appDataModel.userOneModel.uid,
        comment: addressComment,
        startTime: _timeNow,
        location: _userLocation,
        locationName: addressName,
        shopId: null,
        status: "1",
        payType: "cash",
        discount: _discount.toString(),
        orderType: "gas");
    Map<String, dynamic> data = orderDetail.toJson();

    var _addResult =
        await dbAddData("addMartOrder", "orders", _timeStamp, data);
    if (_addResult) {
      List<DriversListModel> _riderData =
          driversListModelFromJson(finrRiderData[1]);
      print(finrRiderData[1]);
      for (var rider in _riderData) {
        if (rider.driverStatus == "1" || rider.driverStatus == "2") {
          await notifySend(
              rider.token, "Orderเติมแก๊ส ใหม่ Rider", "Order:" + _timeStamp);
        }
      }

      await Dialogs().information(context, Style().textBlackSize("สำเร็จ", 16),
          Style().textBlackSize("โปรดรอ Rider เข้าไปรับถังแก๊ส", 14));
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(
          msg: "ผิดหลาด โปรดลองใหม่อีกครั้ง",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  _checkCode(String code, AppDataModel appDataModel) async {
    var _getcodeUse = await dbGetDataAll("getCodeUse", "codeUse");
    var jsonData = setList2Json(_getcodeUse[1]);
    print(jsonData);

    var _getCode = await dbGetDataOne("orderGetCodeOne", 'code', code);
    if (_getCode[0]) {
      codeOneModel = codeOneModelFromJson(_getCode[1]);

      if (int.parse(codeOneModel.stock) > 0) {
        if (_costDelivery > int.parse(codeOneModel.buyValueStart)) {
          int _userUseCode = 0;
          int _userCodeLimit = int.parse(codeOneModel.useLimit);
          await db
              .collection("codeUse")
              .where("code", isEqualTo: codeOneModel.code)
              .where("userId", isEqualTo: appDataModel.userOneModel.uid)
              .get()
              .then((value) {
            var jsonData = setList2Json(value);
            List<CodeUseListModel> codeUseListModel =
                codeUseListModelFromJson(jsonData);
            _userUseCode = codeUseListModel.length;
          });

          print("_userUseCode $_userUseCode");
          print("_userCodeLimit $_userCodeLimit");

          if (_userUseCode < _userCodeLimit) {
            if (codeOneModel.type == "ส่งฟรี") {
              _discount = _costDelivery;

              codeDiscountStatus = true;
              codeString = codeOneModel.name;
              _calTotol();
            } else {
              Fluttertoast.showToast(
                  msg: "ไม่สามารถใช้กับบริการนี้ได้",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          } else {
            Fluttertoast.showToast(
                msg: "โค้ดถูกใช้งานครบแล้ว",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        } else {
          Fluttertoast.showToast(
              msg: "ยอดสั่งซื้อไม่ถึง",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        Fluttertoast.showToast(
            msg: "โค้ดนี้ถูกใช้หมดแล้ว",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      Fluttertoast.showToast(
          msg: "โค้ดไม่ถูกต้อง",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
