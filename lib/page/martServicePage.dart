import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/CodeModel.dart';
import 'package:hro/model/MartSetupModel.dart';
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

class MartServicePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MartServiceState();
  }
}

class MartServiceState extends State<MartServicePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List _martDetailList = [];
  double _allDistancs = 0;
  int _costDelivery = 0;
  int _costDeliveryPerKm = 0;
  int _costDeliveryPerShop = 0;

  int _total = 0;
  MartSetupModel martSetupData;
  double userlat, userlng;
  String addressName;
  double screenW;
  String addressComment;

  bool codeDiscountStatus = false;
  String codeString = "ใส่โค้ดส่วนลด";
  int _discount = 0;
  CodeOneModel codeOneModel;
  double lat, lng;

  bool loading = false;

  List _distancsOnlyRow = [];
  List _costDeliveryOnlyRow = [];

  List finrRiderData;

  _getConfig(AppDataModel appDataModel) async {
    screenW = appDataModel.screenW;
    var _userLocation = appDataModel.userOneModel.location.split(",");
    userlat = double.parse(_userLocation[0]);
    userlng = double.parse(_userLocation[1]);
    addressName = await getAddressName(userlat, userlng);
    var _martSetup = await dbGetDataOne("getMartSetup", "martSetup", "001");
    if (_martSetup[0]) {
      var jsonData = _martSetup[1];
      martSetupData = martSetupModelFromJson(jsonData);
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
                  .textSizeColor("บริการฝากซื้อของ", 18, Style().darkColor),
            ),
            body: (loading)
                ? Center(child: Style().loading())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildMartDetail(),
                        (_martDetailList.length < 1)
                            ? Container()
                            : _buildTotal()
                      ],
                    ),
                  ),
            bottomNavigationBar: (_martDetailList.length < 1 || loading == true)
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
                              if (_martDetailList.length > 0) {
                                if (addressName != null) {
                                  var _conFirmOrder = await Dialogs().confirm(
                                      context,
                                      "เพิ่มคำสั่งซื้อ",
                                      "ยืนยันคำสั่งซื้อ ?");
                                  if (_conFirmOrder != null && _conFirmOrder)
                                    finrRiderData =
                                        await fineRiderOnlineStatus();

                                  if (finrRiderData[0] == 'offline') {
                                    Dialogs().information(
                                        context,
                                        Style().textBlackSize("ไม่พบRider", 16),
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
                                      _addToOrder(context.read<AppDataModel>());
                                    }
                                  } else {
                                    _addToOrder(context.read<AppDataModel>());
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
                                    msg: "ไม่มีรายการ",
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
                              child: Style().textSizeColor(
                                  "สั่งซื้อสินค้า", 16, Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
            // floatingActionButton: FloatingActionButton.extended(
            //   elevation: 4.0,
            //   // icon: const Icon(Icons.add),
            //   label: Style().textSizeColor("สั่งซื้อสินค้า", 16, Colors.white),
            //   onPressed: () async {},
            // )
            ));
  }

  _buildMartDetail() {
    return Container(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            child: Column(
              children: [
                Row(
                  children: [Style().textBlackSize("ร้านค้า และ รายการ", 18)],
                ),
                InkWell(
                  onTap: () async {
                    var _addMartDetail = await Navigator.pushNamed(
                        context, "/martServiceAddDetail-page");
                    print(_addMartDetail);
                    if (_addMartDetail != null) {
                      _martDetailList.add(_addMartDetail);
                      await _calTotol();
                      setState(() {});
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        color: Style().darkColor,
                      ),
                      Style().textSizeColor(
                          "เพิ่มร้านค้า และ รายการ", 14, Style().darkColor)
                    ],
                  ),
                )
              ],
            ),
          ),
          (_martDetailList == null)
              ? Container()
              : Column(
                  children: _martDetailList.map((e) {
                    int index = _martDetailList.indexOf(e);
                    MartDetailModel _martDetailData = e[0];
                    List<MartItemListModel> _martItemData = e[1];
                    print(_martDetailData);
                    return Container(
                      margin: EdgeInsets.all(1),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Style().textBlackSize(_martDetailData.name, 18),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _martItemData.map((e) {
                                  return Style().textSizeColor(
                                      e.itemName + " x " + e.pcs,
                                      14,
                                      Colors.grey);
                                }).toList(),
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
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
              Style().textBlackSize("รวมค่าบรการ", 16),
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
    List distancsAndCostList = [];

    for (var _martDetail in _martDetailList) {
      MartDetailModel _martDetailData = _martDetail[0];
      var _martLocation = _martDetailData.location.split(",");
      double _martLat = double.parse(_martLocation[0]);
      double _martLng = double.parse(_martLocation[1]);
      var _calCost = await calDistanceAndCostDelivery(
          userlat,
          userlng,
          _martLat,
          _martLng,
          int.parse(martSetupData.distancsStart),
          int.parse(martSetupData.costDeliveryStart),
          int.parse(martSetupData.costPerKm));
      distancsAndCostList.add(_calCost);
    }

    List _distancsOnly = [];
    List _costDeliveryOnly = [];

    distancsAndCostList.forEach((element) {
      _distancsOnly.add(element[0]);
      _costDeliveryOnly.add(element[1]);
    });

    _costDeliveryOnlyRow = _costDeliveryOnly;
    _distancsOnlyRow = _distancsOnly;
    // Sorting the list
    _distancsOnly.sort();
    _costDeliveryOnly.sort();

    if (_martDetailList.length > 1) {
      int _shopCount = _martDetailList.length - 1;
      _costDeliveryPerShop = _shopCount * int.parse(martSetupData.costPerShop);
    }

    int _allPcs = 0;
    for (var _martDetail in _martDetailList) {
      List<MartItemListModel> _martItemListModel = _martDetail[1];
      for (var _item in _martItemListModel) {
        _allPcs += int.parse(_item.pcs);
      }
    }
    _costDeliveryPerKm = (_allPcs - 1) * int.parse(martSetupData.costPerPcs);

    var distanceFinal = double.parse(_distancsOnly.last);
    var distanceFormat = NumberFormat('#0.0#', 'en_US');
    var distanceString = distanceFormat.format(distanceFinal);
    _allDistancs = double.parse(distanceString);
    _costDelivery = int.parse(_costDeliveryOnly.last) +
        _costDeliveryPerKm +
        _costDeliveryPerShop;
    _discount = 0;
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
        calPercen(_costDelivery, int.parse(martSetupData.shareForApp));
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
        orderType: "mart");
    Map<String, dynamic> data = orderDetail.toJson();

    var _addResult =
        await dbAddData("addMartOrder", "orders", _timeStamp, data);
    if (_addResult) {
      int i = 0;
      for (var _martList in _martDetailList) {
        MartDetailModel _martDetailData = _martList[0];
        _martDetailData.distanc = _distancsOnlyRow[i].toString();
        _martDetailData.cost = _costDeliveryOnlyRow[i].toString();
        List<MartItemListModel> _items = _martList[1];
        Map<String, dynamic> data = _martDetailData.toJson();
        await db
            .collection("orders")
            .doc(_timeStamp)
            .collection("martDetail")
            .doc(_martDetailData.id)
            .set(data)
            .then((value) async {
          int u = 1;
          for (var _item in _items) {
            Map<String, dynamic> _data = _item.toJson();
            await db
                .collection("orders")
                .doc(_timeStamp)
                .collection("martDetail")
                .doc(_martDetailData.id)
                .collection("martItem")
                .doc(u.toString())
                .set(_data)
                .then((value) {});
            u++;
          }
        });
        i++;
      }
      if (codeDiscountStatus) {
        String _timeStamp = await getTimeStampNow();
        CodeUseOneModel codeUseOneModel = CodeUseOneModel(
            id: _timeStamp,
            time: _timeNow,
            orderId: _timeStamp,
            code: codeOneModel.code,
            userId: appDataModel.profileUid,
            disCountValue: _discount.toString());
        Map<String, dynamic> data = codeUseOneModel.toJson();

        await dbAddData("addCodeUse", "codeUse", _timeStamp, data);

        int _stockCode = (int.parse(codeOneModel.stock) - 1);
        await dbUpdate("updateCodeStock", "code", codeString,
            {"stock": _stockCode.toString()});
      }

      List<DriversListModel> _riderData =
          driversListModelFromJson(finrRiderData[1]);
      for (var rider in _riderData) {
        if (rider.driverStatus == "1" || rider.driverStatus == "2") {
          await notifySend(
              rider.token, "Orderฝากซื้อของ ใหม่ Rider", "Order:" + _timeStamp);
        }
      }

      await Dialogs().information(
          context,
          Style().textBlackSize("สั่งซื้อสำเร็จ", 16),
          Style().textBlackSize("ได้รับ​ Orderแล้วโปรดรอRiderยืนยัน", 14));
      Navigator.pop(context, true);
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
              setState(() {});
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
