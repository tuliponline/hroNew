import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/codeModel.dart';

import 'package:hro/utility/fireBaseFunction.dart';

import 'package:hro/utility/getTimeNow.dart';

import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class addCodePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return addCodeState();
  }
}

class addCodeState extends State<addCodePage> {
  var _codeName = TextEditingController();
  var _code = TextEditingController();
  var _discount = TextEditingController();
  var _userLimit = TextEditingController();
  var _buyValueStart = TextEditingController();
  var _valueLimit = TextEditingController();
  var _stock = TextEditingController();

  CodeOneModel _codeOneModel;

  String _chosenType;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();

  _getData(AppDataModel appDataModel) async {
    if (appDataModel.codeTypeSelect == "edit") {
      var _codeBd =
          await dbGetDataOne("getCode", "code", appDataModel.codeIdSelect);
      if (_codeBd[0] == true) {
        _codeOneModel = codeOneModelFromJson(_codeBd[1]);
        _chosenType = _codeOneModel.type;
        if (_codeOneModel.type == "ส่งฟรี") {
          _chosenType = _codeOneModel.type;
          _codeName.text = _codeOneModel.name;
          _code.text = _codeOneModel.code;
          _discount.text = _codeOneModel.discount;
          _userLimit.text = _codeOneModel.useLimit;
          _buyValueStart.text = _codeOneModel.buyValueStart;
          _valueLimit.text = _codeOneModel.valueLimit;
          _stock.text = _codeOneModel.stock;
        } else {
          _chosenType = _codeOneModel.type;
          _codeName.text = _codeOneModel.name;
          _code.text = _codeOneModel.code;
          _discount.text = _codeOneModel.discount;
          _userLimit.text = _codeOneModel.useLimit;
          _buyValueStart.text = _codeOneModel.buyValueStart;
          _valueLimit.text = _codeOneModel.valueLimit;
          _stock.text = _codeOneModel.stock;
        }
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    _getData(context.read<AppDataModel>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              body: (loading == true)
                  ? Center(child: Style().loading())
                  : Container(
                      padding: EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [_buildDetail()],
                        ),
                      ),
                    ),
              floatingActionButton: FloatingActionButton.extended(
                elevation: 4.0,
                icon: (appDataModel.codeTypeSelect == "edit")
                    ? Icon(Icons.save)
                    : Icon(Icons.add),
                label: (appDataModel.codeTypeSelect == "edit")
                    ? Style().textSizeColor("บันทึก", 16, Colors.white)
                    : Style().textSizeColor("สรัาง Code", 16, Colors.white),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    if (appDataModel.codeTypeSelect == "edit") {
                      _saveCode();
                    } else {
                      _addCode();
                    }
                  }
                },
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: BottomAppBar(),
            ));
  }

  _buildDetail() {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              focusColor: Colors.white,
              value: _chosenType,
              //elevation: 5,
              style: TextStyle(color: Colors.white),
              iconEnabledColor: Colors.black,
              items: <String>[
                'ส่วนลด%',
                'ส่งฟรี',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              hint: Text(
                "ประเภท Code",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              onChanged: (String value) {
                setState(() {
                  _chosenType = value;
                });
              },
            ),
            TextFormField(
              controller: _codeName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'โปรดกรอกข้อมุลให้ครบ';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'ชื่อ Code',
              ),
            ),
            TextFormField(
              controller: _code,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'โปรดกรอกข้อมุลให้ครบ';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Code',
              ),
            ),
            (_chosenType == "ส่งฟรี")
                ? Container()
                : TextFormField(
                    controller: _discount,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'โปรดกรอกข้อมุลให้ครบ';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'ส่วนลด %',
                    ),
                  ),
            TextFormField(
              controller: _buyValueStart,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'โปรดกรอกข้อมุลให้ครบ';
                }
                return null;
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'ลดเมื่อซื้อครบ ฿',
              ),
            ),
            (_chosenType == "ส่งฟรี")
                ? Container()
                : TextFormField(
                    controller: _valueLimit,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'โปรดกรอกข้อมุลให้ครบ';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'ลดสูงสุด ฿',
                    ),
                  ),
            TextFormField(
              controller: _userLimit,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'โปรดกรอกข้อมุลให้ครบ';
                }
                return null;
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'จำนวนใช้งานต่อ User',
              ),
            ),
            TextFormField(
              controller: _stock,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'โปรดกรอกข้อมุลให้ครบ';
                }
                return null;
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'จำนวนใช้งานทั้งหมด',
              ),
            ),
          ],
        ),
      ),
    );
  }

  _addCode() async {
    String _timeStamp = await getTimeStampNow();

    CodeOneModel _codeOneModel = CodeOneModel(
        id: _timeStamp,
        name: _codeName.text,
        code: _code.text,
        discount: _discount.text,
        buyValueStart: _buyValueStart.text,
        valueLimit: _valueLimit.text,
        useLimit: _userLimit.text,
        stock: _stock.text,
        type: _chosenType,
        exp: "non",
        status: "1");

    Map<String, dynamic> data = _codeOneModel.toJson();

    var _adcodeDB = await dbAddData("addCode", "code", _code.text, data);
    if (_adcodeDB) {
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(
          msg: "ผิดพลาด โปรดลองใหม่อีกครั้ง",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  _saveCode() async {
    CodeOneModel _codeNew = _codeOneModel;

    _codeNew.name = _codeName.text;
    _codeNew.code = _code.text;
    _codeNew.discount = _discount.text;
    _codeNew.buyValueStart = _buyValueStart.text;
    _codeNew.valueLimit = _valueLimit.text;
    _codeNew.useLimit = _userLimit.text;
    _codeNew.stock = _stock.text;
    _codeNew.type = _chosenType;

    Map<String, dynamic> data = _codeNew.toJson();

    var _adcodeDB =
        await dbUpdate("updateCode", "code", _codeOneModel.id, data);
    if (_adcodeDB) {
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(
          msg: "ผิดพลาด โปรดลองใหม่อีกครั้ง",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
