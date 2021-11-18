import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/CreditTicketListMadel.dart';
import 'package:hro/model/CreditTicketModel.dart';
import 'package:hro/model/UserListMudel.dart';
import 'package:hro/model/UserOneModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/addTransactionLog.dart';
import 'package:hro/utility/getTimeNow.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class TransactionTicketPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TransactionTicketState();
  }
}

class TransactionTicketState extends State<TransactionTicketPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<CreditTicketListModel> creditTicketListData;
  String cmd;
  double screenW;
  List<UserListModel> userListModel;
  UserOneModel userOneModel;
  CreditTicketModel creditTicketModel;

  _setData(AppDataModel appDataModel) async {
    screenW = appDataModel.screenW;
    userListModel = appDataModel.alluserData;
    userOneModel = appDataModel.userOneModel;
    await db
        .collection("addCreditTicket")
        .orderBy("id", descending: true)
        .get()
        .then((value) {
      var jsonData = setList2Json(value);
      creditTicketListData = creditTicketListModelFromJson(jsonData);
    });

    await db.collection("users").get().then((value) {
      var jsonData = setList2Json(value);
      appDataModel.alluserData = userListModelFromJson(jsonData);
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
              title: Style().textBlackSize("คำของฝาก-ถอน", 14),
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
            body: Container(
              child: SingleChildScrollView(
                child: Column(children: [
                  _buildTransaction(context.read<AppDataModel>())
                ]),
              ),
            )));
  }

  _buildTransaction(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: Column(
        children: [
          (creditTicketListData == null)
              ? Center(
                  child: Style().loading(),
                )
              : Column(
                  children: creditTicketListData.map((e) {
                    String cmdStr = "ฝาก";
                    if (e.cmd == "withdraw") {
                      cmdStr = "ถอน";
                    }

                    String userName = "";
                    String phoneUser = "";
                    String creditUser = "";
                    for (var user in appDataModel.alluserData) {
                      if (user.uid == e.uid) {
                        userName = user.name;
                        if (user.phone != null) {
                          phoneUser = user.phone;
                        }
                        if (user.credit != null) {
                          creditUser = user.credit;
                        }

                        break;
                      }
                    }

                    return Container(
                      margin: EdgeInsets.only(bottom: 1),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: screenW * 0.25,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Style()
                                        .textSizeColor(e.id, 12, Colors.black),
                                    Style().textSizeColor(
                                        e.date, 10, Colors.black),
                                    Style().textSizeColor(
                                        userName, 10, Colors.black),
                                    Style().textSizeColor(
                                        "โทร " + phoneUser, 10, Colors.black),
                                    Style().textSizeColor(
                                        "Credit " + creditUser, 14, Colors.red),
                                  ],
                                ),
                              ),
                              Container(
                                width: screenW * 0.3,
                                child: Row(
                                  children: [
                                    (e.cmd == "add")
                                        ? Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Icon(
                                              FontAwesomeIcons.plusCircle,
                                              size: 10,
                                              color: Colors.green,
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Icon(
                                              FontAwesomeIcons.minusCircle,
                                              size: 10,
                                              color: Colors.red,
                                            ),
                                          ),
                                    Style().textSizeColor(
                                        cmdStr, 14, Colors.black),
                                  ],
                                ),
                              ),
                              Container(
                                width: screenW * 0.3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      children: [
                                        Style().textSizeColor(
                                            e.value + " ฿", 14, Colors.black),
                                        (e.comfirmBy != "0")
                                            ? (e.comfirmBy == "auto")
                                                ? Container(
                                                    color: Colors.green,
                                                    child: Style()
                                                        .textSizeColor("auto",
                                                            10, Colors.white),
                                                  )
                                                : Container(
                                                    color: Style().darkColor,
                                                    child: Style()
                                                        .textSizeColor("Admin",
                                                            10, Colors.white),
                                                  )
                                            : Container()
                                      ],
                                    ),
                                    IconButton(
                                        onPressed: () async {
                                          creditTicketModel =
                                              creditTicketModelFromJson(
                                                  jsonEncode(e));
                                          if (e.status == "3") {
                                            cmd = e.cmd;
                                            CreditTicketModel creditJson =
                                                creditTicketModelFromJson(
                                                    jsonEncode(e));
                                            await _displayTextInputDialog(
                                                context, creditJson);
                                            _setData(
                                                context.read<AppDataModel>());
                                          } else if (e.status == "1") {
                                            appDataModel.creditTicketId = e.id;
                                            Navigator.pushNamed(
                                                context, '/ticketDetail-page');
                                          }
                                        },
                                        icon: (e.status == "3")
                                            ? Icon(
                                                Icons.lock_clock,
                                                color: Colors.orange,
                                              )
                                            : (e.status == "1")
                                                ? Icon(
                                                    FontAwesomeIcons
                                                        .checkCircle,
                                                    color: Colors.green,
                                                  )
                                                : Icon(
                                                    FontAwesomeIcons
                                                        .timesCircle,
                                                    color: Colors.red))
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Style().underLine()
                        ],
                      ),
                    );
                  }).toList(),
                )
        ],
      ),
    );
  }

  Future<void> _displayTextInputDialog(
      BuildContext context, CreditTicketModel creditTicket) async {
    String cmdStr;
    if (cmd == "add") {
      cmdStr = "เติมเครดิต";
    } else {
      cmdStr = "ถอนเครดิต";
    }
    String userName = "";
    for (var e in userListModel) {
      if (e.uid == creditTicket.uid) {
        userName = e.name;
        break;
      }
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Style().textBlackSize("คำขอ$cmdStr", 16),
            content: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  (creditTicket.cmd == "add")
                      ? Container(
                          margin: EdgeInsets.only(bottom: 10),
                          height: 300,
                          width: screenW * 0.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                              fit: BoxFit.fitWidth,
                              image: NetworkImage(creditTicket.photoUrl),
                            ),
                          ),
                        )
                      : Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Style().textBlackSize(
                          cmdStr + ": " + creditTicket.value + " ฿", 14),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Style().textBlackSize("ชื่อผู้ใช้: " + userName, 14),
                    ],
                  ),
                  (cmd == "add")
                      ? Container()
                      : Container(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Style().textBlackSize(
                                      "เลขที่บัญชี " +
                                          creditTicketModel.bankAccount,
                                      14),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Style().textBlackSize(
                                      "ชื่อบัญชี่ " + creditTicket.bankUserName,
                                      14),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Style().textBlackSize(
                                      "ธนคาร " + creditTicket.bankName, 14),
                                ],
                              )
                            ],
                          ),
                        )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () async {
                    var comment = await Dialogs().inputDialog(context,
                        Style().textBlackSize("เหตุผล", 16), "ระบุเหตุผล");
                    if (comment != null || comment != []) {
                      if (comment[0] == true) {
                        await db
                            .collection("addCreditTicket")
                            .doc(creditTicket.id)
                            .update({
                          "status": "0",
                          "comment": comment[1],
                          "comfirmBy": userOneModel.uid
                        });
                        String timeStamp = await getTimeStampNow();
                        String dateNow = await getTimeStringNow();

                        await addTransactionLog(
                            creditTicket.uid,
                            "reject",
                            "0",
                            creditTicket.uid,
                            creditTicket.value,
                            "credit",
                            comment[1],
                            comment[1]);
                        Fluttertoast.showToast(
                            msg: "ปฏิเสธคำขอถอนเครดิตแล้ว",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);

                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Style().textSizeColor("ปฏิเสธ", 14, Colors.red)),
              TextButton(
                  onPressed: () async {
                    var resule = await Dialogs().confirm(context, "ยืนยันคำขอ",
                        'ยืนยันคำของ$cmdStr ' + creditTicket.id);
                    if (resule) {
                      _confirmCreditTicket(
                          context.read<AppDataModel>(), creditTicket);
                    }
                  },
                  child: Style().textSizeColor("อนุมัติ", 14, Colors.green)),
            ],
          );
        });
  }

  _confirmCreditTicket(
      AppDataModel appDataModel, CreditTicketModel creditTicket) async {
    if (creditTicket.cmd == "add") {
      UserOneModel userAction;
      await db.collection("users").doc(creditTicket.uid).get().then((value) {
        userAction = userOneModelFromJson(jsonEncode(value.data()));
      });

      int oldCredit = int.parse(userAction.credit);

      double rowCredit = double.parse(creditTicket.value);
      int newCredit = rowCredit.toInt();
      int finalCredit = oldCredit + newCredit;

      await db
          .collection("users")
          .doc(creditTicket.uid)
          .update({"credit": finalCredit.toString()});

      await addTransactionLog(creditTicket.uid, creditTicket.cmd, "0",
          creditTicket.uid, creditTicket.value, "credit", "เติมเครดิต", "");

      await db.collection("addCreditTicket").doc(creditTicket.id).update({
        "status": "1",
        "comfirmBy": userOneModel.uid,
        "after": finalCredit.toString()
      });

      await Dialogs().information(
          context,
          Style().textBlackSize("สำเร็จ", 16),
          Style().textBlackSize(
              "ยืนยันคำขอสำเร็จ เครดิตถูกเติมเข้าบัญชีเรียบร้อยแล้ว", 16));
      Navigator.pop(context);
    } else {
      UserOneModel userAction;
      await db.collection("users").doc(creditTicket.uid).get().then((value) {
        userAction = userOneModelFromJson(jsonEncode(value.data()));
      });
      int oldCredit = int.parse(userAction.credit);
      int newCredit = int.parse(creditTicket.value);

      if (oldCredit >= newCredit) {
        await db
            .collection("addCreditTicket")
            .doc(creditTicket.id)
            .update({"status": "1", "comfirmBy": userOneModel.uid});

        int finalCredit = oldCredit - newCredit;

        await db
            .collection("users")
            .doc(creditTicket.uid)
            .update({"credit": finalCredit.toString()});

        await addTransactionLog(creditTicket.uid, creditTicket.cmd, "0",
            creditTicket.uid, creditTicket.value, "credit", "", "");

        await Dialogs().information(
            context,
            Style().textBlackSize("สำเร็จ", 16),
            Style().textBlackSize(
                "ถอนเครดิตสำเร็จ เครดิตถูกหักจากบัญชีเรียบร้อยแล้ว", 16));

        Navigator.pop(context);
        _setData(context.read<AppDataModel>());
      } else {
        Fluttertoast.showToast(
            msg: "เครดิตไม่เพียงพอ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }
}
