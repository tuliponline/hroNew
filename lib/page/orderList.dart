import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/model/ratingModel.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class OrderListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OrderListState();
  }
}

class OrderListState extends State<OrderListPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  bool getOrderStatus = false;
  List<OrderList> orderListModel;
  List<OrderList> orderListInProcess;
  List<OrderList> orderListComplete;
  List<OrderList> orderListCancel;
  List<OrderList> orderListFail;

  List<RatingListModel> ratingListModel;

  int _selectedIndex = 0;

  Color darkColor;

  Future<Null> _getOrderListAll(AppDataModel appDataModel) async {
    darkColor = Style().darkColor;

    await db
        .collection('rating')
        .where('customerId', isEqualTo: appDataModel.profileUid)
        .get()
        .then((value) async {
      var jsonData = await setList2Json(value);
      ratingListModel = ratingListModelFromJson(jsonData);
      print("rating = " + ratingListModel.length.toString());
    });

    await FirebaseFirestore.instance
        .collection('orders')
        .where('customerId', isEqualTo: appDataModel.profileUid)
        .orderBy('orderId', descending: true)
        .get()
        .then((value) {
      List<DocumentSnapshot> templist;
      List list = new List();
      templist = value.docs;
      list = templist.map((DocumentSnapshot docSnapshot) {
        return docSnapshot.data();
      }).toList();
      var jsonData = jsonEncode(list);
      print(jsonData);
      orderListModel = orderListFromJson(jsonData);
      print('langth=' + orderListModel.length.toString());

      orderListModel.forEach((element) async {
        print(jsonEncode(element));

        await FirebaseFirestore.instance
            .collection('orders')
            .doc(element.orderId)
            .collection('product')
            .get()
            .then((value) {
          value.docs.forEach((element) {
            // print(jsonEncode(element.data()));
          });
        });
      });
      orderListInProcess = orderListModel
          .where((e) =>
              e.status == '1' ||
              e.status == '2' ||
              e.status == '3' ||
              e.status == '4' ||
              e.status == '9')
          .toList();
      orderListComplete = orderListModel.where((e) => e.status == '5').toList();
      orderListCancel = orderListModel.where((e) => e.status == '0').toList();
      orderListFail = orderListModel.where((e) => e.status == '6').toList();

      setState(() {
        getOrderStatus = true;
      });
    }).catchError((onError) {
      print('error = ' + onError.toString());
      setState(() {
        getOrderStatus = true;
      });
    });
  }

  _realTimeDB(AppDataModel appDataModel) async {
    db.collection("orders").snapshots().listen((event) async {
      await _getOrderListAll(context.read<AppDataModel>());
      if (this.mounted) {
        // check whether the state object is in tree
        setState(() {
          // make changes here
        });
      }
    });
  }

  @override
  void initState() {
    _realTimeDB(context.read<AppDataModel>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (getOrderStatus == false) _getOrderListAll(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Style().darkColor),
              backgroundColor: Colors.white,
              bottomOpacity: 0.0,
              elevation: 0.0,
              // leading: IconButton(
              //     icon: Icon(
              //       Icons.menu,
              //       color: Style().darkColor,
              //     ),
              //     onPressed: () {}),
              title: Style().textDarkAppbar('?????????????????? Order'),
            ),
            body: (orderListInProcess == null)
                ? Center(child: Style().loading())
                : Container(
                    child: buildOrderList(),
                  ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesomeIcons.clock,
                    color: Color(0xff009c86),
                  ),
                  title: Text(
                    '??????????????????????????????????????????',
                    style: TextStyle(fontFamily: 'prompt', fontSize: 12),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesomeIcons.check,
                    color: Colors.lightGreen,
                  ),
                  title: Text(
                    '??????????????????',
                    style: TextStyle(fontFamily: 'prompt', fontSize: 12),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesomeIcons.times,
                    color: Colors.red,
                  ),
                  title: Text(
                    '???????????????????????????/??????????????????',
                    style: TextStyle(fontFamily: 'prompt', fontSize: 12),
                  ),
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
            )));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  SingleChildScrollView buildOrderList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildInProcess(context.read<AppDataModel>()),
          buildInProComplete(context.read<AppDataModel>()),
          buildInFail(context.read<AppDataModel>()),
          (_selectedIndex == 2)
              ? Container(
                  margin: EdgeInsets.all(1),
                  child: Divider(
                    color: Colors.grey,
                    height: 0,
                  ))
              : Container(),
          buildInCancel(context.read<AppDataModel>()),
        ],
      ),
    );
  }

  Container buildInProcess(AppDataModel appDataModel) {
    return (_selectedIndex == 0)
        ? (orderListInProcess != null && orderListInProcess.length != 0)
            ? Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Style().textSizeColor(
                            '??????????????????????????????????????????', 15, Style().textColor)
                      ],
                    ),
                    Column(
                      children: orderListInProcess.map((e) {
                        return InkWell(
                          onTap: () async {
                            if (e.orderType == "mart") {
                              appDataModel.orderDetailSelect =
                                  orderDetailFromJson(jsonEncode(e));
                              Navigator.pushNamed(
                                  context, "/showOrderMart-page",
                                  arguments: "user");
                            } else if (e.orderType == "gas") {
                              appDataModel.orderDetailSelect =
                                  orderDetailFromJson(jsonEncode(e));
                              Navigator.pushNamed(context, "/showOrderGas-page",
                                  arguments: "user");
                            } else {
                              appDataModel.orderIdSelected = e.orderId;
                              var result = await Navigator.pushNamed(
                                  context, "/orderTrack-page");
                              debugPrint('resultBackFromOrderShow = $result');
                              if (result != null) {
                                setState(() {
                                  getOrderStatus = false;
                                });
                              }
                            }
                          },
                          child: InkWell(
                            onTap: () {
                              appDataModel.orderDetailSelect =
                                  orderDetailFromJson(jsonEncode(e));
                              appDataModel.userTypeSelect = "user";
                              appDataModel.orderIdSelected = e.orderId;
                              Navigator.pushNamed(context, "/chat-page");
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 10, bottom: 3),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Style().textSizeColor(e.startTime,
                                                  14, Style().textColor),
                                              Style().textSizeColor(
                                                  " " +
                                                      (int.parse(e.costDelivery) +
                                                              int.parse(
                                                                  e.amount))
                                                          .toString() +
                                                      '???',
                                                  18,
                                                  Style().darkColor)
                                            ],
                                          ),
                                          Style().textSizeColor(
                                              'Order No.' + e.orderId,
                                              12,
                                              Style().textColor),
                                          (e.status == "1")
                                              ? Container()
                                              : Row(
                                                  children: [
                                                    (e.chatRider != null &&
                                                            e.chatUser == "1")
                                                        ? Badge(
                                                            badgeColor: Colors
                                                                .red,
                                                            position:
                                                                BadgePosition
                                                                    .topEnd(
                                                                        top: -5,
                                                                        end:
                                                                            -5),
                                                            shape: BadgeShape
                                                                .circle,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100),
                                                            child: Icon(
                                                                FontAwesomeIcons
                                                                    .facebookMessenger,
                                                                size: 30,
                                                                color: Colors
                                                                    .blue),
                                                            badgeContent: null)
                                                        : Icon(
                                                            FontAwesomeIcons
                                                                .facebookMessenger,
                                                            size: 30,
                                                            color: Colors.blue),
                                                    Style().textBlackSize(
                                                        " ??????????????????Rider"
                                                            .toString(),
                                                        14),
                                                  ],
                                                ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          (e.status == '1')
                                              ? Container(
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        FontAwesomeIcons
                                                            .fileSignature,
                                                        color:
                                                            Style().darkColor,
                                                      ),
                                                      Style().textSizeColor(
                                                          '????????? Order',
                                                          12,
                                                          Style().textColor)
                                                    ],
                                                  ),
                                                )
                                              : (e.status == '2' ||
                                                      e.status == '3')
                                                  ? Container(
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            FontAwesomeIcons
                                                                .clock,
                                                            color: Style()
                                                                .darkColor,
                                                          ),
                                                          (e.orderType ==
                                                                  "mart")
                                                              ? Style().textSizeColor(
                                                                  'Rider ?????????????????????????????????????????????',
                                                                  12,
                                                                  Style()
                                                                      .textColor)
                                                              : (e.orderType ==
                                                                      "gas")
                                                                  ? Style().textSizeColor(
                                                                      'Rider???????????????????????????????????????',
                                                                      12,
                                                                      Style()
                                                                          .textColor)
                                                                  : Style().textSizeColor(
                                                                      '???????????????????????????????????????????????????',
                                                                      12,
                                                                      Style()
                                                                          .textColor)
                                                        ],
                                                      ),
                                                    )
                                                  : (e.status == '4')
                                                      ? Container(
                                                          child: Column(
                                                            children: [
                                                              Icon(
                                                                FontAwesomeIcons
                                                                    .motorcycle,
                                                                color: Style()
                                                                    .darkColor,
                                                              ),
                                                              (e.orderType ==
                                                                      "gas")
                                                                  ? Style().textSizeColor(
                                                                      'Rider?????????????????????????????????????????????????????????',
                                                                      12,
                                                                      Style()
                                                                          .textColor)
                                                                  : Style().textSizeColor(
                                                                      '??????????????????????????????????????????',
                                                                      12,
                                                                      Style()
                                                                          .textColor)
                                                            ],
                                                          ),
                                                        )
                                                      : (e.status == '9')
                                                          ? Container(
                                                              child: Column(
                                                                children: [
                                                                  Icon(
                                                                    FontAwesomeIcons
                                                                        .clock,
                                                                    color: Style()
                                                                        .darkColor,
                                                                  ),
                                                                  Style().textSizeColor(
                                                                      '?????????????????????????????????????????????',
                                                                      12,
                                                                      Style()
                                                                          .textColor)
                                                                ],
                                                              ),
                                                            )
                                                          : Container(),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 10)),
                                  Style().underLine()
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              )
            : (Container(
                child: Center(
                  child: Style()
                      .textSizeColor('?????????????????????????????????', 14, Style().textColor),
                ),
              ))
        : Container();
  }

  Container buildInProComplete(AppDataModel appDataModel) {
    return (_selectedIndex == 1)
        ? (orderListComplete != null && orderListComplete.length != 0)
            ? Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Style().textSizeColor('??????????????????', 15, Style().textColor)
                      ],
                    ),
                    Column(
                      children: orderListComplete.map((e) {
                        RatingModel ratingModel;
                        ratingListModel.forEach((element) {
                          print('RiderComment' + element.orderId);

                          if (element.orderId == e.orderId) {
                            var jsonData = jsonEncode(element);
                            ratingModel = ratingModelFromJson(jsonData);
                            print('riderComment' + ratingModel.riderComment);
                          }
                        });

                        return InkWell(
                            onTap: () {
                              if (e.orderType == "mart") {
                                appDataModel.orderDetailSelect =
                                    orderDetailFromJson(jsonEncode(e));
                                Navigator.pushNamed(
                                    context, "/showOrderMart-page",
                                    arguments: "user");
                              } else if (e.orderType == "gas") {
                                appDataModel.orderDetailSelect =
                                    orderDetailFromJson(jsonEncode(e));
                                Navigator.pushNamed(
                                    context, "/showOrderGas-page",
                                    arguments: "user");
                              } else {
                                appDataModel.orderIdSelected = e.orderId;
                                Navigator.pushNamed(
                                    context, "/orderTrack-page");
                              }
                            },
                            child: Row(children: [
                              Expanded(
                                  child: ListTile(
                                title: Row(
                                  children: [
                                    Style().textSizeColor(
                                        e.startTime, 14, Style().textColor),
                                    Style().textSizeColor(
                                        " " +
                                            (int.parse(e.costDelivery) +
                                                    int.parse(e.amount))
                                                .toString() +
                                            '???',
                                        18,
                                        Style().darkColor)
                                  ],
                                ),
                                subtitle: Style().textSizeColor(
                                    'Order No.' + e.orderId,
                                    12,
                                    Style().textColor),
                              )),
                              Column(
                                children: [
                                  Container(
                                    child: Column(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.check,
                                          color: Colors.blueAccent,
                                        ),
                                        Style().textSizeColor(
                                            '??????????????????', 12, Style().textColor)
                                      ],
                                    ),
                                  ),
                                  (ratingModel == null)
                                      ? Container(
                                          margin: EdgeInsets.only(right: 5),
                                          padding: EdgeInsets.all(1),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () async {
                                                  appDataModel.ratingOrderId =
                                                      e.orderId;
                                                  appDataModel.ratingShopId =
                                                      e.shopId;
                                                  appDataModel.ratingRiderId =
                                                      e.driver;

                                                  var result =
                                                      await Navigator.pushNamed(
                                                          context,
                                                          "/Rating4Customer-page");
                                                  if (result != null &&
                                                      result == true) {
                                                    setState(() {
                                                      getOrderStatus = false;
                                                    });
                                                  }
                                                },
                                                child: Style().textSizeColor(
                                                    '????????????????????????',
                                                    14,
                                                    Colors.white),
                                                style: ElevatedButton.styleFrom(
                                                    primary: Colors.redAccent,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5))),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container()
                                ],
                              )
                            ]));
                      }).toList(),
                    )
                  ],
                ),
              )
            : Container(
                child: Center(
                  child: Style()
                      .textSizeColor('?????????????????????????????????', 14, Style().textColor),
                ),
              )
        : Container();
  }

  Container buildInFail(AppDataModel appDataModel) {
    return (_selectedIndex == 2)
        ? (orderListFail != null && orderListFail.length != 0)
            ? Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Style().textSizeColor(
                            '?????????????????????????????????????????????', 15, Style().textColor)
                      ],
                    ),
                    Column(
                      children: orderListFail.map((e) {
                        return InkWell(
                            onTap: () {
                              if (e.orderType == "mart") {
                                appDataModel.orderDetailSelect =
                                    orderDetailFromJson(jsonEncode(e));
                                Navigator.pushNamed(
                                    context, "/showOrderMart-page",
                                    arguments: "user");
                              } else if (e.orderType == "gas") {
                                appDataModel.orderDetailSelect =
                                    orderDetailFromJson(jsonEncode(e));
                                Navigator.pushNamed(
                                    context, "/showOrderGas-page",
                                    arguments: "user");
                              } else {
                                appDataModel.orderIdSelected = e.orderId;
                                Navigator.pushNamed(
                                    context, "/orderTrack-page");
                              }
                            },
                            child: Row(children: [
                              Expanded(
                                  child: ListTile(
                                title: Row(
                                  children: [
                                    Style().textSizeColor(
                                        e.startTime, 14, Style().textColor),
                                    Style().textSizeColor(
                                        " " +
                                            (int.parse(e.costDelivery) +
                                                    int.parse(e.amount))
                                                .toString() +
                                            '???',
                                        18,
                                        Style().darkColor)
                                  ],
                                ),
                                subtitle: Style().textSizeColor(
                                    'Order No.' + e.orderId,
                                    12,
                                    Style().textColor),
                              )),
                              Container(
                                child: Column(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.timesCircle,
                                      color: Colors.red,
                                    ),
                                    Style().textSizeColor(
                                        '????????????????????????????????????', 12, Style().textColor)
                                  ],
                                ),
                              )
                            ]));
                      }).toList(),
                    )
                  ],
                ),
              )
            : (Container(
                child: Center(
                  child: Style()
                      .textSizeColor('?????????????????????????????????', 14, Style().textColor),
                ),
              ))
        : Container();
  }

  Container buildInCancel(AppDataModel appDataModel) {
    return (_selectedIndex == 2)
        ? (orderListCancel != null && orderListCancel.length != 0)
            ? Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Style().textSizeColor('?????????????????????', 15, Style().textColor)
                      ],
                    ),
                    Column(
                      children: orderListCancel.map((e) {
                        return InkWell(
                            onTap: () {
                              if (e.orderType == "mart") {
                                appDataModel.orderDetailSelect =
                                    orderDetailFromJson(jsonEncode(e));
                                Navigator.pushNamed(
                                    context, "/showOrderMart-page",
                                    arguments: "user");
                              } else {
                                appDataModel.orderIdSelected = e.orderId;
                                Navigator.pushNamed(
                                    context, "/orderTrack-page");
                              }
                            },
                            child: Row(children: [
                              Expanded(
                                  child: ListTile(
                                title: Row(
                                  children: [
                                    Style().textSizeColor(
                                        e.startTime, 14, Style().textColor),
                                    Style().textSizeColor(
                                        " " +
                                            (int.parse(e.costDelivery) +
                                                    int.parse(e.amount))
                                                .toString() +
                                            '???',
                                        18,
                                        Style().darkColor)
                                  ],
                                ),
                                subtitle: Style().textSizeColor(
                                    'Order No.' + e.orderId,
                                    12,
                                    Style().textColor),
                              )),
                              Container(
                                child: Column(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.times,
                                      color: Colors.orange,
                                    ),
                                    Style().textSizeColor(
                                        '??????????????????', 12, Style().textColor)
                                  ],
                                ),
                              )
                            ]));
                      }).toList(),
                    )
                  ],
                ),
              )
            : Container(
                child: Center(
                  child: Style()
                      .textSizeColor('?????????????????????????????????', 14, Style().textColor),
                ),
              )
        : Container();
  }
}
