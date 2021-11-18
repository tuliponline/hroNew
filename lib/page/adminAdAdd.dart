import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/promoteListModel.dart';

import 'package:hro/utility/Dialogs.dart';

import 'package:hro/utility/getTimeNow.dart';
import 'package:hro/utility/style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

import 'fireBaseFunctions.dart';

class AddminAddAdPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AdminAddAdState();
  }
}

class AdminAddAdState extends State<AddminAddAdPage> {
  File file;
  final picker = ImagePicker();
  TextEditingController _adName = TextEditingController();
  TextEditingController _adLink = TextEditingController();
  String _shopId;
  String _shopType;
  var _shopSelect = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: AppBar(
                title: Style().textSizeColor("เพิ่มโฆษณา", 14, Colors.black),
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
                            if ((_adName.text?.isEmpty ?? true) ||
                                file == null) {
                              Dialogs().information(
                                context,
                                Style().textBlackSize("ข้อมูลไม่ครบ", 16),
                                Style().textBlackSize(
                                    "โปรดเลือกรูปภาพ หรือ กรอข้อมูลให้ครับ",
                                    16),
                              );
                            } else {
                              var result = await Dialogs().confirm(
                                  context,
                                  "เพิ่มโฆษณา",
                                  "ต้องการเพิ่มโฆษณา " + _adName.text);
                              if (result)
                                _saveDate(context.read<AppDataModel>());
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
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFrom(context.read<AppDataModel>()),
                    _buildAdName(context.read<AppDataModel>())
                  ],
                ),
              ),
            ));
  }

  _buildFrom(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Stack(children: [
        Container(
          margin: EdgeInsets.only(top: 48),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16.0)),
        ),
        Center(
          child: Container(
            height: (appDataModel.adAddType == 0)
                ? appDataModel.screenW * 0.4
                : appDataModel.screenW * 0.2,
            width: (appDataModel.adAddType == 0)
                ? appDataModel.screenW * 0.4
                : appDataModel.screenW * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(
                fit: BoxFit.fitWidth,
                image: (file == null)
                    ? AssetImage('assets/images/baner.jpg')
                    : FileImage(file),
              ),
            ),
            child: InkWell(
              onTap: () async {
                var result = await Dialogs().photoSelect(context);
                if (result == false) {
                  chooseImage(ImageSource.camera);
                } else if (result == true) {
                  chooseImage(ImageSource.gallery);
                }
              },
              child: Align(
                alignment: Alignment.bottomRight,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 12.0,
                  child: Icon(
                    Icons.camera_enhance,
                    size: 15.0,
                    color: Color(0xFF404040),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  _buildAdName(AppDataModel appDataModel) {
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
            Style().textSizeColor("ชื่อโฆษณา", 12, Colors.black),
            Container(
              margin: EdgeInsets.only(right: 5, bottom: 5, top: 5),
              width: appDataModel.screenW * 0.75,
              child: Container(
                alignment: Alignment.center,
                height: double.parse(textfieldw.toString()),
                child: TextField(
                  controller: _adName,
                  style: TextStyle(
                      fontFamily: "prompt", fontSize: 14, color: Colors.black),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                        left: 5,
                        bottom: textfieldw / 4, // HERE THE IMPORTANT PART
                      ),
                      hintText: 'ชื่อโฆษณา',
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
            Style().textSizeColor("Link", 12, Colors.black),
            Container(
              margin: EdgeInsets.only(right: 5, bottom: 5, top: 5),
              width: appDataModel.screenW * 0.75,
              child: Container(
                alignment: Alignment.center,
                height: double.parse(textfieldw.toString()),
                child: TextField(
                  controller: _adLink,
                  style: TextStyle(
                      fontFamily: "prompt", fontSize: 14, color: Colors.black),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                        left: 5,
                        bottom: textfieldw / 4, // HERE THE IMPORTANT PART
                      ),
                      hintText: 'Link',
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
          (appDataModel.adAddType != 0)
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Style().textSizeColor("ร้านค้า", 12, Colors.black),
                      Container(
                        margin: EdgeInsets.only(right: 5, bottom: 5, top: 5),
                        width: appDataModel.screenW * 0.75,
                        child: Container(
                          alignment: Alignment.center,
                          height: double.parse(textfieldw.toString()),
                          child: InkWell(
                            onTap: () async {
                              var _shopDataSelect = await Navigator.pushNamed(
                                  context, "/shopSelectOnly-page");
                              if (_shopDataSelect != null) {
                                _shopSelect = _shopDataSelect;
                                _shopType = _shopSelect[0];
                                _shopId = _shopSelect[1];
                                setState(() {});
                              }
                            },
                            child: Row(
                              children: [
                                (_shopSelect != null && _shopSelect.length > 0)
                                    ? Style().textBlackSize(_shopSelect[2], 14)
                                    : Style().textBlackSize("เลือกร้านค้า", 14),
                                Icon(Icons.navigate_next)
                              ],
                            ),
                          ),
                        ),
                      )
                    ]),
        ]));
  }

  _saveDate(AppDataModel appDataModel) async {
    String timeStamp = await getTimeStampNow();
    String _collection = "adsApp";

    String adId = await getTimeStampNow();
    final _firebaseStorage = FirebaseStorage.instance;
    var snapshot = await _firebaseStorage
        .ref()
        .child('/driversPhoto/$adId.jpg')
        .putFile(file);
    var downloadUrl = await snapshot.ref.getDownloadURL();
    PromoteOneModel promoteOneModel = PromoteOneModel(
      id: adId,
      name: _adName.text,
      status: "1",
      url: downloadUrl.toString(),
      link: _adLink.text,
    );
    Map<String, dynamic> data = promoteOneModel.toJson();

    await dbAddData("adPomote", _collection, adId, data);

    Navigator.pop(context, true);
  }

  Future<void> chooseImage(ImageSource imageSource) async {
    final pickedFile = await picker.pickImage(
        source: imageSource, maxWidth: 600, maxHeight: 600);

    setState(() {
      if (pickedFile != null) {
        file = File(pickedFile.path);
        print('image = ' + file.path.toString());
      } else {
        print('No image selected.');
      }
    });
  }
}
