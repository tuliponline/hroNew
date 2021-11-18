import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hro/model/AppDataModel.dart';

import 'package:hro/model/contactmodel.dart';

import 'package:hro/utility/Dialogs.dart';

import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class AdminContactDataPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AdminContactDataState();
  }
}

class AdminContactDataState extends State<AdminContactDataPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  TextEditingController _phone = TextEditingController();
  TextEditingController _Line = TextEditingController();

  double screenW;

  ContactModel contactModel;

  _setData(AppDataModel appDataModel) async {
    screenW = appDataModel.screenW;

    await db.collection("contactUs").doc("001").get().then((value) {
      contactModel = contactModelFromJson(jsonEncode(value.data()));

      _phone.text = contactModel.phone;
      _Line.text = contactModel.line;
    });

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _setData(context.read<AppDataModel>());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: AppBar(
                title: Style().textSizeColor("ช้อมูลติดต่อ", 14, Colors.black),
                iconTheme: IconThemeData(color: Style().darkColor),
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                actions: [
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    width: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if ((_phone.text?.isEmpty ?? true) ||
                                (_Line.text?.isEmpty ?? true)) {
                              Fluttertoast.showToast(
                                  msg: "โปรดกรอกข้อมูลให้ครบ",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else {
                              var result = await Dialogs().confirm(context,
                                  "บันทึกข้อมูล", "บันทึกข้อมูลการติดต่อ");
                              if (result)
                                _saveData(context.read<AppDataModel>());
                            }
                          },
                          child:
                              Style().textSizeColor('บันทึก', 14, Colors.white),
                          style: ElevatedButton.styleFrom(
                              primary: Style().darkColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              body: Container(
                child: SingleChildScrollView(
                  child: Column(children: [
                    _buildFerom(context.read<AppDataModel>()),
                  ]),
                ),
              ),
            ));
  }

  _buildFerom(AppDataModel appDataModel) {
    int textfieldw = 40;
    return Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        padding: EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Style().textSizeColor("เบอร์โทรติดต่อ", 12, Colors.black),
            Container(
              margin: EdgeInsets.only(right: 5, bottom: 5, top: 5),
              width: screenW * 0.4,
              child: Container(
                alignment: Alignment.center,
                height: double.parse(textfieldw.toString()),
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _phone,
                  style: TextStyle(
                      fontFamily: "prompt", fontSize: 14, color: Colors.black),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                        left: 5,
                        bottom: textfieldw / 4, // HERE THE IMPORTANT PART
                      ),
                      hintText: 'เบอร์โทรติดต่อ',
                      hintStyle: TextStyle(
                        fontFamily: "prompt",
                        fontSize: 14,
                        color: Colors.orange,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          borderSide:
                              BorderSide(color: Colors.black, width: 0.5)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          borderSide:
                              BorderSide(color: Colors.black, width: 0.5)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          borderSide:
                              BorderSide(color: Colors.black, width: 0.5)),
                      // suffixIcon:
                      //     Style().textSizeColor("km.", 20, Colors.black),
                      // suffixIconConstraints: BoxConstraints(
                      //   minHeight: 32,
                      //   minWidth: 32,
                      // ),
                      filled: true,
                      fillColor: Colors.white),
                ),
              ),
            )
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Style().textSizeColor("Line", 12, Colors.black),
            Container(
              margin: EdgeInsets.only(right: 5, bottom: 5, top: 5),
              width: screenW * 0.4,
              child: Container(
                alignment: Alignment.center,
                height: double.parse(textfieldw.toString()),
                child: TextField(
                  controller: _Line,
                  style: TextStyle(
                      fontFamily: "Line Id", fontSize: 14, color: Colors.black),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                        left: 5,
                        bottom: textfieldw / 4, // HERE THE IMPORTANT PART
                      ),
                      hintText: 'Line Id',
                      hintStyle: TextStyle(
                        fontFamily: "prompt",
                        fontSize: 14,
                        color: Colors.orange,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          borderSide:
                              BorderSide(color: Colors.black, width: 0.5)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          borderSide:
                              BorderSide(color: Colors.black, width: 0.5)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          borderSide:
                              BorderSide(color: Colors.black, width: 0.5)),
                      // suffixIcon:
                      //     Style().textSizeColor("km.", 20, Colors.black),
                      // suffixIconConstraints: BoxConstraints(
                      //   minHeight: 32,
                      //   minWidth: 32,
                      // ),
                      filled: true,
                      fillColor: Colors.white),
                ),
              ),
            )
          ]),
        ]));
  }

  _saveData(AppDataModel appDataModel) async {
    await db
        .collection("contactUs")
        .doc("001")
        .update({"phone": _phone.text, "line": _Line.text}).then((value) {
      Fluttertoast.showToast(
          msg: "บันทึกข้อมูลสำเร็จ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      _setData(context.read<AppDataModel>());
    });
  }
}
