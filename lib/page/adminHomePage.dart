import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/CreditTicketListMadel.dart';
import 'package:hro/model/UserListMudel.dart';
import 'package:hro/model/UserOneModel.dart';
import 'package:hro/model/allShopModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/model/productsModel.dart';
import 'package:hro/model/setupModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/page/fireBaseFunctions.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/notifySend.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:provider/provider.dart';
// import 'package:collection/src/iterable_extensions.dart';

class AdminHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AdminHomeState();
  }
}

class AdminHomeState extends State<AdminHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseFirestore db = FirebaseFirestore.instance;

  int riderOffline = 0,
      riderWork = 0,
      riderFree = 0,
      riderBlock = 0,
      riderNew = 0,
      android = 0,
      ios = 0,
      orderSuscess = 0,
      orderFail = 0;

  int _selectedIndex = 0;
  List<bool> showDetail = [];
  List<UserListModel> allUserData;
  List<AllShopModel> allShopData;
  List<ProductsModel> allProductData;
  List<ProductsModel> productFilter;
  List<DriversListModel> allDriverData;
  List<OrderList> allOrderData;

  String headerText = "Admin";
  double screenW;

  bool isChecked = false;

  var _textControl = TextEditingController();

  bool loading = false;

  ScrollController scrollController = ScrollController();
  int amountListView = 20;

  ScrollController scrollControllerShop = ScrollController();
  int amountListViewShop = 20;

  ScrollController scrollControllerProduct = ScrollController();
  int amountListViewProduct = 20;

  ScrollController scrollControllerRider = ScrollController();
  int amountListViewRider = 20;
  String _productIdSelect;
  TextEditingController _fullPrice = TextEditingController();
  TextEditingController _searchSelect = TextEditingController();

  AppSetupModel appSetupModel;

  bool creditTransactionWaiting = false;

  _getAllUser(AppDataModel appDataModel) async {
    screenW = appDataModel.screenW;

    creditTransactionWaiting = false;

    await db.collection("addCreditTicket").get().then((value) {
      var jsonData = setList2Json(value);
      List<CreditTicketListModel> creditTicketListData =
          creditTicketListModelFromJson(jsonData);
      creditTicketListData.forEach((element) {
        if (element.status == "3") creditTransactionWaiting = true;
      });
    });
    await db.collection("users").get().then((value) {
      var jsonData = setList2Json(value);
      appDataModel.alluserData = userListModelFromJson(jsonData);
      allUserData = appDataModel.alluserData;
      appDataModel.alluserData.forEach((e) {
        if (e.os == "ios") {
          ios += 1;
        } else {
          android += 1;
        }
      });
    });
    await db.collection("shops").get().then((value) {
      var jsonData = setList2Json(value);
      appDataModel.allShopData = allShopModelFromJson(jsonData);
      allShopData = appDataModel.allShopData;
    });
    await db.collection("products").get().then((value) {
      var jsonData = setList2Json(value);
      appDataModel.allProductData = productsModelFromJson(jsonData);
      allProductData = appDataModel.allProductData;
      productFilter = allProductData;
    });
    await db.collection("drivers").get().then((value) {
      var jsonData = setList2Json(value);
      appDataModel.allRiderData = driversListModelFromJson(jsonData);
      allDriverData = appDataModel.allRiderData;
      appDataModel.allRiderData.forEach((e) {
        if (e.driverStatus == "0") {
          riderOffline += 1;
        } else if (e.driverStatus == "1") {
          riderFree += 1;
        } else if (e.driverStatus == "2") {
          riderWork += 1;
        } else if (e.driverStatus == "3") {
          riderNew += 1;
        } else if (e.driverStatus == "4") {
          riderBlock += 1;
        }
      });
    });

    await db.collection("orders").get().then((value) {
      var jsonData = setList2Json(value);
      allOrderData = orderListFromJson(jsonData);
      allOrderData.forEach((element) {
        if (element.status == "5") {
          orderSuscess += 1;
        } else {
          orderFail += 1;
        }
      });
    });

    setState(() {});
  }

  _getConfig() async {
    var _dbAppConfig = await dbGetDataOne("getAppConfig", "setup", "app");
    print(_dbAppConfig[1]);
    appSetupModel = appSetupModelFromJson(_dbAppConfig[1]);
    setState(() {});
  }

  _realTimeDb() {
    db.collection("addCreditTicket").snapshots().listen((event) async {
      creditTransactionWaiting = false;

      await db.collection("addCreditTicket").get().then((value) {
        var jsonData = setList2Json(value);
        List<CreditTicketListModel> creditTicketListData =
            creditTicketListModelFromJson(jsonData);
        creditTicketListData.forEach((element) {
          if (element.status == "3") creditTransactionWaiting = true;
        });
      });
    });
  }

  @override
  void initState() {
    _getConfig();
    _getAllUser(context.read<AppDataModel>());
    _realTimeDb();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                iconTheme: IconThemeData(color: Style().darkColor),
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                title: Style().textDarkAppbar(headerText),
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios)),
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/adminSendNotify-page");
                      },
                      icon: Icon(
                        Icons.sms,
                        color: Style().darkColor,
                      )),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/transectionTicket-page");
                    },
                    icon: (creditTransactionWaiting == false)
                        ? Icon(
                            FontAwesomeIcons.exchangeAlt,
                            size: 20,
                          )
                        : Badge(
                            badgeColor: Colors.red,
                            position: BadgePosition.topEnd(top: -5, end: -5),
                            shape: BadgeShape.circle,
                            borderRadius: BorderRadius.circular(100),
                            child: Icon(
                              FontAwesomeIcons.exchangeAlt,
                              size: 20,
                            ),
                            badgeContent: null),
                  ),
                  IconButton(
                      onPressed: () {
                        _scaffoldKey.currentState.openEndDrawer();
                      },
                      icon: Icon(Icons.menu))
                ],
              ),
              endDrawer: _adminDrawer(),
              body: (allOrderData == null)
                  ? Center(child: Style().loading())
                  : Container(
                      color: Color.fromRGBO(242, 244, 251, 1),
                      child: (_selectedIndex == 0)
                          ? Container(
                              margin: EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _bulidAllUser(context.read<AppDataModel>()),
                                  _bulidOrder(context.read<AppDataModel>()),
                                  _buildShopAndRider(
                                      context.read<AppDataModel>()),
                                ],
                              ))
                          : (_selectedIndex == 1)
                              ? buildCustomerList(context.read<AppDataModel>())
                              : (_selectedIndex == 2)
                                  ? buildShopList()
                                  : (_selectedIndex == 3)
                                      ? buildProductList(
                                          context.read<AppDataModel>())
                                      : (_selectedIndex == 4)
                                          ? buildRiderList()
                                          : Container()),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    title: Text(
                      'DashBoard',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    title: Text(
                      'Users',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.store),
                    title: Text(
                      'shops',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.fastfood),
                    title: Text(
                      'products',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.motorcycle),
                    title: Text(
                      'riders',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
            ));
  }

  _bulidAllUser(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: (Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Style().textSizeColor("Users", 14, Colors.blueAccent),
                      Row(
                        children: [
                          Style().textSizeColor(
                              appDataModel.alluserData.length.toString(),
                              40,
                              Colors.black),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Style().textBlackSize(" Android ", 10),
                                  Style().textBlackSize(android.toString(), 12)
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Style().textBlackSize(" iOS ", 10),
                                  Style().textBlackSize(ios.toString(), 12)
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 20),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Style().darkColor,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      )),
    );
  }

  _buildShopAndRider(AppDataModel appDataModel) {
    return Expanded(
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  radius: 25,
                  child: Icon(
                    Icons.store,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
                ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                    title: Style().textSizeColor(
                        appDataModel.allShopData.length.toString(),
                        30,
                        Colors.black),
                    subtitle: Style().textSizeColor(
                        "เมนู " + appDataModel.allProductData.length.toString(),
                        16,
                        Colors.grey))
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  radius: 25,
                  child: Icon(
                    Icons.motorcycle,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
                Style().textSizeColor(
                    appDataModel.allRiderData.length.toString(),
                    30,
                    Colors.black),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: Colors.green,
                        ),
                        Style()
                            .textBlackSize(" free " + riderFree.toString(), 12)
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: Colors.orange,
                        ),
                        Style().textBlackSize(" new " + riderNew.toString(), 12)
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: Colors.grey,
                        ),
                        Style().textBlackSize(
                            " offline " + riderOffline.toString(), 12)
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: Colors.red,
                        ),
                        Style().textBlackSize(
                            " block " + riderBlock.toString(), 12)
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _bulidOrder(AppDataModel appDataModel) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, "/adminOrder-page");
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        child: (Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Icon(
                      Icons.receipt,
                      size: 60,
                      color: Colors.pink,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.only(
                              top: 5,
                            ),
                            child: Style().textSizeColor(
                                "Orders", 14, Colors.blueAccent)),
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Style().textSizeColor(
                                  allOrderData.length.toString(),
                                  40,
                                  Colors.black),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.circle,
                                        size: 10, color: Colors.green),
                                    Style().textBlackSize(" suscess ", 12),
                                    Style().textBlackSize(
                                        orderSuscess.toString(), 12)
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.circle,
                                        size: 10, color: Colors.red),
                                    Style().textBlackSize(" fail ", 12),
                                    Style()
                                        .textBlackSize(orderFail.toString(), 12)
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        )),
      ),
    );
  }

  buildCustomerList(AppDataModel appDataModel) {
    return Center(
      child: SingleChildScrollView(
        // margin: EdgeInsets.all(8),
        child: (allUserData == null || showDetail.length != allUserData.length)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Style().circularProgressIndicator(Style().darkColor),
                ],
              )
            : Column(
                children: allUserData.map((e) {
                  int index = allUserData.indexOf(e);
                  return Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(top: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            (showDetail[index] == true)
                                ? Container()
                                : Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.all(3),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: (e.photoUrl == null)
                                            ? Container()
                                            : CachedNetworkImage(
                                                key: UniqueKey(),
                                                imageUrl: e.photoUrl,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  color: Colors.black12,
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  color: Colors.black12,
                                                  child: (Icon(
                                                    Icons.error,
                                                    color: Colors.red,
                                                  )),
                                                ),
                                              ),
                                      ),
                                    )),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Style().textBlackSize(e.name, 14),
                                (showDetail[index] == false)
                                    ? Container()
                                    : Container(
                                        margin: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                margin: EdgeInsets.only(
                                                    right: 10, left: 10),
                                                height: 180,
                                                width: 180,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Colors.white,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  child: (e.photoUrl == null)
                                                      ? Container()
                                                      : OptimizedCacheImage(
                                                          imageUrl: e.photoUrl,
                                                          progressIndicatorBuilder: (context,
                                                                  url,
                                                                  downloadProgress) =>
                                                              CircularProgressIndicator(
                                                                  value: downloadProgress
                                                                      .progress),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(Icons.error),
                                                        ),
                                                )),
                                            Style().textBlackSize(
                                                "email : " + e.email, 14),
                                            (e.phone == null)
                                                ? Style()
                                                    .textBlackSize("tel : ", 14)
                                                : Style().textBlackSize(
                                                    "tel : " + e.phone, 14),
                                            (e.location == null)
                                                ? Style().textBlackSize(
                                                    "location : ", 14)
                                                : Style().textBlackSize(
                                                    "location : " + e.location,
                                                    14),
                                            (e.status == null)
                                                ? Style().textBlackSize(
                                                    "status : ", 14)
                                                : Style().textBlackSize(
                                                    "status : " + e.status, 14),
                                            (e.uid == null)
                                                ? Style()
                                                    .textBlackSize("uid : ", 14)
                                                : Style()
                                                    .textBlackSize(e.uid, 10)
                                          ],
                                        ),
                                      )
                              ],
                            )
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                print("index = " + index.toString());
                                (showDetail[index] == true)
                                    ? showDetail[index] = false
                                    : showDetail[index] = true;
                              });
                            },
                            icon: (showDetail[index] == false)
                                ? Icon(Icons.arrow_drop_down)
                                : Icon(Icons.arrow_drop_up))
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  buildShopList() {
    return SingleChildScrollView(
      child: Container(
        // margin: EdgeInsets.all(8),
        child: (allShopData == null || showDetail.length != allShopData.length)
            ? Style().circularProgressIndicator(Style().darkColor)
            : Column(
                children: allShopData.map((e) {
                  int index = allShopData.indexOf(e);
                  bool shopStatusOnline = false;
                  (e.shopStatus == "1")
                      ? shopStatusOnline = true
                      : shopStatusOnline = false;

                  print(index);
                  return Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(top: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            (showDetail[index] == true)
                                ? Container()
                                : Container(
                                    margin: EdgeInsets.only(
                                      left: 10,
                                    ),
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: CachedNetworkImage(
                                        key: UniqueKey(),
                                        imageUrl: e.shopPhotoUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                          color: Colors.black12,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: Colors.black12,
                                          child: (Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          )),
                                        ),
                                      ),

                                      // FadeInImage.assetNetwork(
                                      //   fit: BoxFit.fitHeight,
                                      //   placeholder:
                                      //       'assets/images/loading.gif',
                                      //   image: ranProductModel[index]
                                      //       .productPhotoUrl,
                                      // ),
                                    )),
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (showDetail[index] == false)
                                      ? Container()
                                      : Container(
                                          margin: EdgeInsets.only(
                                            left: 10,
                                          ),
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            child: CachedNetworkImage(
                                              key: UniqueKey(),
                                              imageUrl: e.shopPhotoUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Container(
                                                color: Colors.black12,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                color: Colors.black12,
                                                child: (Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                )),
                                              ),
                                            ),
                                          )),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Style().textBlackSize(e.shopName, 14),
                                          (e.shopStatus == "3")
                                              ? Container(
                                                  margin:
                                                      EdgeInsets.only(left: 5),
                                                  child: IconButton(
                                                      onPressed: () async {
                                                        var result =
                                                            await Dialogs()
                                                                .confirm(
                                                          context,
                                                          "ยืนยันร้านค้า",
                                                          "ยืนยันสถานะร้านค้า",
                                                        );

                                                        if (result != null &&
                                                            result == true) {
                                                          await db
                                                              .collection(
                                                                  "shops")
                                                              .doc(e.shopUid)
                                                              .update({
                                                            "shop_status": "1"
                                                          }).then((value) {
                                                            notifySend(
                                                                e.token,
                                                                "ยืนยันร้านค้า",
                                                                "ร้าน" +
                                                                    e.shopName +
                                                                    " ได้รับการยืนยันแล้ว");
                                                          });
                                                          _getAllUser(context.read<
                                                              AppDataModel>());
                                                        }
                                                      },
                                                      icon: Icon(
                                                        Icons.lock_clock,
                                                        size: 20,
                                                        color: Colors
                                                            .deepOrangeAccent,
                                                      )),
                                                )
                                              : (e.shopStatus == "2")
                                                  ? Container(
                                                      margin: EdgeInsets.only(
                                                          left: 5),
                                                      child: Icon(
                                                        Icons.circle,
                                                        size: 10,
                                                        color: Colors.orange,
                                                      ),
                                                    )
                                                  : (e.shopStatus == "1")
                                                      ? Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 5),
                                                          child: Icon(
                                                            Icons.circle,
                                                            size: 10,
                                                            color: Colors.green,
                                                          ))
                                                      : Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 5),
                                                          child: Icon(
                                                            Icons.close,
                                                            size: 20,
                                                            color: Colors.red,
                                                          ))
                                        ],
                                      ),
                                      (e.shopStatus == "1" ||
                                              e.shopStatus == "2")
                                          ? Switch(
                                              activeColor: Style().darkColor,
                                              value: shopStatusOnline,
                                              onChanged: (value) async {
                                                String str = "offline";
                                                (value == true)
                                                    ? str = "เปิดร้าน"
                                                    : str = "ปิดร้าน";

                                                var resule = await Dialogs()
                                                    .confirm(
                                                        context,
                                                        "$str ร้าน",
                                                        "$str ร้าน " +
                                                            e.shopName);

                                                if (resule == true) {
                                                  if (value == true) {
                                                    db
                                                        .collection('shops')
                                                        .doc(e.shopUid)
                                                        .update({
                                                      "shop_status": "1"
                                                    });
                                                  } else {
                                                    db
                                                        .collection('shops')
                                                        .doc(e.shopUid)
                                                        .update({
                                                      "shop_status": "2"
                                                    });
                                                  }

                                                  shopStatusOnline = value;
                                                  _getAllUser(context
                                                      .read<AppDataModel>());
                                                }
                                              })
                                          : Container()
                                    ],
                                  ),
                                  (showDetail[index] == false)
                                      ? Container()
                                      : Container(
                                          child: SizedBox(
                                            width: screenW * 0.8,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Style().textFlexibleBackSize(
                                                    e.shopAddress, 2, 12),
                                                (e.shopPhone == null)
                                                    ? Style().textBlackSize(
                                                        "tel : ", 12)
                                                    : Style().textBlackSize(
                                                        "tel : " + e.shopPhone,
                                                        12),
                                                (e.shopLocation == null)
                                                    ? Style().textBlackSize(
                                                        "location : ", 12)
                                                    : Style()
                                                        .textFlexibleBackSize(
                                                            "location : " +
                                                                e.shopLocation,
                                                            2,
                                                            12),
                                                (e.shopType == null)
                                                    ? Style().textBlackSize(
                                                        "type : ", 14)
                                                    : Style().textBlackSize(
                                                        "status : " +
                                                            e.shopStatus,
                                                        14),
                                                (e.shopUid == null)
                                                    ? Style().textBlackSize(
                                                        "uid : ", 14)
                                                    : Style().textBlackSize(
                                                        e.shopUid, 10)
                                              ],
                                            ),
                                          ),
                                        )
                                ],
                              ),
                            )
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                print("index = " + index.toString());
                                (showDetail[index] == true)
                                    ? showDetail[index] = false
                                    : showDetail[index] = true;
                              });
                            },
                            icon: (showDetail[index] == false)
                                ? Icon(Icons.arrow_drop_down)
                                : Icon(Icons.arrow_drop_up))
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  buildProductList1(AppDataModel appDataModel) {
    return SingleChildScrollView(
      child: Container(
        child: (allProductData == null ||
                showDetail.length != allProductData.length)
            ? Style().circularProgressIndicator(Style().darkColor)
            : Column(
                children: allProductData.map((e) {
                  int index = allProductData.indexOf(e);
                  String shopName = "";

                  bool productOnline = false;
                  if (e.productStatus == "1") productOnline = true;

                  allShopData.forEach((element) {
                    ShopModel shopModel =
                        shopModelFromJson(jsonEncode(element));
                    if (shopModel.shopUid == e.shopUid) {
                      shopName = shopModel.shopName;
                    }
                  });

                  return Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(top: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            (showDetail[index] == true)
                                ? Container()
                                : Container(
                                    margin: EdgeInsets.only(
                                      left: 10,
                                    ),
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: CachedNetworkImage(
                                        key: UniqueKey(),
                                        imageUrl: e.productPhotoUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                          color: Colors.black12,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: Colors.black12,
                                          child: (Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          )),
                                        ),
                                      ),

                                      // FadeInImage.assetNetwork(
                                      //   fit: BoxFit.fitHeight,
                                      //   placeholder:
                                      //       'assets/images/loading.gif',
                                      //   image: ranProductModel[index]
                                      //       .productPhotoUrl,
                                      // ),
                                    )),
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (showDetail[index] == false)
                                      ? Container()
                                      : Container(
                                          margin: EdgeInsets.only(
                                            left: 10,
                                          ),
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                          ),
                                          child: CachedNetworkImage(
                                            key: UniqueKey(),
                                            imageUrl: e.productPhotoUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              color: Colors.black12,
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              color: Colors.black12,
                                              child: (Icon(
                                                Icons.error,
                                                color: Colors.red,
                                              )),
                                            ),
                                          ),
                                        ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          (e.productName == null)
                                              ? Container()
                                              : Style().textBlackSize(
                                                  e.productName, 14),
                                          (e.productStatus == "3")
                                              ? Container(
                                                  margin:
                                                      EdgeInsets.only(left: 5),
                                                  child: IconButton(
                                                      onPressed: () async {
                                                        var result = await Dialogs()
                                                            .confirm(
                                                                context,
                                                                "ยืนยันสินค้า",
                                                                "ยืนยันสถานะสินค้า");

                                                        if (result != null &&
                                                            result == true) {
                                                          await db
                                                              .collection(
                                                                  "products")
                                                              .doc(e.productId)
                                                              .update({
                                                            "product_status":
                                                                "1"
                                                          }).then((value) {});
                                                          setState(() {
                                                            _getAllUser(
                                                                appDataModel);
                                                          });
                                                        }
                                                      },
                                                      icon: Icon(
                                                        Icons.lock_clock,
                                                        color: Colors
                                                            .deepOrangeAccent,
                                                      )),
                                                )
                                              : (e.productStatus == "2")
                                                  ? Container(
                                                      margin: EdgeInsets.only(
                                                          left: 5),
                                                      child: Icon(
                                                        Icons.circle,
                                                        color: Colors.orange,
                                                        size: 10,
                                                      ),
                                                    )
                                                  : (e.productStatus == "1")
                                                      ? Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 5),
                                                          child: Icon(
                                                              Icons.circle,
                                                              size: 10,
                                                              color:
                                                                  Colors.green))
                                                      : Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 5),
                                                          child: Icon(
                                                            Icons.close,
                                                            color: Colors.red,
                                                          ))
                                        ],
                                      ),
                                      (e.productStatus == "1" ||
                                              e.productStatus == "2")
                                          ? Switch(
                                              activeColor: Style().darkColor,
                                              value: productOnline,
                                              onChanged: (value) async {
                                                String str = "ปิด";
                                                (value == true)
                                                    ? str = "เปิด"
                                                    : str = "ปิด";

                                                var resule = await Dialogs()
                                                    .confirm(
                                                        context,
                                                        "$str สินค้า",
                                                        "$str สินค้า " +
                                                            e.productName);

                                                if (resule == true) {
                                                  if (value == true) {
                                                    db
                                                        .collection('products')
                                                        .doc(e.productId)
                                                        .update({
                                                      "product_status": "1"
                                                    });
                                                  } else {
                                                    db
                                                        .collection('products')
                                                        .doc(e.productId)
                                                        .update({
                                                      "product_status": "2"
                                                    });
                                                  }

                                                  productOnline = value;
                                                  _getAllUser(context
                                                      .read<AppDataModel>());
                                                }
                                              })
                                          : Container()
                                    ],
                                  ),
                                  (showDetail[index] == false)
                                      ? Container()
                                      : Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Style().textBlackSize(
                                                  e.productDetail, 14),
                                              (e.productPrice == null)
                                                  ? Style().textBlackSize(
                                                      "ราคา : ", 14)
                                                  : Style().textBlackSize(
                                                      "ราคา : " +
                                                          e.productPrice,
                                                      14),
                                              (e.productTime == null)
                                                  ? Style().textBlackSize(
                                                      "เวลา : ", 14)
                                                  : Style().textBlackSize(
                                                      "เวลา : " + e.productTime,
                                                      14),
                                              Style()
                                                  .textBlackSize(shopName, 14),
                                              (e.productId == null)
                                                  ? Style().textBlackSize(
                                                      "uid : ", 14)
                                                  : Style().textBlackSize(
                                                      e.productId, 10)
                                            ],
                                          ),
                                        ),
                                  (showDetail[index] == false)
                                      ? (Container())
                                      : Container(
                                          width: screenW * 0.8,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                margin:
                                                    EdgeInsets.only(right: 5),
                                                padding: EdgeInsets.all(1),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        var result =
                                                            await Dialogs()
                                                                .confirm(
                                                          context,
                                                          "ลบสินค้า",
                                                          "ยืนยัน ลบสินค้า",
                                                        );
                                                        if (result != null &&
                                                            result == true) {
                                                          _deleteProduct(
                                                              2,
                                                              e.productId,
                                                              e.productPhotoUrl);
                                                        }
                                                      },
                                                      child: Style()
                                                          .textSizeColor(
                                                              'ลบถาวร',
                                                              14,
                                                              Colors.white),
                                                      style: ElevatedButton.styleFrom(
                                                          primary: Colors.red,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5))),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(right: 5),
                                                padding: EdgeInsets.all(1),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        var result =
                                                            await Dialogs()
                                                                .confirm(
                                                          context,
                                                          "ย้านสินค้า",
                                                          "ยืนยัน ย้านสินค้าไปถังขยะ",
                                                        );
                                                        if (result != null &&
                                                            result == true) {
                                                          _deleteProduct(
                                                              1,
                                                              e.productId,
                                                              e.productPhotoUrl);
                                                        }
                                                      },
                                                      child: Style()
                                                          .textSizeColor(
                                                              'ย้ายไปถังขยะ',
                                                              14,
                                                              Colors.white),
                                                      style: ElevatedButton.styleFrom(
                                                          primary:
                                                              Colors.orange,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5))),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                ],
                              ),
                            )
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                print("index = " + index.toString());
                                (showDetail[index] == true)
                                    ? showDetail[index] = false
                                    : showDetail[index] = true;
                              });
                            },
                            icon: (showDetail[index] == false)
                                ? Icon(Icons.arrow_drop_down)
                                : Icon(Icons.arrow_drop_up))
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  buildProductList(AppDataModel appDataModel) {
    return Container(
      child: (productFilter == null ||
              showDetail.length != productFilter.length ||
              loading == true)
          ? Center(child: Style().loading())
          : Column(
              children: [
                _searchBare(context.read<AppDataModel>()),
                Expanded(
                  child: ListView.builder(
                      controller: scrollControllerProduct,
                      itemCount: amountListViewProduct,
                      itemBuilder: (BuildContext buildContext, int index) {
                        var e = productFilter[index];
                        String shopName = "";

                        allShopData.forEach((element) {
                          ShopModel shopModel =
                              shopModelFromJson(jsonEncode(element));
                          if (shopModel.shopUid == e.shopUid) {
                            shopName = shopModel.shopName;
                          }
                        });

                        return Container(
                          color: Colors.white,
                          margin: EdgeInsets.only(top: 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  (showDetail[index] == true)
                                      ? Container()
                                      : Container(
                                          margin: EdgeInsets.only(
                                            left: 10,
                                          ),
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            child: CachedNetworkImage(
                                              key: UniqueKey(),
                                              imageUrl: e.productPhotoUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Container(
                                                color: Colors.black12,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                color: Colors.black12,
                                                child: (Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                )),
                                              ),
                                            ),

                                            // FadeInImage.assetNetwork(
                                            //   fit: BoxFit.fitHeight,
                                            //   placeholder:
                                            //       'assets/images/loading.gif',
                                            //   image: ranProductModel[index]
                                            //       .productPhotoUrl,
                                            // ),
                                          )),
                                  Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        (showDetail[index] == false)
                                            ? Container()
                                            : Container(
                                                margin: EdgeInsets.only(
                                                  left: 10,
                                                ),
                                                height: 100,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Colors.white,
                                                ),
                                                child: CachedNetworkImage(
                                                  key: UniqueKey(),
                                                  imageUrl: e.productPhotoUrl,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                    color: Colors.black12,
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Container(
                                                    color: Colors.black12,
                                                    child: (Icon(
                                                      Icons.error,
                                                      color: Colors.red,
                                                    )),
                                                  ),
                                                ),
                                              ),
                                        Row(
                                          children: [
                                            (e.productName == null)
                                                ? Container()
                                                : Container(
                                                    width: screenW * 0.5,
                                                    child: Style()
                                                        .textFlexibleBackSize(
                                                            e.productName,
                                                            2,
                                                            14),
                                                  ),
                                            (e.productStatus == "3")
                                                ? Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5),
                                                    child: IconButton(
                                                        onPressed: () async {
                                                          var result = await Dialogs()
                                                              .confirm(
                                                                  context,
                                                                  "ยืนยันสินค้า",
                                                                  "ยืนยันสถานะสินค้า");

                                                          if (result != null &&
                                                              result == true) {
                                                            await db
                                                                .collection(
                                                                    "products")
                                                                .doc(
                                                                    e.productId)
                                                                .update({
                                                              "product_status":
                                                                  "1"
                                                            }).then((value) {});
                                                            await db
                                                                .collection(
                                                                    "products")
                                                                .get()
                                                                .then((value) {
                                                              var jsonData =
                                                                  setList2Json(
                                                                      value);
                                                              appDataModel
                                                                      .allProductData =
                                                                  productsModelFromJson(
                                                                      jsonData);
                                                              allProductData =
                                                                  appDataModel
                                                                      .allProductData;
                                                              productFilter =
                                                                  allProductData;
                                                            });

                                                            if (isChecked) {
                                                              productFilter = allProductData
                                                                  .where((element) => (element
                                                                          .productStatus)
                                                                      .contains(
                                                                          "3"))
                                                                  .toList();
                                                            } else {
                                                              productFilter =
                                                                  allProductData;
                                                            }

                                                            setState(() {});
                                                          }
                                                        },
                                                        icon: Icon(
                                                          Icons.lock_clock,
                                                          color: Colors
                                                              .deepOrangeAccent,
                                                        )),
                                                  )
                                                : (e.productStatus == "2")
                                                    ? Container(
                                                        margin: EdgeInsets.only(
                                                            left: 5),
                                                        child: Icon(
                                                          Icons.circle,
                                                          color: Colors.orange,
                                                          size: 10,
                                                        ),
                                                      )
                                                    : (e.productStatus == "1")
                                                        ? Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 5),
                                                            child: Icon(
                                                                Icons.circle,
                                                                size: 10,
                                                                color: Colors
                                                                    .green))
                                                        : Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 5),
                                                            child: Icon(
                                                              Icons.close,
                                                              color: Colors.red,
                                                            ))
                                          ],
                                        ),
                                        (showDetail[index] == false)
                                            ? Container()
                                            : Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: screenW * 0.6,
                                                      child: Style()
                                                          .textFlexibleBackSize(
                                                              e.productDetail,
                                                              2,
                                                              14),
                                                    ),
                                                    (e.productPrice == null)
                                                        ? Style().textBlackSize(
                                                            "ราคา : ", 14)
                                                        : Style().textBlackSize(
                                                            "ราคาหน้าร้าน : " +
                                                                e.productOriPrice,
                                                            14),
                                                    (e.productPrice == null)
                                                        ? Style().textBlackSize(
                                                            "ราคา : ", 14)
                                                        : Row(
                                                            children: [
                                                              Style().textBlackSize(
                                                                  "ราคาแอพ : " +
                                                                      e.productPrice +
                                                                      " ",
                                                                  14),
                                                              InkWell(
                                                                onTap:
                                                                    () async {
                                                                  _productIdSelect =
                                                                      e.productId;
                                                                  _fullPrice
                                                                          .text =
                                                                      e.productPrice;

                                                                  await _displayTextInputDialog(
                                                                      context);
                                                                  await _getAllUser(
                                                                      context.read<
                                                                          AppDataModel>());
                                                                  if (isChecked ==
                                                                      true)
                                                                    _checkWork();
                                                                },
                                                                child: Icon(
                                                                  Icons.edit,
                                                                  size: 20,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                    (e.productTime == null)
                                                        ? Style().textBlackSize(
                                                            "เวลา : ", 14)
                                                        : Style().textBlackSize(
                                                            "เวลา : " +
                                                                e.productTime,
                                                            14),
                                                    Style().textBlackSize(
                                                        shopName, 14),
                                                    (e.productId == null)
                                                        ? Style().textBlackSize(
                                                            "uid : ", 14)
                                                        : Style().textBlackSize(
                                                            e.productId, 10)
                                                  ],
                                                ),
                                              ),
                                        (showDetail[index] == false)
                                            ? (Container())
                                            : Container(
                                                width: screenW * 0.8,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 5),
                                                      padding:
                                                          EdgeInsets.all(1),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              var result =
                                                                  await Dialogs()
                                                                      .confirm(
                                                                context,
                                                                "ลบสินค้า",
                                                                "ยืนยัน ลบสินค้า",
                                                              );
                                                              if (result !=
                                                                      null &&
                                                                  result ==
                                                                      true) {
                                                                _deleteProduct(
                                                                  2,
                                                                  e.productId,
                                                                  e.productPhotoUrl,
                                                                );
                                                              }
                                                            },
                                                            child: Style()
                                                                .textSizeColor(
                                                                    'ลบถาวร',
                                                                    14,
                                                                    Colors
                                                                        .white),
                                                            style: ElevatedButton.styleFrom(
                                                                primary:
                                                                    Colors.red,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5))),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 5),
                                                      padding:
                                                          EdgeInsets.all(1),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              var result =
                                                                  await Dialogs()
                                                                      .confirm(
                                                                context,
                                                                "ย้านสินค้า",
                                                                "ยืนยัน ย้านสินค้าไปถังขยะ",
                                                              );
                                                              if (result !=
                                                                      null &&
                                                                  result ==
                                                                      true) {
                                                                _deleteProduct(
                                                                  1,
                                                                  e.productId,
                                                                  e.productPhotoUrl,
                                                                );
                                                              }
                                                            },
                                                            child: Style()
                                                                .textSizeColor(
                                                                    'ย้ายไปถังขยะ',
                                                                    14,
                                                                    Colors
                                                                        .white),
                                                            style: ElevatedButton.styleFrom(
                                                                primary: Colors
                                                                    .orange,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5))),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      print("index = " + index.toString());
                                      (showDetail[index] == true)
                                          ? showDetail[index] = false
                                          : showDetail[index] = true;
                                    });
                                  },
                                  icon: (showDetail[index] == false)
                                      ? Icon(Icons.arrow_drop_down)
                                      : Icon(Icons.arrow_drop_up))
                            ],
                          ),
                        );
                      }),
                )
              ],
            ),
    );
  }

  buildRiderList() {
    return SingleChildScrollView(
      child: Container(
        child: (allDriverData == null ||
                showDetail.length != allDriverData.length)
            ? Style().circularProgressIndicator(Style().darkColor)
            : Column(
                children: allDriverData.map((e) {
                  int index = allDriverData.indexOf(e);
                  bool riderStatusOnline = false;
                  if (e.driverStatus == "1") riderStatusOnline = true;
                  print(index);
                  return Container(
                    color: Colors.white,
                    margin: EdgeInsets.only(top: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            (showDetail[index] == true)
                                ? Container()
                                : Container(
                                    margin: EdgeInsets.only(
                                      left: 10,
                                    ),
                                    height: 40,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: CachedNetworkImage(
                                        key: UniqueKey(),
                                        imageUrl: e.driverPhotoUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                          color: Colors.black12,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: Colors.black12,
                                          child: (Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          )),
                                        ),
                                      ),

                                      // FadeInImage.assetNetwork(
                                      //   fit: BoxFit.fitHeight,
                                      //   placeholder:
                                      //       'assets/images/loading.gif',
                                      //   image: ranProductModel[index]
                                      //       .productPhotoUrl,
                                      // ),
                                    )),
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (showDetail[index] == false)
                                      ? Container()
                                      : Container(
                                          margin: EdgeInsets.only(
                                            left: 10,
                                          ),
                                          height: 100,
                                          width: 170,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            child: CachedNetworkImage(
                                              key: UniqueKey(),
                                              imageUrl: e.driverPhotoUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Container(
                                                color: Colors.black12,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                color: Colors.black12,
                                                child: (Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                )),
                                              ),
                                            ),

                                            // FadeInImage.assetNetwork(
                                            //   fit: BoxFit.fitHeight,
                                            //   placeholder:
                                            //       'assets/images/loading.gif',
                                            //   image: ranProductModel[index]
                                            //       .productPhotoUrl,
                                            // ),
                                          )),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Style()
                                              .textBlackSize(e.driverName, 14),
                                          (e.driverStatus == "1" ||
                                                  e.driverStatus == "0")
                                              ? Switch(
                                                  activeColor:
                                                      Style().darkColor,
                                                  value: riderStatusOnline,
                                                  onChanged: (value) async {
                                                    String str = "offline";
                                                    (value == true)
                                                        ? str = "online"
                                                        : str = "offline";

                                                    var resule = await Dialogs()
                                                        .confirm(
                                                            context,
                                                            "Rider $str",
                                                            "เปลี่ยน Rider " +
                                                                e.driverName +
                                                                " $str");

                                                    if (resule == true) {
                                                      if (value == true) {
                                                        db
                                                            .collection(
                                                                'drivers')
                                                            .doc(e.driverId)
                                                            .update({
                                                          "driverStatus": "1"
                                                        });
                                                      } else {
                                                        db
                                                            .collection(
                                                                'drivers')
                                                            .doc(e.driverId)
                                                            .update({
                                                          "driverStatus": "0"
                                                        });
                                                      }

                                                      riderStatusOnline = value;
                                                      _getAllUser(context.read<
                                                          AppDataModel>());
                                                    }
                                                  })
                                              : Container()
                                        ],
                                      ),
                                      (e.driverStatus == "3")
                                          ? Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: IconButton(
                                                  onPressed: () async {
                                                    var result =
                                                        await Dialogs().confirm(
                                                      context,
                                                      "ยืนยันRider",
                                                      "ยืนยันสถานะRider",
                                                    );

                                                    if (result != null &&
                                                        result == true) {
                                                      await db
                                                          .collection("drivers")
                                                          .doc(e.driverId)
                                                          .update({
                                                        "driverStatus": "1"
                                                      }).then((value) {
                                                        notifySend(
                                                            e.token,
                                                            "สถานะ Rider",
                                                            "Rider " +
                                                                e.driverName +
                                                                " ได้รับการยืนยันแล้ว");
                                                      });
                                                      setState(() {
                                                        _getAllUser(context.read<
                                                            AppDataModel>());
                                                      });
                                                    }
                                                  },
                                                  icon: Icon(
                                                    Icons.lock_clock,
                                                    color:
                                                        Colors.yellow.shade600,
                                                    size: 20,
                                                  )),
                                            )
                                          : (e.driverStatus == "2")
                                              ? Container(
                                                  margin:
                                                      EdgeInsets.only(left: 5),
                                                  child: Icon(
                                                    Icons.motorcycle,
                                                    size: 20,
                                                    color: Colors.blueAccent,
                                                  ),
                                                )
                                              : (e.driverStatus == "1")
                                                  ? Container(
                                                      margin: EdgeInsets.only(
                                                          left: 5),
                                                      child: Icon(
                                                        Icons.circle,
                                                        size: 10,
                                                        color: Colors.green,
                                                      ))
                                                  : (e.driverStatus == "4")
                                                      ? Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 5),
                                                          child: Icon(
                                                            Icons.block,
                                                            size: 20,
                                                            color: Colors.red,
                                                          ))
                                                      : Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 5),
                                                          child: Icon(
                                                            Icons.circle,
                                                            size: 10,
                                                            color:
                                                                Colors.orange,
                                                          ))
                                    ],
                                  ),
                                  (showDetail[index] == false)
                                      ? Container()
                                      : SizedBox(
                                          width: screenW * 0.7,
                                          child: Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Style().textFlexibleBackSize(
                                                    "Status = " +
                                                        e.driverStatus,
                                                    2,
                                                    12),
                                                Style().textFlexibleBackSize(
                                                    e.driverAddress, 2, 12),
                                                (e.driverPhone == null)
                                                    ? Style()
                                                        .textFlexibleBackSize(
                                                            "tel : ", 2, 12)
                                                    : Style()
                                                        .textFlexibleBackSize(
                                                            "tel : " +
                                                                e.driverPhone,
                                                            2,
                                                            12),
                                                (e.driverLocation == null)
                                                    ? Style()
                                                        .textFlexibleBackSize(
                                                            "location : ",
                                                            2,
                                                            12)
                                                    : Style()
                                                        .textFlexibleBackSize(
                                                            "location : " +
                                                                e.driverLocation,
                                                            2,
                                                            12),
                                                (e.driverId == null)
                                                    ? Style()
                                                        .textFlexibleBackSize(
                                                            "uid : ", 2, 12)
                                                    : Style()
                                                        .textFlexibleBackSize(
                                                            e.driverId, 2, 10)
                                              ],
                                            ),
                                          ),
                                        )
                                ],
                              ),
                            )
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                print("index = " + index.toString());
                                (showDetail[index] == true)
                                    ? showDetail[index] = false
                                    : showDetail[index] = true;
                              });
                            },
                            icon: (showDetail[index] == false)
                                ? Icon(Icons.arrow_drop_down)
                                : Icon(Icons.arrow_drop_up))
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  _deleteProduct(int cmd, String productID, String photoUrl) async {
    if (cmd == 1) {
      await db
          .collection("products")
          .doc(productID)
          .update({"product_status": "3"}).then((value) async {
        await Dialogs().information(
          context,
          Style().textBlackSize("สำเร็จ", 16),
          Style().textBlackSize("ย้านสินค้าไปถังขยะแล้ว", 14),
        );
      });
    } else if (cmd == 2) {
      await db
          .collection("products")
          .doc(productID)
          .delete()
          .then((value) async {
        await FirebaseStorage.instance
            .refFromURL(photoUrl)
            .delete()
            .then((value) async {
          await Dialogs().information(
            context,
            Style().textBlackSize("สำเร็จ", 16),
            Style().textBlackSize("ลบสินค้าแล้ว", 14),
          );
        });
      });
    }
    setState(() {
      _getAllUser(context.read<AppDataModel>());
    });
  }

  _onItemTapped(int index) {
    print(index.toString());
    isChecked = false;
    _textControl = null;
    _getAllUser(context.read<AppDataModel>());

    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 1) {
        showDetail = [];
        headerText = allUserData.length.toString();
        allUserData.forEach((element) {
          showDetail.add(false);
        });
      } else if (_selectedIndex == 2) {
        showDetail = [];
        headerText = allShopData.length.toString();
        allShopData.forEach((element) {
          showDetail.add(false);
        });
      } else if (_selectedIndex == 3) {
        showDetail = [];
        headerText = allProductData.length.toString();
        allProductData.forEach((element) {
          showDetail.add(false);
        });
      } else if (_selectedIndex == 4) {
        showDetail = [];
        headerText = allDriverData.length.toString();
        allDriverData.forEach((element) {
          showDetail.add(false);
        });
      }
    });
  }

  _searchProduct(AppDataModel appDataModel) {
    print(_textControl.text);
    if (_textControl != null) {
      showDetail = [];
      allProductData = appDataModel.allProductData
          .where((e) => (e.productName).contains(_textControl.text))
          .toList();
      allProductData.forEach((element) {
        showDetail.add(false);
      });
      setState(() {});
    }
  }

  _waitForReviewProduct(AppDataModel appDataModel, bool waitForReviww) async {
    if (waitForReviww == true) {
      showDetail = [];
      allProductData = appDataModel.allProductData
          .where((e) => (e.productStatus).contains("3"))
          .toList();
      allProductData.forEach((element) {
        showDetail.add(false);
      });
    } else {
      showDetail = [];
      allProductData = appDataModel.allProductData;
      allProductData.forEach((element) {
        showDetail.add(false);
      });
    }
  }

  _searchUser(AppDataModel appDataModel) {
    _textControl.text = "";
    print(_textControl.text);
    if (_textControl != null) {
      showDetail = [];
      allUserData = appDataModel.alluserData
          .where((e) => (e.name).contains(_textControl.text))
          .toList();
      allUserData.forEach((element) {
        showDetail.add(false);
      });
      setState(() {});
    }
  }

  _waitForReviewUser(AppDataModel appDataModel, bool waitForReviww) async {
    if (waitForReviww == true) {
      showDetail = [];
      allUserData = appDataModel.alluserData
          .where((e) => (e.status).contains("3"))
          .toList();
      allUserData.forEach((element) {
        showDetail.add(false);
      });
    } else {
      showDetail = [];
      allUserData = appDataModel.alluserData;
      allUserData.forEach((element) {
        showDetail.add(false);
      });
    }
  }

  _searcShop(AppDataModel appDataModel) {
    print(_textControl.text);
    if (_textControl != null) {
      showDetail = [];
      allShopData = appDataModel.allShopData
          .where((e) => (e.shopName).contains(_textControl.text))
          .toList();
      allShopData.forEach((element) {
        showDetail.add(false);
      });
      setState(() {});
    }
  }

  _waitForReviewShop(AppDataModel appDataModel, bool waitForReviww) async {
    if (waitForReviww == true) {
      showDetail = [];
      allShopData = appDataModel.allShopData
          .where((e) => (e.shopStatus).contains("3"))
          .toList();
      allShopData.forEach((element) {
        showDetail.add(false);
      });
    } else {
      showDetail = [];
      allShopData = appDataModel.allShopData;
      allShopData.forEach((element) {
        showDetail.add(false);
      });
    }
  }

  _searcRider(AppDataModel appDataModel) {
    print(_textControl.text);
    if (_textControl != null) {
      showDetail = [];
      allDriverData = appDataModel.allRiderData
          .where((e) => (e.driverName).contains(_textControl.text))
          .toList();
      allDriverData.forEach((element) {
        showDetail.add(false);
      });
      setState(() {});
    }
  }

  _waitForReviewRider(AppDataModel appDataModel, bool waitForReviww) async {
    if (waitForReviww == true) {
      showDetail = [];
      allDriverData = appDataModel.allRiderData
          .where((e) => (e.driverStatus).contains("3"))
          .toList();
      allDriverData.forEach((element) {
        showDetail.add(false);
      });
    } else {
      showDetail = [];
      allDriverData = appDataModel.allRiderData;
      allDriverData.forEach((element) {
        showDetail.add(false);
      });
    }
  }

  _searchBare(AppDataModel appDataModel) {
    int textfieldw = 40;
    return Container(
      child: Row(
        children: [
          (_selectedIndex == 1)
              ? Container()
              : Row(
                  children: [
                    Checkbox(
                      checkColor: Colors.white,
                      value: isChecked,
                      onChanged: (bool value) {
                        isChecked = value;
                        _checkWork();
                      },
                    ),
                    Style().textSizeColor("รอยืนยัน", 14, Colors.black)
                  ],
                ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              height: double.parse(textfieldw.toString()),
              margin: EdgeInsets.only(left: 10, right: 10, top: 3),
              child: TextField(
                style: TextStyle(
                    fontFamily: "prompt", fontSize: 14, color: Colors.black),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                      left: 5,
                      bottom: textfieldw / 4, // HERE THE IMPORTANT PART
                    ),
                    hintText: 'ค้นหา',
                    hintStyle: TextStyle(
                        fontFamily: "prompt",
                        fontSize: 14,
                        color: Colors.black),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        borderSide: BorderSide.none),
                    suffixIcon: InkWell(
                      onTap: () {
                        print("text Icon select");
                      },
                      child: Icon(
                        FontAwesomeIcons.search,
                        color: Colors.red,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white),
                controller: _searchSelect,
                onChanged: (value) {
                  _searchWork(context.read<AppDataModel>());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _checkWork() {
    if (_selectedIndex == 2) {
      // if (isChecked) {
      //   shopFilter = allShopData
      //       .where((element) => (element.shopStatus).contains("3"))
      //       .toList();
      //   if (this.mounted) {
      //     setState(() {
      //       (shopFilter.length > 20)
      //           ? amountListViewShop = 20
      //           : amountListViewShop = shopFilter.length;
      //     });
      //   }
      // } else {
      //   shopFilter = allShopData;
      //   setState(() {
      //     (shopFilter.length > 20)
      //         ? amountListViewShop = 20
      //         : amountListViewShop = shopFilter.length;
      //   });
      // }
    } else if (_selectedIndex == 3) {
      if (isChecked) {
        productFilter = allProductData
            .where((element) => (element.productStatus).contains("3"))
            .toList();

        if (showDetail.length != productFilter.length) {
          showDetail = [];
          productFilter.forEach((element) {
            showDetail.add(false);
          });
        }

        setState(() {
          (productFilter.length > 20)
              ? amountListViewProduct = 20
              : amountListViewProduct = productFilter.length;
        });
      } else {
        productFilter = allProductData;
        showDetail = [];
        productFilter.forEach((element) {
          showDetail.add(false);
        });
        setState(() {
          (productFilter.length > 20)
              ? amountListViewProduct = 20
              : amountListViewProduct = productFilter.length;
        });
      }
    } else if (_selectedIndex == 4) {
      // if (isChecked) {
      //   driverFliter = allDriverData
      //       .where((element) => (element.driverStatus).contains("3"))
      //       .toList();

      //   showDetail = [];
      //   driverFliter.forEach((element) {
      //     showDetail.add(false);
      //   });
      //   setState(() {
      //     (driverFliter.length > 20)
      //         ? amountListViewRider = 20
      //         : amountListViewRider = driverFliter.length;
      //   });
      // } else {
      //   driverFliter = allDriverData;
      //   setState(() {
      //     (driverFliter.length > 20)
      //         ? amountListViewRider = 20
      //         : amountListViewRider = driverFliter.length;
      //   });
      // }
    }
  }

  _searchWork(AppDataModel appDataModel) {
    if (_selectedIndex == 1) {
      // userFilter = allUserData
      //     .where((element) =>
      //         (element.name).contains(_searchSelect.text) ||
      //         (element.email).contains(_searchSelect.text) ||
      //         (element.uid).contains(_searchSelect.text))
      //     .toList();
      // setState(() {});
    } else if (_selectedIndex == 2) {
      // shopFilter = allShopData
      //     .where((element) =>
      //         (element.shopName).contains(_searchSelect.text) ||
      //         (element.shopFullAddress).contains(_searchSelect.text))
      //     .toList();
      // setState(() {
      //   (shopFilter.length > 20)
      //       ? amountListViewShop = 20
      //       : amountListViewShop = shopFilter.length;
      // });
    } else if (_selectedIndex == 3) {
      productFilter = allProductData
          .where(
              (element) => (element.productName).contains(_searchSelect.text))
          .toList();
      showDetail = [];
      productFilter.forEach((element) {
        showDetail.add(false);
      });

      setState(() {
        (productFilter.length > 20)
            ? amountListViewProduct = 20
            : amountListViewProduct = productFilter.length;
      });
    } else if (_selectedIndex == 4) {
      // driverFliter = allDriverData
      //     .where((element) =>
      //         (element.driverName).contains(_searchSelect.text) ||
      //         (element.driverId).contains(_searchSelect.text))
      //     .toList();

      // showDetail = [];
      // driverFliter.forEach((element) {
      //   showDetail.add(false);
      // });

      // setState(() {
      //   (driverFliter.length > 20)
      //       ? amountListViewRider = 20
      //       : amountListViewRider = driverFliter.length;
      // });
    }
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Style().textBlackSize("ราคาบนแอพ", 16),
            content: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {});
              },
              controller: _fullPrice,
              decoration: InputDecoration(hintText: "ระบุราคา"),
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
                    await db
                        .collection("products")
                        .doc(_productIdSelect)
                        .update({"product_price": _fullPrice.text});
                    Navigator.pop(context, true);
                  },
                  child: Style().textSizeColor("ตกลง", 14, Style().darkColor)),
            ],
          );
        });
  }

  _adminDrawer() {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: SafeArea(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.tags),
                  Expanded(
                    child: ListTile(
                      title: Style()
                          .textSizeColor("Code ส่วนลด", 14, Colors.black),
                      onTap: () {
                        Navigator.pushNamed(context, "/adminDoce-page",
                            arguments: "allapp");
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.ad),
                  Expanded(
                    child: ListTile(
                      title:
                          Style().textSizeColor("แบนเนอร์", 14, Colors.black),
                      onTap: () {
                        Navigator.pushNamed(context, "/adminAdManage-page");
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.moneyBill),
                  Expanded(
                    child: ListTile(
                      title: Style()
                          .textSizeColor("ตั้งค่าบริการ", 14, Colors.black),
                      onTap: () {
                        Navigator.pushNamed(context, "/serviceSetting-page");
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.university),
                  Expanded(
                    child: ListTile(
                      title: Style()
                          .textSizeColor("บัญชีธนาคาร", 14, Colors.black),
                      onTap: () {
                        Navigator.pushNamed(context, "/adminBankAccount-page");
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.phone),
                  Expanded(
                    child: ListTile(
                      title: Style()
                          .textSizeColor("ข้อมูลติดต่อ", 14, Colors.black),
                      onTap: () {
                        Navigator.pushNamed(context, "/adminContactData-page");
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.database),
                  Expanded(
                    child: ListTile(
                      title:
                          Style().textSizeColor("จัดการDB", 14, Colors.black),
                      onTap: () {
                        Navigator.pushNamed(context, "/adminSystem-page");
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    FontAwesomeIcons.powerOff,
                    color: Colors.red,
                  ),
                  Expanded(
                    child: ListTile(
                      title: Row(
                        children: [
                          Style().textSizeColor("สถานะแอพ", 14, Colors.black),
                        ],
                      ),
                      onTap: () {},
                    ),
                  ),
                  (appSetupModel == null)
                      ? Container()
                      : Switch(
                          activeColor: Style().darkColor,
                          value: appSetupModel.status,
                          onChanged: (value) async {
                            String text = "";

                            if (value == true) {
                              text = "เปิดใช้งานแอพ";
                            } else {
                              text = "ปิดใช้งานแอพชั่วคราว";
                            }

                            var _result = await Dialogs()
                                .confirm(context, text, 'ยืนยัน $text');
                            if (_result == true) {
                              await db
                                  .collection('setup')
                                  .doc("app")
                                  .update({"status": value});
                              setState(() {
                                appSetupModel.status = value;
                              });
                            }
                          })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
