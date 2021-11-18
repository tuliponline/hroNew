import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/GasSetupModel.dart';
import 'package:hro/model/MartSetupModel.dart';
import 'package:hro/model/bankAccountModel.dart';
import 'package:hro/model/locationSetupModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/model/setupModel.dart';
import 'package:hro/page/fireBaseFunctions.dart';
import 'package:hro/utility/AppTheme.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/SizeConfig.dart';
import 'package:hro/utility/getAddressName.dart';

import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class AdminBankAccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AdminBankAccountState();
  }
}

class AdminBankAccountState extends State<AdminBankAccountPage> {
  ThemeData themeData = ThemeData.light();

  var _value = TextEditingController();

  bool loading = false;

  double screenW;

  BankAccountModel bankAccountModel;
  bool bankStatus = false;

  _getSetup(AppDataModel appDataModel) async {
    screenW = appDataModel.screenW;

    var _bankDb = await dbGetDataOne("getBankAccount", "bankAccount", "001");
    if (_bankDb[0]) {
      bankAccountModel = bankAccountModelFromJson(_bankDb[1]);
      if (bankAccountModel.status == "1") bankStatus = true;
    }

    setState(() {});
  }

  @override
  void initState() {
    _getSetup(context.read<AppDataModel>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              backgroundColor: themeData.scaffoldBackgroundColor,
              appBar: AppBar(
                iconTheme: IconThemeData(color: Style().darkColor),
                backgroundColor: themeData.scaffoldBackgroundColor,
                bottomOpacity: 0.0,
                elevation: 0.0,
                title: Style().textDarkAppbar("บัญชีธนาคาร"),
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios)),
                actions: [],
              ),
              body: (bankStatus == null)
                  ? Center(child: Style().loading())
                  : Container(
                      margin: EdgeInsets.only(left: 5),
                      child: ListView(
                        padding: EdgeInsets.all(8),
                        children: [
                          _buildFoodSeting(),
                        ],
                      ),
                    ),
            ));
  }

  _buildFoodSeting() {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 5, bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Style().textBlackSize("เติมเครดิต", 16),
                Switch(
                    activeColor: Style().darkColor,
                    value: bankStatus,
                    onChanged: (value) async {
                      String text = "";
                      String _status = "0";

                      if (value == true) {
                        text = "เปิดบริการเติมเครดิต";
                        _status = "1";
                      } else {
                        text = "ปิดบริการเติมเครดิต";
                        _status = "0";
                      }

                      var _result = await Dialogs()
                          .confirm(context, text, 'ยืนยัน $text');
                      if (_result == true) {
                        await dbUpdate("bankStatsu", "bankAccount", "001",
                            {"status": _status});

                        setState(() {
                          bankStatus = value;
                        });
                      }
                    })
              ],
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [Style().textBlackSize("ธนาคาร", 14)],
                    ),
                    Row(
                      children: [
                        Style().textBlackSize(bankAccountModel.bank, 16),
                        IconButton(
                            onPressed: () async {
                              var _result = await inputDialog(context, "ธนาคาร",
                                  "ธนาคาร", bankAccountModel.bank, "text");
                              if (_result[0]) {
                                setState(() {
                                  loading = true;
                                });
                                bankAccountModel.bank = _result[1];

                                await dbUpdate("updateBankAccount",
                                    "bankAccount", "001", {"bank": _result[1]});
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                            icon: Icon(Icons.navigate_next))
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [Style().textBlackSize("เลขบัญชี", 14)],
                    ),
                    Row(
                      children: [
                        Style().textBlackSize(bankAccountModel.number, 16),
                        IconButton(
                            onPressed: () async {
                              var _result = await inputDialog(
                                  context,
                                  "เลขบัญชี",
                                  "เลขบัญชี",
                                  bankAccountModel.number,
                                  "number");
                              if (_result[0]) {
                                setState(() {
                                  loading = true;
                                });
                                bankAccountModel.number = _result[1];

                                await dbUpdate(
                                    "updateBankAccount",
                                    "bankAccount",
                                    "001",
                                    {"number": _result[1]});
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                            icon: Icon(Icons.navigate_next))
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [Style().textBlackSize("ชื่อบัญชี", 14)],
                    ),
                    Row(
                      children: [
                        Style().textBlackSize(bankAccountModel.name, 16),
                        IconButton(
                            onPressed: () async {
                              var _result = await inputDialog(
                                  context,
                                  "ชื่อบัญชี",
                                  "ชื่อบัญชี",
                                  bankAccountModel.name,
                                  "text");
                              if (_result[0]) {
                                setState(() {
                                  loading = true;
                                });
                                bankAccountModel.name = _result[1];

                                await dbUpdate("updateBankAccount",
                                    "bankAccount", "001", {"name": _result[1]});
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                            icon: Icon(Icons.navigate_next))
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  inputDialog(BuildContext context, String title, String hinText, value, type) {
    _value.text = "";
    if (value != "") {
      _value.text = value;
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
                    keyboardType: (type == "text")
                        ? TextInputType.text
                        : TextInputType.number,
                    decoration: InputDecoration(
                        hintText: hinText,
                        hintStyle:
                            TextStyle(fontFamily: 'Prompt', fontSize: 14)),
                    controller: _value,
                  )
                ],
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context, [false, 'Prompt']);
                  },
                  child: Text('ยกเลิก')),
              FlatButton(
                  onPressed: () {
                    if (_value.text.length > 0) {
                      Navigator.pop(context, [true, _value.text]);
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
                  child: Text('ตกลง'))
            ],
          );
        });
  }
}
