import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/fireBaseFunction.dart';
import 'package:hro/utility/getAddressName.dart';
import 'package:hro/utility/getTimeNow.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class MartServiceAddDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MartServiceAddDetailState();
  }
}

class MartServiceAddDetailState extends State<MartServiceAddDetailPage> {
  var _martName = TextEditingController();
  var _listName = TextEditingController();
  int _itemCount = 1;

  _test() {
    setState(() {});
  }

  double martlat;
  double martlng;
  String adddressName;

  List _rowItemList = [];
  List<MartItemListModel> _itemListData;

  int _maxPcs = 10;
  int _allPcs = 0;
  @override
  Widget build(BuildContext context) {
    if (_itemListData != null && _itemListData.length > 0) _calAllPcs();
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                iconTheme: IconThemeData(color: Style().darkColor),
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                title: Style().textSizeColor("", 18, Style().darkColor),
              ),
              body: Container(
                padding: EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Column(
                    children: [_buildLocation(context.read<AppDataModel>())],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                elevation: 4.0,
                icon: const Icon(Icons.add),
                label:
                    Style().textSizeColor("เพิ่มใส่ตะกร้า", 16, Colors.white),
                onPressed: () async {
                  _addTocart();
                },
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: BottomAppBar(),
            ));
  }

  _buildLocation(AppDataModel appDataModel) {
    String addressString = "โปรดระบุตำแหน่ง";
    if (adddressName != null) {
      addressString = adddressName;
    }

    return Container(
      margin: EdgeInsets.only(top: 10),
      width: appDataModel.screenW,
      child: Column(
        children: [
          TextField(
            style: TextStyle(fontSize: 16),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                prefixIcon: Icon(
                  FontAwesomeIcons.store,
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Style().labelColor)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Style().labelColor)),
                hintText: "ชื่อร้าน หรือ สถานที่",
                hintStyle: TextStyle(fontSize: 16, fontFamily: 'Prompt')),
            controller: _martName,
            // onChanged: (value) => email = value.trim(),
          ),
          InkWell(
            onTap: () async {
              var result =
                  await Navigator.pushNamed(context, "/googleMap-page");
              if (result != null) {
                List latlngNew = result;
                martlat = latlngNew[0];
                martlng = latlngNew[1];
                adddressName = await getAddressName(martlat, martlng);

                setState(() {});
              }
            },
            child: Container(
              margin: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                          margin: EdgeInsets.only(right: 5),
                          child: Icon(
                            FontAwesomeIcons.mapMarkerAlt,
                            color: Colors.red,
                          )),
                      Container(
                          width: appDataModel.screenW * 0.7,
                          child: Style().textBlackSize(addressString, 16))
                    ],
                  ),
                  Icon(Icons.navigate_next)
                ],
              ),
            ),
          ),
          _buildProductDetail(context.read<AppDataModel>()),
        ],
      ),
    );
  }

  _buildProductDetail(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              (_itemListData == null)
                  ? Style().textSizeColor("0 รายการ (0 ชิ้น)", 16, Colors.black)
                  : Style().textSizeColor(
                      _itemListData.length.toString() +
                          " รายการ ($_allPcs ชิ้น)",
                      16,
                      Colors.black),
              InkWell(
                onTap: () async {
                  _listName.text = "";
                  _itemCount = 1;
                  var _result = await _inputDialog(context, "รายการ", "สินค้า");
                  if (_result != null) {
                    _rowItemList.add(jsonEncode(_result));

                    String _rowItemData = _rowItemList.toString();
                    _itemListData = martItemListModelFromJson(_rowItemData);

                    setState(() {});
                  }
                },
                child: Row(
                  children: [
                    Style().textSizeColor("เพิ่มรายการ", 14, Style().darkColor),
                    Icon(
                      Icons.add_circle,
                      color: Style().darkColor,
                    )
                  ],
                ),
              )
            ],
          ),
          (_itemListData == null)
              ? Container()
              : Container(
                  child: Column(
                    children: _itemListData.map((e) {
                      int index = _itemListData.indexOf(e);
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      width: appDataModel.screenW * 0.8,
                                      child: Style()
                                          .textBlackSize(e.itemName, 16)),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          int pcsNow = int.parse(e.pcs);
                                          if (pcsNow > 1) {
                                            pcsNow--;
                                            _itemListData[index].pcs =
                                                pcsNow.toString();
                                            setState(() {});
                                          }
                                        },
                                        child: Icon(
                                          Icons.remove,
                                          size: 15,
                                        ),
                                      ),
                                      Container(
                                          margin: EdgeInsets.only(
                                              left: 5, right: 5),
                                          child:
                                              Style().textBlackSize(e.pcs, 16)),
                                      InkWell(
                                        onTap: () {
                                          int pcsNow = int.parse(e.pcs);
                                          if (pcsNow < _maxPcs) {
                                            pcsNow++;
                                            _itemListData[index].pcs =
                                                pcsNow.toString();
                                            setState(() {});
                                          }
                                        },
                                        child: Icon(
                                          Icons.add,
                                          size: 15,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              IconButton(
                                  onPressed: () async {
                                    var _result = await Dialogs().confirm(
                                        context,
                                        "ลบราายการ",
                                        "ลบรายการ " + e.itemName + " ?");

                                    if (_result != null && _result) {
                                      _itemListData.removeAt(index);
                                      _rowItemList.removeAt(index);
                                      setState(() {});
                                    }
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ))
                            ]),
                      );
                    }).toList(),
                  ),
                )
        ],
      ),
    );
  }

  _inputDialog(BuildContext context, String title, String hinText) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Style().textBlackSize(title, 16),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                          hintText: hinText,
                          hintStyle: TextStyle(
                              fontFamily: 'BaiJamjuree', fontSize: 14)),
                      controller: _listName,
                      onChanged: (value) {},
                    ),
                    Container(
                        child: Row(
                      children: [
                        Style().textBlackSize("จำนวน", 14),
                        Row(
                          children: <Widget>[
                            IconButton(
                                icon: new Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  if (_itemCount > 1) {
                                    setState(() {
                                      _itemCount--;
                                    });
                                  }
                                }),
                            Text(_itemCount.toString()),
                            IconButton(
                                icon: new Icon(
                                  Icons.add_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  if (_itemCount < _maxPcs) {
                                    setState(() {
                                      _itemCount++;
                                    });
                                  }
                                })
                          ],
                        ),
                      ],
                    ))
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    child: Style().textBlackSize("ยกเลิก", 14)),
                Container(
                  width: 80,
                  child: ElevatedButton(
                      onPressed: () {
                        print(_listName);
                        if (_listName != null && _listName.text != "") {
                          MartItemOneModel martItemOneModel = MartItemOneModel(
                              itemName: _listName.text,
                              pcs: _itemCount.toString());
                          Navigator.pop(context, martItemOneModel);
                        } else {
                          Fluttertoast.showToast(
                              msg: "โปรดกรอกข้อมูล",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            size: 20,
                          ),
                          Style().textSizeColor("เพิ่ม", 14, Colors.white)
                        ],
                      )),
                )
              ],
            );
          });
        });
  }

  _calAllPcs() {
    _allPcs = 0;
    _itemListData.forEach((element) {
      int _pcs = int.parse(element.pcs);
      _allPcs += _pcs;
    });
  }

  _addTocart() async {
    if (_martName != null && _martName.text != "") {
      if (martlat != null && martlng != null) {
        if (_itemListData != null && _itemListData.length > -0) {
          String _timeStamp = await getTimeStampNow();
          String _location = martlat.toString() + "," + martlng.toString();
          print(_itemListData.length);
          MartDetailModel martDetailModel = MartDetailModel(
              id: _timeStamp, name: _martName.text, location: _location);
          Navigator.pop(context, [martDetailModel, _itemListData]);
        } else {
          Fluttertoast.showToast(
              msg: "ไม่มีรายการสินค้า โปรดเพิ่มรายการสินค้า",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        Fluttertoast.showToast(
            msg: "โปรดระบุตำแหน่งของร้าน หรือ สถานที่",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      Fluttertoast.showToast(
          msg: "โปรดระบุชื่อร้าน หรือ สถานที่",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
