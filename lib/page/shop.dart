import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/UserListMudel.dart';
import 'package:hro/model/UserOneModel.dart';
import 'package:hro/model/allShopModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/addLog.dart';
import 'package:hro/utility/notifySend.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class ShopPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ShopState();
  }
}

class ShopState extends State<ShopPage> {
  Dialogs dialogs = Dialogs();
  String timeNow;
  UserOneModel userOneModel;
  List<OrderList> orderList;
  FirebaseFirestore db = FirebaseFirestore.instance;

  List<bool> showDetail = [];
  List<OrderProduct> orderProduct;
  String orderSelected = "";
  String pageNow = 'working';
  int _selectedIndex = 0;
  bool shopOpen = false;
  ShopModel shopModel;
  OrderDetail _orderDetailSelect;
  bool loading = false;

  _setData(AppDataModel appDataModel) async {
    userOneModel = appDataModel.userOneModel;
    await db.collection("drivers").get().then((value) {
      var jsonData = setList2Json(value);
      appDataModel.allRiderData = driversListModelFromJson(jsonData);
    });
    await db.collection("users").get().then((value) {
      var jsonData = setList2Json(value);
      appDataModel.alluserData = userListModelFromJson(jsonData);
    });

    await db.collection("shops").get().then((value) {
      var jsonData = setList2Json(value);
      appDataModel.allShopData = allShopModelFromJson(jsonData);
    });

    await db
        .collection('shops')
        .doc(userOneModel.uid)
        .update({'token': appDataModel.token});
    await _getOrders(context.read<AppDataModel>());
    await _getShopData(userOneModel.uid);
    setState(() {
      loading = false;
      print('setstate');
    });
  }

  _getShopData(String shopId) async {
    print("shopData" + shopId);
    await db.collection("shops").doc(shopId).get().then((value) {
      shopModel = shopModelFromJson(jsonEncode(value.data()));
      print(shopModel.shopName);
      if (shopModel.shopStatus == "1") {
        shopOpen = true;
      } else if (shopModel.shopStatus == "2") {
        shopOpen = false;
      }
    });
  }

  _getOrders(AppDataModel appDataModel) async {
    showDetail = [];
    await db
        .collection('orders')
        .where('shopId', isEqualTo: userOneModel.uid)
        .orderBy("orderId", descending: true)
        .get()
        .then((value) {
      print('valueType=' + value.runtimeType.toString());

      List<DocumentSnapshot> templist;
      List list = new List();
      templist = value.docs;
      list = templist.map((DocumentSnapshot docSnapshot) {
        showDetail.add(false);
        return docSnapshot.data();
      }).toList();
      print('ListType=' + list.runtimeType.toString());

      var jsonData = jsonEncode(list);
      print('jsonDataType=' + jsonData.runtimeType.toString());
      print('OrdersList' + jsonData.toString());
      orderList = orderListFromJson(jsonData);
    });
  }

  _getProduct(orderIdSelect) {
    db
        .collection('orders')
        .doc(orderIdSelect)
        .collection('product')
        .get()
        .then((value) async {
      var jsonData = await setList2Json(value);
      print(jsonData);
      orderProduct = orderProductFromJson(jsonData);
      setState(() {});
    });
  }

