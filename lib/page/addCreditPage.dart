import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/CreditAndPointMOdel.dart';
import 'package:hro/model/CreditTicketListMadel.dart';
import 'package:hro/model/CreditTicketModel.dart';
import 'package:hro/model/UserListMudel.dart';

import 'package:hro/model/UserOneModel.dart';
import 'package:hro/model/adminModel.dart';
import 'package:hro/model/bankAccountModel.dart';
import 'package:hro/page/fireBaseFunctions.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/addErrorLog.dart';
import 'package:hro/utility/addTransactionLog.dart';
import 'package:hro/utility/fineAdminToken.dart';
import 'package:hro/utility/getTimeNow.dart';
import 'package:hro/utility/notifySend.dart';

import 'package:hro/utility/regexText.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddCreditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddCreditState();
  }
}

class AddCreditState extends State<AddCreditPage> {
  BankAccountModel bankAccountModel;
  FirebaseFirestore db = FirebaseFirestore.instance;
  File file;
  final picker = ImagePicker();
  TextEditingController _amount = TextEditingController();

  double screenW = 0;
  String dateBank, timeBank;
  String smsLogId;
  bool loading = false;
  List<String> tokenList = [];

  _setData(AppDataModel appDataModel) async {
    await db.collection("kbankSms").get().then((value) {
      var jsonData = setList2Json(value);
      print("SMSData" + jsonData);
    });

    var _bankDb = await dbGetDataOne("getBank", "bankAccount", "001");
    if (_bankDb[0]) {
      bankAccountModel = bankAccountModelFromJson(_bankDb[1]);
    }

    screenW = appDataModel.screenW;

    await db
        .collection("users")
        .doc(appDataModel.userOneModel.uid)
        .get()
        .then((value) {
      appDataModel.userOneModel =
          userOneModelFromJson(jsonEncode(value.data()));
    });

    List<AdminListModel> _adminList;
    List<UserListModel> _userList;

    var _admindata = await dbGetDataAll("getAdmin", "admin");
    if (_admindata[0]) {
      var _jsonData = setList2Json(_admindata[1]);
      _adminList = adminListModelFromJson(_jsonData);
    }

    var _getAllUsrt = await dbGetDataAll("getUserAll", "users");
    if (_getAllUsrt[0]) {
      var jsonData = setList2Json(_getAllUsrt[1]);
      _userList = userListModelFromJson(jsonData);
    }

    for (var admin in _adminList) {
      for (var user in _userList) {
        if (user.email == admin.email) {
          tokenList.add(user.token);
          break;
        }
      }
    }

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
              appBar: (loading == true)
                  ? null
                  : AppBar(
                      title: Style().textBlackSize("เติมเครดิต", 16),
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
                      actions: [
                        Container(
                          margin: EdgeInsets.only(right: 10),
                          width: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (file != null &&
                                      _amount != null &&
                                      dateBank != null &&
                                      timeBank != null) {
                                    if (_amount.text.length > 0) {
                                      var checkCredit =
                                          onlyNumberRegex(_amount.text);
                                      if (checkCredit == true) {
                                        var result = await Dialogs().confirm(
                                            context,
                                            "แจ้งเติมเครดิต",
                                            "ยืนยันการเติมเครดิต " +
                                                _amount.text +
                                                "บาท");
                                        if (result == true) {
                                          if (bankAccountModel.status == "1") {
                                            var _haveData =
                                                await _checkHaveTicket(
                                                    context
                                                        .read<AppDataModel>(),
                                                    dateBank,
                                                    timeBank,
                                                    _amount.text);
                                            if (_haveData == false) {
                                              await _saveDate(
                                                  context.read<AppDataModel>());
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "มีการแจ้งเติมเครดิตนี้แล้ว",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.red,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0);
                                            }
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: "ปิดเติมเครติตชั่วคราว",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          }
                                        }
                                      } else {
                                        Fluttertoast.showToast(
                                            msg:
                                                "จำนวนเงินต้องเป็นจำนวนเต็ม และ มีทศนิยม",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "โปรดใส่จำนวนเงิน",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            "โปรดเลือกสลิป ใส่จำนวนเงิน และระบุวันที่",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  }
                                },
                                child: Style().textSizeColor(
                                    'แจ้งเติมเครติด', 14, Colors.white),
                                style: ElevatedButton.styleFrom(
                                    primary: Style().darkColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              body: (loading == true || bankAccountModel == null)
                  ? Center(child: Style().loading())
                  : Container(
                      child: SingleChildScrollView(
                        child: Column(children: [
                          _buildBankAccountNew(),
                          // _buildBankAccount(),

                          _buildAmount(context.read<AppDataModel>()),

                          _buildUploadSlip(context.read<AppDataModel>()),
                        ]),
                      ),
                    ),
            ));
  }

  _buildBankAccountNew() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child:
                      Style().textBlackSize("เติมเครดิตโดยการโอนเข้าบัญชี", 16),
                ),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Style()
                        .textBlackSize("ธนาคาร " + bankAccountModel.bank, 16)),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Style().textBlackSize(
                        "เลขที่ " + bankAccountModel.number, 16)),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  width: screenW * 0.8,
                  child: Style().textFlexibleColorSize(
                      "ชื่อ " + bankAccountModel.name, 2, 16, Colors.black),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _buildAmount(AppDataModel appDataModel) {
    int textfieldw = 40;
    return Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
        padding: EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Column(children: [
          Row(children: [
            // Style().textSizeColor("จำนวนเครดิต", 12, Colors.black),

            Container(
              margin: EdgeInsets.only(right: 5, bottom: 5, top: 5),
              width: appDataModel.screenW * 0.8,
              child: Container(
                alignment: Alignment.center,
                height: double.parse(textfieldw.toString()),
                child: TextField(
                  controller: _amount,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                      fontFamily: "prompt", fontSize: 14, color: Colors.black),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                        left: 5,
                        bottom: textfieldw / 4, // HERE THE IMPORTANT PART
                      ),
                      hintText: 'จำนวนเงิน',
                      hintStyle: TextStyle(
                        fontFamily: "prompt",
                        fontSize: 18,
                        color: Colors.grey,
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
          Column(children: [
            Row(children: [
              // Style().textSizeColor("จำนวนเครดิต", 12, Colors.black),

              Container(
                margin: EdgeInsets.only(right: 5, bottom: 5, top: 5),
                width: appDataModel.screenW * 0.7,
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Style().textBlackSize("วันที่ และ เวลา: ", 14),
                          (dateBank == null || timeBank == null)
                              ? Style().textBlackSize("โปรดระบุ", 14)
                              : Style()
                                  .textBlackSize("$dateBank $timeBank", 14),
                          InkWell(
                            onTap: () {
                              var dateNow = new DateTime.now();
                              var dateMin = new DateTime(
                                  dateNow.year, dateNow.month, dateNow.day - 3);
                              DatePicker.showDateTimePicker(context,
                                  showTitleActions: true,
                                  minTime: dateMin,
                                  maxTime: dateNow, onChanged: (date) {
                                print('change $date in time zone ' +
                                    date.timeZoneOffset.inHours.toString());
                              }, onConfirm: (date) {
                                print('confirm $date');

                                String finalmonth;
                                (date.month.toString().length == 1)
                                    ? finalmonth = "0" + date.month.toString()
                                    : finalmonth = date.month.toString();
                                String finalDay;
                                (date.day.toString().length == 1)
                                    ? finalDay = "0" + date.day.toString()
                                    : finalDay = date.day.toString();

                                var thaiyear =
                                    (int.parse(date.year.toString()) + 543)
                                        .toString();
                                thaiyear = thaiyear.substring(2);

                                dateBank = finalDay +
                                    "/" +
                                    finalmonth +
                                    "/" +
                                    thaiyear.toString();
                                String finalHour;
                                (date.hour.toString().length == 1)
                                    ? finalHour = "0" + date.hour.toString()
                                    : finalHour = date.hour.toString();
                                String finalminute;
                                (date.minute.toString().length == 1)
                                    ? finalminute = "0" + date.minute.toString()
                                    : finalminute = date.minute.toString();

                                timeBank = finalHour + ":" + finalminute;

                                print('confirm $dateBank');
                                setState(() {});
                              }, locale: LocaleType.th);
                            },
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: Style().darkColor,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ]),
            Style().textFlexibleColorSize(
                "โปรดระบุวันที่และเวลาที่แสดงบนสลิปธนาคาร", 10, 14, Colors.red)
          ])
        ]));
  }

  _buildUploadSlip(AppDataModel appDataModel) {
    return Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Column(children: [
          Container(
            margin: EdgeInsets.all(8),
            child: (file != null)
                ? Container(
                    height: appDataModel.screenW,
                    width: appDataModel.screenW * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: (file == null)
                            ? AssetImage('assets/images/slip.png')
                            : FileImage(file),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Style().textBlackSize("ยังไม่แนบสลิปธนาคาร", 16),
                    ],
                  ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    var result = await Dialogs().photoSelect(context);
                    if (result == false) {
                      chooseImage(ImageSource.camera);
                    } else if (result == true) {
                      chooseImage(ImageSource.gallery);
                    }
                  },
                  child:
                      Style().textSizeColor('แนบสลิปธนาคาร', 14, Colors.white),
                  style: ElevatedButton.styleFrom(
                      primary: Style().darkColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                ),
              ],
            ),
          ),
        ]));
  }

  _saveDate(AppDataModel appDataModel) async {
    loading = true;
    setState(() {});

    String timeStamp = await getTimeStampNow();
    String dateNow = await getTimeStringNow();
    final _firebaseStorage = FirebaseStorage.instance;
    var snapshot = await _firebaseStorage
        .ref()
        .child('/slipPhoto/slip$timeStamp.jpg')
        .putFile(file);
    var photoUrl = await snapshot.ref.getDownloadURL();

    if (photoUrl != null) {
      await addTransactionLog(
          appDataModel.userOneModel.uid,
          "addWaiting",
          "0",
          appDataModel.userOneModel.uid,
          _amount.text,
          "credit",
          "แจ้งเติมเครดิต (รอตรวจสอบ)",
          "");

      CreditTicketModel model = CreditTicketModel(
          id: timeStamp,
          uid: appDataModel.userOneModel.uid,
          photoUrl: photoUrl,
          value: _amount.text,
          date: dateNow,
          status: "3",
          comfirmBy: "0",
          comment: "",
          cmd: "add",
          bankAccount: "",
          bankName: "",
          bankUserName: "",
          befor: appDataModel.userOneModel.credit,
          after: "",
          dateBank: dateBank,
          timeBank: timeBank);
      Map<String, dynamic> data = model.toJson();
      db
          .collection('addCreditTicket')
          .doc(timeStamp)
          .set(data)
          .then((value) async {
        tokenList.forEach((eAdmin) async {
          await notifySend(eAdmin, "แจ้งเติมเครดิต",
              "คำขอมายเลข " + timeStamp + " โปรดตรวจสอบ");
        });

        await Dialogs().information(
          context,
          Style().textBlackSize("โปรดรอเจ้าหน้าที่ตรวจสอบ", 16),
          Style()
              .textBlackSize("แจ้งเติมเครดิตสำเร็จ โปรรอเจ้าหน้าที่ยืนยัน", 16),
        );
        Navigator.pop(context, true);
      });
    }
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

  Future<bool> _checkHaveTicket(
      AppDataModel appDataModel, String _date, _time, _amount) async {
    bool haveData = false;
    await db
        .collection("addCreditTicket")
        .where("uid", isEqualTo: appDataModel.userOneModel.uid)
        .where("dateBank", isEqualTo: _date)
        .where("timeBank", isEqualTo: _time)
        .where("value", isEqualTo: _amount)
        .get()
        .then((value) {
      var jsonData = setList2Json(value);
      List<CreditTicketListModel> creditTicketListModel =
          creditTicketListModelFromJson(jsonData);
      if (creditTicketListModel.length > 0) {
        haveData = true;
      } else {
        haveData = false;
      }
    }).catchError((onError) {
      haveData = false;
      print("onError $onError");
    });
    print(haveData);
    return haveData;
  }
}
