import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/CodeModel.dart';

import 'package:hro/utility/Dialogs.dart';

import 'package:hro/utility/getTimeNow.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

import 'fireBaseFunctions.dart';

class AdminCodePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AdminCodeState();
  }
}

class AdminCodeState extends State<AdminCodePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<CodeListModel> codeListModel;
  var _textFildName = TextEditingController();
  var _textFildCode = TextEditingController();
  var _textFildDiscount = TextEditingController();
  var _textFildValueStart = TextEditingController();
  var _textFildValueLimit = TextEditingController();
  var _textFildUseLimit = TextEditingController();
  var _textFildStock = TextEditingController();

  String _type = "percent";
  String _status = "1";

  bool loading = false;
  String _cmdPage;

  _setData(AppDataModel appDataModel) async {
    loading = true;

    var dbData = await dbGetDataAll("AdmingetCode", "code");
    if (dbData != null && dbData[0] == true) {
      var jsonData = setList2Json(dbData[1]);
      codeListModel = codeListModelFromJson(jsonData);
      print(jsonData);
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _setData(context.read<AppDataModel>());
  }

  @override
  Widget build(BuildContext context) {
    _cmdPage = ModalRoute.of(context).settings.arguments;
    print(_cmdPage);
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: AppBar(
                title: Style().textSizeColor("Code ส่วนลด", 14, Colors.black),
                iconTheme: IconThemeData(color: Style().darkColor),
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                actions: [
                  IconButton(
                      onPressed: () async {
                        appDataModel.codeTypeSelect = "new";
                        var _addCode =
                            await Navigator.pushNamed(context, "/addCode-page");
                        if (_addCode != null && _addCode == true) {
                          _setData(context.read<AppDataModel>());
                        }
                      },
                      icon: Icon(FontAwesomeIcons.plusCircle))
                ],
              ),
              body: (codeListModel == null || loading == true)
                  ? Center(child: Style().loading())
                  : (codeListModel.length < 1)
                      ? Center(child: Style().textBlackSize("ไม่มีข้อมูล", 16))
                      : Container(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildDiscountList(context.read<AppDataModel>())
                              ],
                            ),
                          ),
                        ),
            ));
  }

  _buildDiscountList(AppDataModel appDataModel) {
    return Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        padding: EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Column(
            children: codeListModel.map((e) {
          return InkWell(
            onTap: () async {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Style().textSizeColor(
                            e.name + " (ส่วนลด " + e.discount + "%)",
                            14,
                            Colors.black),
                        IconButton(
                            onPressed: () async {
                              appDataModel.codeTypeSelect = "edit";
                              appDataModel.codeIdSelect = e.id;

                              var _addCode = await Navigator.pushNamed(
                                  context, "/addCode-page");
                              if (_addCode != null && _addCode == true) {
                                _setData(context.read<AppDataModel>());
                              }
                            },
                            icon: Icon(
                              Icons.edit,
                              color: Colors.orange,
                            ))
                      ],
                    ),
                    Style().textSizeColor(
                        "-ซื้อขั้นต่ำ " + e.buyValueStart + " ฿",
                        12,
                        Colors.black),
                    Style().textSizeColor(
                        "-ลดสูงสุด " + e.valueLimit + " ฿", 12, Colors.black),
                    Style().textSizeColor(
                        "-ใช้ได้ " + e.useLimit + " ครั้ง", 12, Colors.black),
                    Style()
                        .textSizeColor("-คงเหลือ " + e.stock, 12, Colors.red),
                  ],
                ),
                IconButton(
                    onPressed: () async {
                      _deleteCode(e.id);
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ))
              ],
            ),
          );
        }).toList()));
  }

  _inputDialog(
      BuildContext context,
      String title,
      String hinTextName,
      valuename,
      hinTextCode,
      valueCode,
      hinTextDiscount,
      valueDiscount,
      hinTextValueStart,
      valueStart,
      hinTextValueLimit,
      valueLimit,
      hinTextValueUseLimit,
      valueUseLimit,
      hinTextStock,
      valueStock,
      cmd) {
    _textFildName.text = "";
    if (valuename != "") {
      _textFildName.text = valuename;
    }
    _textFildCode.text = "";
    if (valueCode != "") {
      _textFildCode.text = valueCode;
    }
    _textFildDiscount.text = "";
    if (valueDiscount != "") {
      _textFildDiscount.text = valueDiscount;
    }
    _textFildValueStart.text = "";
    if (valueStart != "") {
      _textFildValueStart.text = valueStart;
    }
    _textFildValueLimit.text = "";
    if (valueLimit != "") {
      _textFildValueLimit.text = valueLimit;
    }
    _textFildUseLimit.text = "";
    if (valueUseLimit != "") {
      _textFildUseLimit.text = valueUseLimit;
    }
    _textFildStock.text = "";
    if (valueStock != "") {
      _textFildStock.text = valueStock;
    }
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Style().textBlackSize(title, 16),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  TextField(
                    decoration: InputDecoration(
                        hintText: hinTextName,
                        hintStyle:
                            TextStyle(fontFamily: 'BaiJamjuree', fontSize: 14)),
                    controller: _textFildName,
                  ),
                  Style().textSizeColor("ชื่อ", 10, Colors.black),
                  TextField(
                    enabled: (cmd == "new") ? true : false,
                    decoration: InputDecoration(
                        hintText: hinTextCode,
                        hintStyle:
                            TextStyle(fontFamily: 'BaiJamjuree', fontSize: 14)),
                    controller: _textFildCode,
                  ),
                  Style().textSizeColor("Code", 10, Colors.black),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: hinTextDiscount,
                        hintStyle:
                            TextStyle(fontFamily: 'BaiJamjuree', fontSize: 14)),
                    controller: _textFildDiscount,
                  ),
                  Row(
                    children: [
                      Style().textSizeColor("ส่วนลด", 10, Colors.black),
                      Style().textSizeColor(" (เป็น %)", 10, Colors.red),
                    ],
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: hinTextValueStart,
                        hintStyle:
                            TextStyle(fontFamily: 'BaiJamjuree', fontSize: 14)),
                    controller: _textFildValueStart,
                  ),
                  Style().textSizeColor("ลดเมื่อซื้อครบ", 10, Colors.black),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: hinTextValueLimit,
                        hintStyle:
                            TextStyle(fontFamily: 'BaiJamjuree', fontSize: 14)),
                    controller: _textFildValueLimit,
                  ),
                  Style().textSizeColor("ลดสูงสุด", 10, Colors.black),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: hinTextValueUseLimit,
                        hintStyle:
                            TextStyle(fontFamily: 'BaiJamjuree', fontSize: 14)),
                    controller: _textFildUseLimit,
                  ),
                  Style().textSizeColor("จำกัดการใช้Code/คน", 10, Colors.black),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: hinTextStock,
                        hintStyle:
                            TextStyle(fontFamily: 'BaiJamjuree', fontSize: 14)),
                    controller: _textFildStock,
                  ),
                  Style().textSizeColor("จำนวน Code", 10, Colors.black),
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
              TextButton(
                  onPressed: () {
                    if (_textFildName.text.length > 0) {
                      Navigator.pop(context,
                          [true, _textFildName.text, _textFildDiscount.text]);
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
                  child: Style().textBlackSize("ตกลง", 14)),
            ],
          );
        });
  }

  _addCode() async {
    if ((_textFildCode.text?.isEmpty ?? true) ||
        (_textFildDiscount.text?.isEmpty ?? true) ||
        (_textFildName.text?.isEmpty ?? true) ||
        (_textFildStock.text?.isEmpty ?? true) ||
        (_textFildUseLimit.text?.isEmpty ?? true) ||
        (_textFildValueLimit.text?.isEmpty ?? true) ||
        (_textFildValueStart.text?.isEmpty ?? true)) {
      await Dialogs().information(
          context,
          Style().textBlackSize("ข้อมูลไมครบ", 16),
          Style().textBlackSize("โปรดกรอกข้อมูลให้ครบ", 14));
    } else {
      var _getCode =
          await dbGetDataOne("checkHaveCode", "code", _textFildCode.text);
      if (_getCode[0]) {
        await Dialogs().information(
            context,
            Style().textBlackSize("โค้ดซ้ำ", 16),
            Style().textBlackSize("โปรดแก้ไขโค้ดใหม่", 14));
      } else {
        var _result = await Dialogs()
            .confirm(context, "เพิ่ม Code", "ต้องการเพิ่ม Code ?");
        if (_result != null && _result == true) {
          setState(() {
            loading = true;
          });

          CodeOneModel codeOneModel = CodeOneModel(
              buyValueStart: _textFildValueStart.text,
              code: _textFildCode.text,
              discount: _textFildDiscount.text,
              name: _textFildName.text,
              status: _status,
              stock: _textFildStock.text,
              type: _type,
              useLimit: _textFildUseLimit.text,
              valueLimit: _textFildValueLimit.text);
          Map<String, dynamic> data = codeOneModel.toJson();

          var _dbResult =
              await dbAddData("addNewCode", "code", _textFildCode.text, data);
          if (_dbResult) {
            _setData(context.read<AppDataModel>());
          }
        }
      }
    }
  }

  _deleteCode(String id) async {
    var _confirm =
        await Dialogs().confirm(context, "ลบ Code", "ต้องการลบCode ?");
    if (_confirm != null && _confirm == true) {
      var _dbResult = await dbDeleteData("adminDeleteCode", "code", id);
      if (_dbResult) {
        _setData(context.read<AppDataModel>());
      }
    }
  }
}