  _Notififation() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        _setData(context.read<AppDataModel>());
      }
    });
  }

  void initState() {
    super.initState();
    _Notififation();
    _setData(context.read<AppDataModel>());
  }

  @override
  Widget build(BuildContext context) {
    // if (getData == false) _setData(context.read<AppDataModel>());

    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
            appBar: (shopModel == null)
                ? null
                : AppBar(
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
                    title:
                        Style().textSizeColor('ร้านค้า', 18, Style().darkColor),
                    actions: [
                      IconButton(
                          icon: Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 30,
                          ),
                          onPressed: () async {
                            Navigator.pushNamed(context, "/shopHistory-page");
                          }),
                      IconButton(
                          icon: Icon(
                            FontAwesomeIcons.sync,
                            color: Style().darkColor,
                          ),
                          onPressed: () {
                            _setData(context.read<AppDataModel>());
                          }),
                      Container(
                        child: Container(
                          margin: EdgeInsets.only(right: 5),
                          padding: EdgeInsets.all(1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, "/menu-Page");
                                },
                                child: Style()
                                    .textSizeColor('สินค้า', 14, Colors.white),
                                style: ElevatedButton.styleFrom(
                                    primary: Style().darkColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: Container(
                          margin: EdgeInsets.only(right: 5),
                          padding: EdgeInsets.all(1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/editShop-Page');
                                },
                                child: Style().textSizeColor(
                                    'ข้อมูลร้าน', 14, Colors.white),
                                style: ElevatedButton.styleFrom(
                                    primary: Style().darkColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
            body: (shopModel == null || loading == true)
                ? Center(child: Style().loading())
                : Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: ListView(
                        children: [
                          Column(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              (orderList == null)
                                  ? Container()
                                  : buildShopStatus(
                                      context.read<AppDataModel>()),
                              (orderList == null || orderList.length == 0)
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: Style().textSizeColor(
                                              "ไม่มี Order",
                                              16,
                                              Colors.black87),
                                        ),
                                      ],
                                    )
                                  : buildOrderList(context.read<AppDataModel>())

                              //buildPopularProduct(),
                              //buildPopularShop((context.read<AppDataModel>()))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesomeIcons.clock,
                    color: Colors.orangeAccent,
                  ),
                  title: Text(
                    'กำลังดำเนินการ',
                    style: TextStyle(fontFamily: 'prompt', fontSize: 12),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesomeIcons.check,
                    color: Colors.lightGreen,
                  ),
                  title: Text(
                    'Rider รับสินค้าแล้ว',
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

  buildOrderList(AppDataModel appDataModel) {
    return Column(
      children: orderList.map((e) {
        int index = orderList.indexOf(e);

        if (_selectedIndex == 0) {
          if (e.status == "2" || e.status == "3") {
            String statusStr = '';
            switch (e.status) {
              case '0':
                {
                  statusStr = 'ยกเลิก';
                }
                break;

              case '1':
                {
                  statusStr = 'รอ Rider ยืนยัน';
                }
                break;

              case '2':
                {
                  statusStr = 'รอการตอบรับ โปรดตอบรับOrder';
                }
                break;

              case '3':
                {
                  statusStr = 'โปรดจัดเตรียมสินค้า';
                }
                break;

              case '4':
                {
                  statusStr = 'Rider กำลังออกส่ง';
                }
                break;
              case '5':
                {
                  statusStr = 'ส่งสำเร็จ';
                }
                break;
              case '6':
                {
                  statusStr = 'ส่งไม่สำเร็จ/ยกเลิก';
                }
            }
            return InkWell(
              onTap: () async {
                print(index.toString());
                print(showDetail[index]);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                margin: EdgeInsets.only(top: 2, left: 8, right: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Row(
                                children: [
                                  Style().textSizeColor('order No.' + e.orderId,
                                      12, Style().textColor),
                                  Style().textSizeColor(
                                      " (" + e.amountOri + "฿)",
                                      12,
                                      Style().darkColor)
                                ],
                              ),
                              subtitle: Style().textSizeColor(
                                  statusStr,
                                  12,
                                  (e.status == '0' ||
                                          e.status == '5' ||
                                          e.status == '6')
                                      ? Style().textColor
                                      : (e.status == "2")
                                          ? Colors.deepOrange
                                          : (e.status == "3")
                                              ? Colors.orangeAccent
                                              : Style().darkColor),
                            ),
                            Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Style().textBlackSize(e.startTime, 12))
                          ],
                        )),
                        IconButton(
                            onPressed: () {
                              orderSelected = e.orderId;
                              _orderDetailSelect =
                                  orderDetailFromJson(jsonEncode(e));
                              for (int i = 0; i < showDetail.length; i++) {
                                if (index != i) showDetail[i] = false;
                              }

                              if (showDetail[index] == false) {
                                showDetail[index] = true;
                              } else {
                                showDetail[index] = false;
                              }
                              setState(() {
                                orderProduct = null;
                                _getProduct(e.orderId);
                              });
                            },
                            icon: Icon((showDetail[index] == false)
                                ? FontAwesomeIcons.angleDown
                                : FontAwesomeIcons.angleUp))
                      ],
                    ),
                    (showDetail[index] == true)
                        ? (orderProduct == null)
                            ? Style().circularProgressIndicator(
                                Style().shopPrimaryColor)
                            : showDetailList(e.orderId, e.status, e.driver,
                                e.customerId, context.read<AppDataModel>())
                        : Container()
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        } else {
          if (e.status == "0" ||
              e.status == "4" ||
              e.status == "5" ||
              e.status == "6") {
            String statusStr = '';
            switch (e.status) {
              case '0':
                {
                  statusStr = 'ยกเลิก';
                }
                break;

              case '1':
                {
                  statusStr = 'รอ Rider ยืนยัน';
                }
                break;

              case '2':
                {
                  statusStr = 'โปรดยืนยันOrder';
                }
                break;

              case '3':
                {
                  statusStr = 'โปรดจัดเตรียมสินค้า';
                }
                break;

              case '4':
                {
                  statusStr = 'Rider กำลังออกส่ง';
                }
                break;
              case '5':
                {
                  statusStr = 'ส่งสำเร็จ';
                }
                break;
              case '6':
                {
                  statusStr = 'ส่งไม่สำเร็จ/ยกเลิก';
                }
            }
            return InkWell(
              onTap: () async {
                print(index.toString());
                print(showDetail[index]);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                margin: EdgeInsets.only(top: 2, left: 8, right: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Row(
                                children: [
                                  Style().textSizeColor('order No.' + e.orderId,
                                      12, Style().textColor),
                                  Style().textSizeColor(
                                      " (" + e.amountOri + "฿)",
                                      12,
                                      Style().darkColor)
                                ],
                              ),
                              subtitle: Style().textSizeColor(
                                  statusStr,
                                  12,
                                  (e.status == '0' ||
                                          e.status == '5' ||
                                          e.status == '6')
                                      ? Style().textColor
                                      : (e.status == "2")
                                          ? Colors.deepOrange
                                          : (e.status == "3")
                                              ? Colors.orangeAccent
                                              : Style().darkColor),
                            ),
                            Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Style().textBlackSize(e.startTime, 12))
                          ],
                        )),
                        IconButton(
                            onPressed: () {
                              orderSelected = e.orderId;
                              for (int i = 0; i < showDetail.length; i++) {
                                if (index != i) showDetail[i] = false;
                              }

                              if (showDetail[index] == false) {
                                showDetail[index] = true;
                              } else {
                                showDetail[index] = false;
                              }
                              setState(() {
                                orderProduct = null;
                                _getProduct(e.orderId);
                              });
                            },
                            icon: Icon((showDetail[index] == false)
                                ? Icons.arrow_drop_down
                                : Icons.arrow_drop_up))
                      ],
                    ),
                    (showDetail[index] == true)
                        ? (orderProduct == null)
                            ? Style().loading()
                            : showDetailList(e.orderId, e.status, e.driver,
                                e.customerId, context.read<AppDataModel>())
                        : Container()
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        }
      }).toList(),
    );
  }

  showDetailList(String orderIdSelect, orderStatus, orderRider, orderUser,
      AppDataModel appDataModel) {
    String userName, userPhone, riderName, RiderPhone;
    appDataModel.alluserData.forEach((element) {
      if (element.uid == orderUser) {
        userName = element.name;
        userPhone = element.phone;
      }
    });
    appDataModel.allRiderData.forEach((element) {
      if (element.driverId == orderRider) {
        riderName = element.driverName;
        RiderPhone = element.driverPhone;
      }
    });

    return Column(children: [
      Column(
        children: [
          Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Style().textBlackSize("ลูกค้า: $userName", 14)),
                IconButton(
                    onPressed: () {
                      _callNumber(userPhone);
                    },
                    icon: Icon(
                      Icons.phone,
                      color: Style().darkColor,
                    ))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Style().textBlackSize("Rider: $riderName", 14)),
                IconButton(
                    onPressed: () {
                      _callNumber(userPhone);
                    },
                    icon: Icon(
                      Icons.phone,
                      color: Style().darkColor,
                    ))
              ],
            )
          ]),
          Column(
              children: orderProduct.map((e) {
            String productDetail;
            appDataModel.allProductsData.forEach((element) {
              if (e.productId == element.productId)
                productDetail = element.productDetail;
            });

            return Row(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    ListTile(
                      title: Style().textFlexibleBackSize(e.name, 2, 14),
                      subtitle: (productDetail == null)
                          ? Text("")
                          : Style().textFlexibleBackSize(productDetail, 2, 12),
                    ),
                    (e.comment == null)
                        ? Container()
                        : Container(
                            margin: EdgeInsets.only(left: 20),
                            child: Style().textFlexibleColorSize(
                                e.comment, 2, 12, Colors.red),
                          )
                  ],
                )),
                Column(
                  children: [
                    Style().textSizeColor(
                        (int.parse(e.pcs) * int.parse(e.oriPrice)).toString() +
                            ' ฿',
                        14,
                        Style().textColor),
                    Row(
                      children: [
                        Style()
                            .textSizeColor(e.oriPrice, 12, Style().darkColor),
                        Style().textSizeColor(
                            ' ฿/จำนวน x ' + e.pcs, 12, Style().darkColor)
                      ],
                    )
                  ],
                )
              ],
            );
          }).toList()),
          buildAmount(),
          (orderStatus == '2') ? buildConfirmMenu() : Container()
        ],
      )
    ]);
  }

  buildConfirmMenu() {
    return Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 5),
            child: ElevatedButton(
              onPressed: () async {
                var result = await Dialogs().confirm(
                  context,
                  "ยกเลิก Order",
                  "ยกเลิก Order สินค้า ",
                );
                if (result == true) {
                  print('cancelOrder By Shop');
                  _cancelOrder(context.read<AppDataModel>(), orderSelected);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Style().textSizeColor('ยกเลิก', 14, Colors.white),
                ],
              ),
              style: ElevatedButton.styleFrom(
                  primary: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
            ),
          )
        ],
      ),
      Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 5),
            child: ElevatedButton(
              onPressed: () async {
                var result = await Dialogs().confirm(
                  context,
                  "ยืนยัน Order",
                  "ยืนยัน Order สินค้า ",
                );
                if (result == true) {
                  _conFirmOrder(context.read<AppDataModel>(), orderSelected);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Style().textSizeColor('ยืนยัน', 14, Colors.white),
                ],
              ),
              style: ElevatedButton.styleFrom(
                  primary: Style().darkColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
            ),
          )
        ],
      )
    ]));
  }

  Row buildShopStatus(AppDataModel appDataModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        (shopModel.shopStatus == '3')
            ? Expanded(
                child: ListTile(
                  title: Style().textSizeColor(
                      'อยู่ระหว่างการตรวจสอบ', 16, Colors.orange),
                  subtitle:
                      Style().textSizeColor('สถานะ ', 14, Style().textColor),
                ),
              )
            : (shopOpen == true)
                ? Expanded(
                    child: ListTile(
                      title:
                          Style().textSizeColor('เปิดร้าน', 16, Colors.green),
                      subtitle: Style()
                          .textSizeColor('สถานะ ', 14, Style().textColor),
                    ),
                  )
                : Expanded(
                    child: ListTile(
                      title: Style()
                          .textSizeColor('ปิดร้าน', 16, Colors.deepOrange),
                      subtitle: Style()
                          .textSizeColor('สถานะ ', 14, Style().textColor),
                    ),
                  ),
        (shopModel.shopStatus == "3")
            ? Container()
            : Switch(
                activeColor: Style().darkColor,
                value: shopOpen,
                onChanged:
                    (shopModel.shopStatus == '1' || shopModel.shopStatus == '2')
                        ? (value) async {
                            if (value == true) {
                              db
                                  .collection('shops')
                                  .doc(userOneModel.uid)
                                  .update({"shop_status": "1"});
                            } else {
                              db
                                  .collection('shops')
                                  .doc(userOneModel.uid)
                                  .update({"shop_status": "2"});
                            }
                            setState(() {
                              shopOpen = value;
                            });
                          }
                        : null)
      ],
    );
  }

  _cancelOrder(AppDataModel appDataModel, String orderId) async {
    setState(() {
      loading = true;
    });
    await db.collection('orders').doc(orderId).get().then((value) async {
      OrderDetail orderDetail = orderDetailFromJson(jsonEncode(value.data()));
      if (orderDetail.status == '2') {
        var result = await dialogs.inputDialog(
            context,
            Style().textSizeColor('เหตุผล', 16, Style().textColor),
            'ระบุเหตุผลที่ยกเลิก');
        if (result != null && result[0] == true) {
          await db
              .collection('orders')
              .doc(orderId)
              .update({'status': '0'}).then((value) {
            addLog(orderId, '0', 'shop', userOneModel.uid, result[1])
                .then((value) {
              _setData(context.read<AppDataModel>());
            });
          });

          String userToken;
          String riderToken;
          await db
              .collection("users")
              .doc(orderDetail.customerId)
              .get()
              .then((value) {
            UserOneModel userOneModel =
                userOneModelFromJson(jsonEncode(value.data()));
            userToken = userOneModel.token;
          });
          await db
              .collection("drivers")
              .doc(orderDetail.driver)
              .get()
              .then((value) {
            ShopModel shopModel = shopModelFromJson(jsonEncode(value.data()));
            riderToken = shopModel.token;
          });
          await notifySend(riderToken, "Order ถูกยกเลิกโดย ร้านค้า",
              "Order:" + orderId + " เหตุผล: " + result[1]);
          await notifySend(userToken, "Order ถูกยกเลิกโดย ร้านค้า",
              "Order:" + orderId + " เหตุผล: " + result[1]);
        }
      } else {
        await dialogs.information(
            context,
            Style().textSizeColor('ผิดพลาด', 16, Style().textColor),
            Style()
                .textSizeColor('Order ถูกยกเลิกแล้ว', 14, Style().textColor));
        _setData(context.read<AppDataModel>());
      }
    });
  }

  _conFirmOrder(AppDataModel appDataModel, String orderId) async {
    setState(() {
      loading = true;
    });

    db.collection('orders').doc(orderId).get().then((value) async {
      OrderDetail orderDetail = orderDetailFromJson(jsonEncode(value.data()));
      if (orderDetail.status == '2') {
        db
            .collection('orders')
            .doc(orderId)
            .update({'status': '3'}).then((value) {
          addLog(orderId, '3', 'shop', userOneModel.uid, '')
              .then((value) async {
            await db
                .collection("users")
                .doc(_orderDetailSelect.customerId)
                .get()
                .then((value) async {
              UserOneModel userOneModel =
                  userOneModelFromJson(jsonEncode(value.data()));

              await notifySend(userOneModel.token, "ร้านค้ากำลังเตรียมสินค้า",
                  "ร้านค้ากำลังเตรียมสินค้าของคุณ");
            });
            await db
                .collection("users")
                .doc(_orderDetailSelect.driver)
                .get()
                .then((value) async {
              UserOneModel userOneModel =
                  userOneModelFromJson(jsonEncode(value.data()));

              await notifySend(userOneModel.token, "ร้านค้ากำลังเตรียมสินค้า",
                  "โปรดเดินทางไปรับสินค้าที่ร้านค้า");
            });

            _setData(context.read<AppDataModel>());
          });
        });
      } else {
        await dialogs.information(
            context,
            Style().textSizeColor('ผิดพลาด', 16, Style().textColor),
            Style()
                .textSizeColor('Order ถูกยกเลิกแล้ว', 14, Style().textColor));
        _setData(context.read<AppDataModel>());
      }
    });
  }

  buildAmount() {
    int amount = 0;
    orderProduct.forEach((e) {
      amount += (int.parse(e.oriPrice) * int.parse(e.pcs));
    });

    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Divider(
                color: Colors.grey,
                height: 0,
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Style().textSizeColor('รวมค่าสินค้า', 16, Style().darkColor),
              Style().textSizeColor('$amount ฿', 16, Style().darkColor)
            ],
          ),
        ],
      ),
    );
  }

  _callNumber(String number) async {
    bool res = await FlutterPhoneDirectCaller.callNumber(number);
  }
}
