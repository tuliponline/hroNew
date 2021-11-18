import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';

import 'package:hro/model/UserOneModel.dart';
import 'package:hro/model/creditTransectionModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/getTimeNow.dart';
import 'package:hro/utility/notifySend.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

class CreditTransactionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CreditTransactionState();
  }
}

class CreditTransactionState extends State<CreditTransactionPage> {
  final oCcy = new NumberFormat("#,##0", "en_US");
  FirebaseFirestore db = FirebaseFirestore.instance;
  UserOneModel userOneModel;
  List<CreditTransactionListModel> creditTransactions;
  TextEditingController _withdraw = TextEditingController();

  TextEditingController _bankAccount = TextEditingController();
  TextEditingController _bankUserName = TextEditingController();
  TextEditingController _bankName = TextEditingController();

  _setData(AppDataModel appDataModel) async {
    await db
        .collection("users")
        .doc(appDataModel.userOneModel.uid)
        .get()
        .then((value) {
      userOneModel = userOneModelFromJson(jsonEncode(value.data()));
    });

    await db
        .collection("creditTransaction")
        .where("userId", isEqualTo: userOneModel.uid)
        .orderBy("id", descending: true)
        .get()
        .then((value) {
      var jsonData = setList2Json(value);
      creditTransactions = creditTransactionListModelFromJson(jsonData);
      print("jsonData= $jsonData");
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
              title: Style().textBlackSize("เครดิตของคุณ", 14),
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
            ),
            body: (creditTransactions == null)
                ? Center(
                    child: Style().loading(),
                  )
                : Container(
                    child: SingleChildScrollView(
                      child: Column(children: [
                        _buildSumCredit(context.read<AppDataModel>()),
                        _buildTransaction(context.read<AppDataModel>())
                      ]),
                    ),
                  )));
  }

  _buildSumCredit(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Style().textSizeColor(" ฿", 40, Colors.black),
                  Style().textSizeColor(
                      oCcy.format(int.parse(userOneModel.credit)),
                      40,
                      Colors.black),
                ],
              ),
              IconButton(
                  onPressed: () async {
                    var _result = await Navigator.pushNamed(
                        context, "/addCreditPage-page");
                    if (_result != null) {
                      _setData(context.read<AppDataModel>());
                    }
                  },
                  icon: Icon(Icons.add))
            ],
          ),
          Container(
              margin: EdgeInsets.all(1),
              child: Divider(
                color: Colors.grey,
                height: 0,
              )),
        ],
      ),
    );
  }

  _buildTransaction(AppDataModel appDataModel) {
    double testW = appDataModel.screenW * 0.5;
    return Container(
      margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child:
                      Style().textSizeColor("รายการล่าสุด", 16, Colors.black))
            ],
          ),
          (creditTransactions.length == 0)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Style().textSizeColor("ไม่มีรายการ", 14, Colors.black),
                  ],
                )
              : Column(
                  children: creditTransactions.map((e) {
                    Icon iconStr = Icon(
                      FontAwesomeIcons.plusCircle,
                      color: Colors.green,
                      size: 15,
                    );
                    if (e.cmd == "remove") {
                      iconStr = Icon(
                        FontAwesomeIcons.minusCircle,
                        color: Colors.red,
                        size: 15,
                      );
                    }

                    if (e.cmd == "addWaiting") {
                      iconStr = Icon(
                        Icons.lock_clock,
                        color: Colors.orange,
                        size: 15,
                      );
                    }

                    if (e.cmd == "reject") {
                      iconStr = Icon(
                        FontAwesomeIcons.solidTimesCircle,
                        color: Colors.red,
                        size: 15,
                      );
                    }

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: appDataModel.screenW * 0.26,
                                child: Style()
                                    .textSizeColor(e.date, 12, Colors.black)),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      iconStr,
                                      Container(
                                        width: appDataModel.screenW * 0.45,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 5),
                                          child: Style().textFlexibleBackSize(
                                              e.text, 2, 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                width: appDataModel.screenW * 0.2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    (e.cmd == "remove")
                                        ? Style().textSizeColor(
                                            "- ฿" + e.value, 12, Colors.red)
                                        : (e.cmd == "add")
                                            ? Style().textSizeColor(
                                                "+ ฿" + e.value,
                                                12,
                                                Colors.green)
                                            : Style().textSizeColor(
                                                "฿" + e.value,
                                                12,
                                                Colors.black),
                                  ],
                                )),
                          ],
                        ),
                        Container(
                            margin: EdgeInsets.only(bottom: 10, top: 10),
                            child: Style().underLine())
                      ],
                    );
                  }).toList(),
                )
        ],
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    _withdraw.text = "";
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Style().textBlackSize("แจ้งถอนเครดิต", 16),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {});
                    },
                    controller: _withdraw,
                    decoration: InputDecoration(hintText: "THB"),
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {});
                    },
                    controller: _bankAccount,
                    decoration: InputDecoration(hintText: "เลขที่บัญชี"),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {});
                    },
                    controller: _bankUserName,
                    decoration: InputDecoration(hintText: "ชื่อบัญชี"),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {});
                    },
                    controller: _bankName,
                    decoration: InputDecoration(hintText: "ธนาคาร"),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:
                      Style().textSizeColor("ยกเลิก", 14, Style().darkColor)),
              TextButton(
                  onPressed: () async {
                    _saveData(context.read<AppDataModel>());
                  },
                  child: Style().textSizeColor("ตกลง", 14, Style().darkColor)),
            ],
          );
        });
  }

  _saveData(AppDataModel appDataModel) async {}
}
