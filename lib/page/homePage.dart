import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:math';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/GasSetupModel.dart';
import 'package:hro/model/MartSetupModel.dart';
import 'package:hro/model/UserOneModel.dart';
import 'package:hro/model/adsAppModel.dart';
import 'package:hro/model/allShopModel.dart';
import 'package:hro/model/cartModel.dart';

import 'package:hro/model/locationSetupModel.dart';
import 'package:hro/model/orderModel.dart';

import 'package:hro/model/productsModel.dart';
import 'package:hro/model/promoteListModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/page/fireBaseFunctions.dart';

import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/checkLocation.dart';
import 'package:hro/utility/getAddressName.dart';

import 'package:hro/utility/getAndSetLocation.dart';
import 'package:hro/utility/newDialog.dart';
import 'package:hro/utility/ranDomData.dart';
import 'package:hro/utility/snapshot2list.dart';

import 'package:hro/utility/style.dart';
import 'package:hro/utility/updateToken.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';

import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<HomePage> {
  Dialogs dialogs = Dialogs();
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static final GoogleSignIn googleSignIn = new GoogleSignIn();

  bool getAllShopStatus = false;
  int orderNew = 0;
  int pcs = 0;
  int orderActiveCount = 0;
  List<OrderList> orderList;
  List<ProductsModel> ranProductModel;
  List<AllShopModel> ranShopModel;
  List<AllShopModel> allShopModelFilter;
  List<ProductsModel> allProductModelFilter;
  int productLength;
  bool getData = false;
  int limitProduct = 100;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String goPage = "";
  String title = '';
  String body = "";

  String addressString;

  double userlat, userlng;
  double screenW;

  List<AdsAppListModel> adsAppListData;
  MartSetupModel martSetupData;
  GasSetupModel gasSetupData;

  PromoteListModel promoteListModel;

  // Triggers fecth() and then add new items or change _hasMore flag
  _getAdsApp() async {
    await db.collection("adsApp").get().then((value) {
      var jsonData = setList2Json(value);
      adsAppListData = adsAppListModelFromJson(jsonData);
      adsAppListData = randomData(adsAppListData);
    });
    if (this.mounted) {
      setState(() {});
    }
  }

  _getAllShop(AppDataModel appDataModel) async {
    screenW = appDataModel.screenW;

    if (appDataModel.loginStatus == true) {
      String token = await firebaseMessaging.getToken();
      print('NotiToken = ' + token.toString());
      appDataModel.token = token;

      await db
          .collection("users")
          .where("email", isEqualTo: "overtechth@gmail.com")
          .limit(1)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          var jsonData = jsonEncode(element.data());
          print("jsonUser = " + jsonData);
          UserOneModel userModel = userOneModelFromJson(jsonData);
          print('Admintoken = ' + userModel.token);
          appDataModel.adminToken = userModel.token;
        });
      });
      await updateToken(appDataModel.userOneModel.uid, token);
      await updateOs(appDataModel.userOneModel.uid, appDataModel.os);
    }

    CollectionReference shops = FirebaseFirestore.instance.collection('shops');

    // await getAndSetLocation(appDataModel.userOneModel.uid);

    await shops.get().then((value) {
      List<DocumentSnapshot> templist;
      List list = new List();
      templist = value.docs;
      list = templist.map((DocumentSnapshot docSnapshot) {
        return docSnapshot.data();
      }).toList();
      var jsonData = jsonEncode(list);
      //print('allShopJsonData' + jsonData.toString());
      appDataModel.allShopData = allShopModelFromJson(jsonData);
      appDataModel.allFullShopData = allShopModelFromJson(jsonData);
      print(appDataModel.allShopData.length);
      _getAllProduct(context.read<AppDataModel>());
      int shopLength = 0;

      allShopModelFilter = appDataModel.allShopData
          .where((e) => (e.shopStatus).contains("1"))
          .toList();

      // allShopModelFilter = appDataModel.allShopData
      //     .where((element) => (element.shopStatus).contains("1"))
      //     .toList();

      print("allShopModelFilter = " + allShopModelFilter.length.toString());
      (allShopModelFilter.length < 10)
          ? shopLength = allShopModelFilter.length
          : shopLength = 10;
      List<String> ranShop = [];
      for (int i = 0; i < shopLength;) {
        var randomItem = (allShopModelFilter..shuffle()).first;
        bool sameData = false;
        ranShop.forEach((element) {
          if (element == jsonEncode(randomItem)) sameData = true;
        });
        if (sameData == false) {
          ranShop.add(jsonEncode(randomItem));
          i++;
        }
      }
      String rowData = ranShop.toString();
      ranShopModel = allShopModelFromJson(rowData);
      print("randomShopCount" + ranShopModel.length.toString());
      ranShopModel.forEach((element) {});
    }).catchError((onError) {
      appDataModel.allShopData = null;
      print(onError.toString());
    });
    if (this.mounted) {
      setState(() {});
    }
  }

  _setLocation(AppDataModel appDataModel) async {
    if (appDataModel.loginStatus == true) {
      var _locationService = await checkLocationService();
      if (_locationService == true) {
        var _locationSPermission = await checkLocationSPermission();
        print("_locationSPermission $_locationSPermission");

        if (_locationSPermission == true) {
          try {
            await Geolocator.getCurrentPosition().then((value) {
              userlat = value.latitude;
              userlng = value.longitude;
              appDataModel.userLat = userlat;
              appDataModel.userLng = userlng;
            }).catchError((error) {
              List<String> locationLatLng =
                  appDataModel.locationSetupModel.centerLocation.split(",");
              if (userlat == null || userlng == null) {
                userlat = double.parse(locationLatLng[0]);
                userlng = double.parse(locationLatLng[1]);
                appDataModel.userLat = userlat;
                appDataModel.userLng = userlng;
              }
            });
          } on Exception catch (_) {
            print('never reached');
            return null;
          }
        } else {
          List<String> locationLatLng =
              appDataModel.locationSetupModel.centerLocation.split(",");
          if (userlat == null || userlng == null) {
            userlat = double.parse(locationLatLng[0]);
            userlng = double.parse(locationLatLng[1]);
            appDataModel.userLat = userlat;
            appDataModel.userLng = userlng;
          }
        }
      } else {
        List<String> locationLatLng =
            appDataModel.locationSetupModel.centerLocation.split(",");
        if (userlat == null || userlng == null) {
          userlat = double.parse(locationLatLng[0]);
          userlng = double.parse(locationLatLng[1]);
          appDataModel.userLat = userlat;
          appDataModel.userLng = userlng;
        }
      }

      addressString = await getAddressName(userlat, userlng);
      if (this.mounted) {
        setState(() {});
      }
    }
  }

  _getAllProduct(AppDataModel appDataModel) async {
    print('getAllProduct');
    CollectionReference products =
        FirebaseFirestore.instance.collection('products');
    await products
        .where('product_status', isEqualTo: '1')
        .get()
        .then((value) async {
      List<DocumentSnapshot> templist;
      List list = new List();
      templist = value.docs;
      list = templist.map((DocumentSnapshot docSnapshot) {
        return docSnapshot.data();
      }).toList();
      var jsonData = jsonEncode(list);
      //print('allProductJsonData' + jsonData.toString());
      appDataModel.allProductsData = productsModelFromJson(jsonData);
      print('allProduct = ' + appDataModel.allProductsData.length.toString());

      productLength = 0;

      allProductModelFilter = appDataModel.allProductsData
          .where((element) => (element.productStatus).contains("1"))
          .toList();

      print(
          "allProductModelFilter = " + allProductModelFilter.length.toString());

      List<dynamic> indexRemove = [];
      allProductModelFilter.asMap().forEach((i, e) {
        appDataModel.allShopData.forEach((element) {
          if (e.shopUid == element.shopUid) {
            if (element.shopStatus == "2") {
              indexRemove.add(e);
            }
          }
        });
      });

      indexRemove.forEach((element) {
        allProductModelFilter.remove(element);
      });
      print("allProductModelFilterRemove = " +
          allProductModelFilter.length.toString());

      (allProductModelFilter.length < limitProduct)
          ? productLength = allProductModelFilter.length
          : productLength = limitProduct;
      List<String> ranProductList = [];
      for (int i = 0; i < productLength;) {
        var randomItem = (allProductModelFilter..shuffle()).first;
        bool sameData = false;
        ranProductList.forEach((element) {
          if (element == jsonEncode(randomItem)) sameData = true;
        });
        if (sameData == false) {
          ranProductList.add(jsonEncode(randomItem));
          i++;
        }
      }

      String rowData = ranProductList.toString();
      ranProductModel = productsModelFromJson(rowData);
      print("randomCount" + ranProductModel.length.toString());

      ranProductModel.forEach((element) {});
    }).catchError((onError) {
      appDataModel.allProductsData = null;
      print(onError.toString());
    });

    // getOrder
    getAllShopStatus = true;
    if (this.mounted) {
      setState(() {});
    }
  }

  _reRandomData(AppDataModel appDataModel) async {
    setState(() {
      ranProductModel = null;
      ranShopModel = null;
    });

    productLength = 0;
    allProductModelFilter = null;
    allProductModelFilter = appDataModel.allProductsData
        .where((element) => (element.productStatus).contains("1"))
        .toList();

    (allProductModelFilter.length < limitProduct)
        ? productLength = allProductModelFilter.length
        : productLength = limitProduct;
    List<String> ranProductList = [];
    for (int i = 0; i < productLength;) {
      var randomItem = (allProductModelFilter..shuffle()).first;
      bool sameData = false;
      ranProductList.forEach((element) async {
        if (element == jsonEncode(randomItem)) sameData = true;
      });
      if (sameData == false) {
        ranProductList.add(jsonEncode(randomItem));
        i++;
      }
    }

    String rowData = ranProductList.toString();
    ranProductModel = productsModelFromJson(rowData);
    print("Re-randomProduct" + ranProductModel.length.toString());

    int shopLength = 0;
    allShopModelFilter = null;
    allShopModelFilter = appDataModel.allShopData;
    print("Re-random Shop = " + allShopModelFilter.length.toString());
    (allShopModelFilter.length < 10)
        ? shopLength = allShopModelFilter.length
        : shopLength = 10;
    List<String> ranShop = [];
    for (int i = 0; i < shopLength;) {
      var randomItem = (allShopModelFilter..shuffle()).first;
      bool sameData = false;
      ranShop.forEach((element) {
        if (element == jsonEncode(randomItem)) sameData = true;
      });
      if (sameData == false) {
        ranShop.add(jsonEncode(randomItem));
        i++;
      }
    }
    String rowData2 = ranShop.toString();
    ranShopModel = allShopModelFromJson(rowData2);
    setState(() {});
  }

  getRandomElement<T>(List<T> list) {
    final random = new Random();
    var i = random.nextInt(list.length);
    return list[i];
  }

  _getLocationSetup(AppDataModel appDataModel) async {
    await db.collection('appstatus').doc('locationSetup').get().then((value) {
      print("locationSetup" + jsonEncode(value.data()));
      var jsonData = jsonEncode(value.data());
      appDataModel.locationSetupModel = locationSetupModelFromJson(jsonData);
      List<String> locationLatLng =
          appDataModel.locationSetupModel.centerLocation.split(",");
      appDataModel.latStart = double.parse(locationLatLng[0]);
      appDataModel.lngStart = double.parse(locationLatLng[1]);
      appDataModel.distanceLimit =
          double.parse(appDataModel.locationSetupModel.distanceMax);
    });
  }

  _getSetup() async {
    var _martDb = await dbGetDataOne("getMartSatup", "martSetup", "001");
    if (_martDb[0]) {
      martSetupData = martSetupModelFromJson(_martDb[1]);
    }

    var _gasDb = await dbGetDataOne("getGasSatup", "gasSetup", "001");
    if (_martDb[0]) {
      gasSetupData = gasSetupModelFromJson(_gasDb[1]);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  static int refreshNum = 10; // number that changes when refreshed
  Stream<int> counterStream =
      Stream<int>.periodic(Duration(seconds: 3), (x) => refreshNum);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _handleRefresh() {
    final Completer<void> completer = Completer<void>();
    Timer(const Duration(seconds: 3), () {
      completer.complete();
    });
    setState(() {
      refreshNum = new Random().nextInt(100);
    });
    return completer.future.then<void>((_) {
      getAllShopStatus = false;
      _getAllShop(context.read<AppDataModel>());
    });
  }

  _raelTimeDB() {
    db.collection("martSetup").snapshots().listen((event) async {
      _getSetup();
    });
    db.collection("gasSetup").snapshots().listen((event) async {
      _getSetup();
    });
    db.collection("adsApp").snapshots().listen((event) async {
      _getAdsApp();
    });
  }

  void initState() {
    super.initState();
    _setLocation(context.read<AppDataModel>());
    _getAdsApp();
    _getAllShop(context.read<AppDataModel>());
    _getSetup();
    _raelTimeDB();
  }

  Future SelectNotification(String payload) {
    debugPrint("payload : $payload");
  }

  showNotification(String title, String body, String goPage) async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.high, importance: Importance.max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(0, title, body, platform,
        payload: 'Nitish Kumar Singh is part time Youtuber');
  }

  @override
  Widget build(BuildContext context) {
    // if (getAllShopStatus == false) _getAllShop(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
      builder: (context, appDataModel, child) => Scaffold(
        key: _scaffoldKey,
        // appBar: AppBar(
        //   iconTheme: IconThemeData(color: Style().darkColor),
        //   backgroundColor: Colors.white,
        //   bottomOpacity: 0.0,
        //   elevation: 0.0,
        //
        //   title: Style().textDarkAppbar('เฮาะ อากาศเดลิเวอรี่'),
        //   actions: [
        //     (orderActiveCount == 0)
        //         ? Container()
        //         : Badge(
        //             position: BadgePosition.topEnd(top: 0, end: 3),
        //             animationDuration: Duration(milliseconds: 300),
        //             animationType: BadgeAnimationType.slide,
        //             badgeContent: Text(
        //               orderActiveCount.toString(),
        //               style: TextStyle(color: Colors.white, fontSize: 10),
        //             ),
        //             child: IconButton(
        //                 icon: Icon(
        //                   FontAwesomeIcons.receipt,
        //                   color: Style().darkColor,
        //                 ),
        //                 onPressed: () {
        //                   setState(() {
        //                     Navigator.pushNamed(context, "/orderList-page");
        //                   });
        //                 }),
        //           ),
        //     IconButton(
        //         icon: Icon(
        //           Icons.refresh,
        //           color: Style().darkColor,
        //         ),
        //         onPressed: () {
        //           setState(() {
        //             DefaultCacheManager().emptyCache();
        //             imageCache.clear();
        //             imageCache.clearLiveImages();
        //             _handleRefresh();
        //           });
        //         }),
        //   ],
        // ),
        body: Container(
          color: Colors.grey.shade100,
          child:
              // (appDataModel.locationStatus == false)
              //     ? Center(
              //         child: Column(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             Container(
              //               margin: EdgeInsets.only(bottom: 10),
              //               child: Icon(
              //                 Icons.location_disabled,
              //                 size: 40,
              //                 color: Colors.red,
              //               ),
              //             ),
              //             Style().textSizeColor(
              //                 "เข้าถึงตำแหน่งของคุณไม่ได้ โปรดตรวจสอบการตั้งค่า",
              //                 14,
              //                 Style().darkColor),
              //             Container(
              //               margin: EdgeInsets.only(top: 10),
              //               child: ElevatedButton(
              //                   style: ElevatedButton.styleFrom(
              //                     primary: Style().darkColor,
              //                   ),
              //                   onPressed: () async {
              //                     await Geolocator.openLocationSettings();
              //                     exit(0);
              //                   },
              //                   child: Style()
              //                       .textSizeColor("ตั้งค่า", 14, Colors.white)),
              //             )
              //           ],
              //         ),
              //       )
              //     :
              (ranShopModel == null || ranProductModel == null)
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Style().loading(),
                        ],
                      ),
                    )
                  : Center(
                      child: LiquidPullToRefresh(
                        // key if you want to add
                        color: Colors.white,
                        backgroundColor: Style().darkColor,
                        springAnimationDurationInMilliseconds: 3,
                        showChildOpacityTransition: false,
                        onRefresh: _handleRefresh,
                        height: 50,
                        child: ListView(
                          children: [
                            Column(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                (appDataModel.loginStatus == false)
                                    ? Container()
                                    : _builbLocationSet(
                                        context.read<AppDataModel>()),
                                (adsAppListData == null)
                                    ? Container()
                                    : _adsBar(),
                                _allService(context.read<AppDataModel>()),
                                // Container(
                                //   padding:
                                //       EdgeInsets.only(left: 10, right: 10, top: 10),
                                //   child: buildMainMenu(),
                                // ),
                                // buildMainMenu(),
                                showShop((context.read<AppDataModel>())),
                                showProduct((context.read<AppDataModel>())),
                                // showProductLoadMore(
                                //     (context.read<AppDataModel>())),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
        floatingActionButton: (appDataModel.currentOrder == null ||
                appDataModel.currentOrder.length > 0)
            ? Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                        onTap: () async {
                          var _conFirm = await Dialogs().confirm(
                              context,
                              "ล้างตะกร้า",
                              "สิ้นค้าทั้งหมดจะถูกลบออกจากตะกร้า");
                          if (_conFirm != null && _conFirm) {
                            appDataModel.currentOrder = [];
                            setState(() {});
                          }
                        },
                        child: Icon(Icons.close)),
                    FloatingActionButton.extended(
                      backgroundColor: Style().darkColor,
                      onPressed: () async {
                        appDataModel.storeSelectId =
                            appDataModel.currentOrder[0].shopId;
                        for (CartModel orderItem in appDataModel.currentOrder) {
                          print('delete = ' + jsonEncode(orderItem));
                        }

                        await Navigator.pushNamed(context, "/orderDetail-page");
                        setState(() {});
                      },
                      icon: Icon(Icons.shopping_cart),
                      label: Style().textSizeColor(
                          appDataModel.currentOrder.length.toString(),
                          16,
                          Colors.white),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  _adsBar() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: ImageSlideshow(
        width: double.infinity,
        height: 150,
        initialPage: 0,
        indicatorColor: Colors.transparent,
        indicatorBackgroundColor: Colors.transparent,
        onPageChanged: (value) {
          // debugPrint('Page changed: $value');
        },
        autoPlayInterval: 5000,
        isLoop: true,
        children: adsAppListData.map((e) {
          // print(e.url);
          return Container(
            margin: EdgeInsets.all(5),
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: CachedNetworkImage(
                key: UniqueKey(),
                imageUrl: e.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.black12,
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.black12,
                  child: (Icon(
                    Icons.error,
                    color: Colors.red,
                  )),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  _allService(AppDataModel appDataModel) {
    double blogSize = 0.2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: EdgeInsets.only(top: 10, left: 5),
            child: Row(
              children: [
                Style().textSizeColor('บริการของเรา', 16, Colors.black),
              ],
            )),
        Container(
            margin: EdgeInsets.only(
              top: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    _serviceSelect(context.read<AppDataModel>(), "1");
                  },
                  child: Container(
                    width: screenW * blogSize,
                    child: Column(
                      children: [
                        CircleAvatar(
                            backgroundColor: Style().darkColor,
                            radius: 20,
                            child: Icon(
                              Icons.store,
                              color: Colors.white,
                            )),
                        Container(
                            margin: EdgeInsets.all(8.0),
                            width: screenW * blogSize,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Style().textFlexibleBackSizeNonRow(
                                    "ซื้อสินค้า", 2, 10),
                              ],
                            ))
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _serviceSelect(context.read<AppDataModel>(), "2");
                  },
                  child: Container(
                    width: screenW * blogSize,
                    child: Column(
                      children: [
                        CircleAvatar(
                            backgroundColor: (martSetupData == null ||
                                    martSetupData.status == "0")
                                ? Colors.grey
                                : Style().darkColor,
                            radius: 20,
                            child: Icon(
                              Icons.shopping_bag,
                              size: 20,
                              color: Colors.white,
                            )),
                        Container(
                            margin: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Style().textFlexibleBackSizeNonRow(
                                    "ฝากซื้อของ", 2, 10),
                              ],
                            ))
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _serviceSelect(context.read<AppDataModel>(), "3");
                  },
                  child: Container(
                    width: screenW * blogSize,
                    child: Column(
                      children: [
                        CircleAvatar(
                            backgroundColor: (gasSetupData != null &&
                                    gasSetupData.status == "1")
                                ? Style().darkColor
                                : Colors.grey,
                            radius: 20,
                            child: Icon(
                              FontAwesomeIcons.burn,
                              size: 20,
                              color: Colors.white,
                            )),
                        Container(
                            margin: EdgeInsets.all(8.0),
                            width: screenW * 0.15,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Style().textFlexibleBackSizeNonRow(
                                    "เติมแก๊ส", 2, 10),
                              ],
                            ))
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _serviceSelect(context.read<AppDataModel>(), "4");
                  },
                  child: Container(
                    width: screenW * blogSize,
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 20,
                          child: Icon(Icons.home_repair_service,
                              color: Colors.white),
                        ),
                        Container(
                            margin: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Style().textFlexibleBackSizeNonRow(
                                    "เรียกช่าง", 2, 10),
                              ],
                            ))
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }

  buildMainMenu() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              // Navigator.pushNamed(context, "/loadMore-page");
            },
            child: Container(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Image.asset("assets/images/foodIcon.png"),
                  ),
                  Style().textBlackSize("อาหาร/เครื่องดื่ม", 12)
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Dialogs().information(
                  context,
                  Style().textBlackSize('ยังไม่ให้บริการ', 16),
                  Style()
                      .textBlackSize('เรียกช่าง จะเปิดให้บริการเร็วๆนี้', 14));
            },
            child: Container(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Image.asset("assets/images/serviceIcon.png"),
                  ),
                  Style().textBlackSize("เรียกช่าง", 12)
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Dialogs().information(
                  context,
                  Style().textBlackSize('ยังไม่ให้บริการ', 16),
                  Style()
                      .textBlackSize('รถรับจ้าง จะเปิดให้บริการเร็วๆนี้', 14));
            },
            child: Container(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Image.asset("assets/images/taxiIcon.png"),
                  ),
                  Style().textBlackSize("รถรับจ้าง", 12)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  showProduct(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Style().textBlackSize('สินค้าสำหรับคุญ', 16),
                InkWell(
                  onTap: () async {
                    if (appDataModel.loginStatus == true) {
                      appDataModel.allProductCurrentPage = 1;
                      await Navigator.pushNamed(context, "/allProduct-page");
                      if (appDataModel.currentOrder != null &&
                          appDataModel.currentOrder.length > 0) setState(() {});
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Row(
                    children: [
                      Style().textSizeColor(
                          'เลือกซื้อสินค้าต่อ', 14, Colors.blueAccent),
                      Icon(
                        Icons.navigate_next_sharp,
                        color: Colors.blueAccent,
                        size: 20,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          (ranProductModel == null)
              ? Container(
                  height: 150,
                  child: Style().circularProgressIndicator(Style().darkColor))
              : StaggeredGridView.countBuilder(
                  shrinkWrap: true,
                  primary: false,
                  crossAxisCount: 2,
                  staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: ranProductModel.length,
                  itemBuilder: (BuildContext context, int index) {
                    // int costDeliveryStr;
                    ShopModel shopModel;
                    for (var shop in appDataModel.allFullShopData) {
                      if (shop.shopUid == ranProductModel[index].shopUid) {
                        shopModel = shopModelFromJson(jsonEncode(shop));
                        // costDeliveryStr = _calCostDelivery(
                        //     shopModel.shopLocation,
                        //     nowLocation,
                        //     int.parse(
                        //         appDataModel.locationSetupModel.distanceStart),
                        //     int.parse(appDataModel
                        //         .locationSetupModel.costDeliveryMin),
                        //     int.parse(appDataModel
                        //         .locationSetupModel.costDeliveryPerKm));
                      }
                    }
                    return InkWell(
                      onTap: () async {
                        if (appDataModel.loginStatus == true) {
                          appDataModel.productSelectId =
                              ranProductModel[index].productId;
                          await Navigator.pushNamed(
                              context, "/showProduct-page");
                          if (appDataModel.currentOrder != null &&
                              appDataModel.currentOrder.length > 0)
                            setState(() {});
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                    margin: EdgeInsets.all(8),
                                    height: 180,
                                    width: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: CachedNetworkImage(
                                        key: UniqueKey(),
                                        imageUrl: ranProductModel[index]
                                            .productPhotoUrl,
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
                                // Container(height: 50,
                                //   width: 50,child:  paddingShopOpen(e.shopTime, e.shopStatus),)
                              ],
                            ),
                            Container(
                              width: 170,
                              margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                              child: Column(
                                children: [
                                  (shopModel == null ||
                                          shopModel.shopName == null)
                                      ? Style().textFlexibleBackSize(
                                          ranProductModel[index].productName,
                                          2,
                                          14)
                                      : Style().textFlexibleBackSize(
                                          ranProductModel[index].productName +
                                              " - " +
                                              shopModel.shopName,
                                          2,
                                          14)
                                ],
                              ),
                            ),
                            Container(
                              width: 170,
                              margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                              child: Column(
                                children: [
                                  Style().textFlexibleBackSize(
                                      ranProductModel[index].productDetail,
                                      2,
                                      12)
                                ],
                              ),
                            ),
                            Container(
                              width: 170,
                              margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Style().textSizeColor(
                                      ranProductModel[index].productPrice +
                                          " ฿",
                                      16,
                                      Style().darkColor),
                                  // Row(
                                  //   children: [
                                  //     Icon(
                                  //       Icons.motorcycle,
                                  //       size: 20,
                                  //     ),
                                  //     Style().textSizeColor(
                                  //         " " +
                                  //             appDataModel.moneyFormat
                                  //                 .format(costDeliveryStr) +
                                  //             ' ฿',
                                  //         14,
                                  //         Style().shopPrimaryColor),
                                  //   ],
                                  // )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  })
        ],
      ),
    );
  }

  showShop(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Style().textBlackSize('ร้านค้าแนะนำ', 16),
                InkWell(
                  onTap: () async {
                    if (appDataModel.loginStatus == true) {
                      appDataModel.allProductCurrentPage = 2;
                      await Navigator.pushNamed(context, "/allProduct-page");
                      if (appDataModel.currentOrder != null &&
                          appDataModel.currentOrder.length > 0) setState(() {});
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Row(
                    children: [
                      Style().textSizeColor(
                          'ร้านค้าทั้งหมด', 14, Colors.blueAccent),
                      Icon(
                        Icons.navigate_next_sharp,
                        color: Colors.blueAccent,
                        size: 20,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          (ranShopModel == null)
              ? Container(
                  height: 150,
                  child: Style().circularProgressIndicator(Style().darkColor))
              : StaggeredGridView.countBuilder(
                  shrinkWrap: true,
                  primary: false,
                  crossAxisCount: 5,
                  staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  itemCount: ranShopModel.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () async {
                        if (appDataModel.loginStatus == true) {
                          print("goto StorePage");
                          appDataModel.storeSelectId =
                              ranShopModel[index].shopUid;
                          // appDataModel.currentOrder = [];

                          await Navigator.pushNamed(context, '/store-Page');
                          await _reRandomData(context.read<AppDataModel>());
                          if (appDataModel.currentOrder != null &&
                              appDataModel.currentOrder.length > 0)
                            setState(() {});
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.shade100,
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: CachedNetworkImage(
                                        key: UniqueKey(),
                                        imageUrl:
                                            ranShopModel[index].shopPhotoUrl,
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
                                    )),

                                // ClipRRect(
                                //   borderRadius: BorderRadius.circular(5.0),
                                //   child: FadeInImage.assetNetwork(
                                //     fit: BoxFit.fitHeight,
                                //     placeholder:
                                //         'assets/images/loading.gif',
                                //     image: ranShopModel[index].shopPhotoUrl,
                                //   ),
                                // )),
                                Container(
                                  height: 50,
                                  width: 50,
                                  child: paddingShopOpen(
                                      ranShopModel[index].shopTime,
                                      ranShopModel[index].shopStatus),
                                )
                              ],
                            ),
                            Container(
                              width: 60,
                              margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                              child: Column(
                                children: [
                                  Style().textFlexibleBackSize(
                                      ranShopModel[index].shopName, 2, 10)
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  })
        ],
      ),
    );
  }

  _builbLocationSet(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Style().textBlackSize("ตำแหน่ง", 12),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Style().darkColor,
                size: 14,
              ),
              (addressString == null)
                  ? Style().textBlackSize("ระบุตำแหน่ง ", 12)
                  : Container(
                      width: screenW * 0.7,
                      child: Style().textBlackSize(addressString, 12)),
              InkWell(
                onTap: () async {
                  appDataModel.userLat = userlat;
                  appDataModel.userLng = userlng;

                  var result =
                      await Navigator.pushNamed(context, "/googleMap-page");
                  if (result != null) {
                    List latlngNew = result;
                    userlat = latlngNew[0];
                    userlng = latlngNew[1];

                    appDataModel.userLat = userlat;
                    appDataModel.userLng = userlng;

                    addressString = await getAddressName(userlat, userlng);
                    getAllShopStatus = true;
                    setState(() {});
                  }
                },
                child: Icon(
                  Icons.keyboard_arrow_down_sharp,
                  color: Style().darkColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  paddingShopOpen(String shopTime, String shopStatus) {
    bool shopOpen = false;

    if (shopStatus == "1") {
      var now = DateTime.now();
      int dayNum = now.weekday;
      List<String> statusTimeAll = shopTime.split(",");
      for (int i = 0; i < statusTimeAll.length - 1; i++) {
        if (dayNum == i + 1) {
          List<String> statusTime = statusTimeAll[i].split("/");
          if (statusTime[0] == "close") {
            shopOpen = false;
          } else {
            List<String> openClose = statusTime[1].split('-');
            List<String> openHM = openClose[0].split(':');
            List<String> closeHM = openClose[1].split(':');
            final startTime = DateTime(now.year, now.month, now.day,
                int.parse(openHM[0]), int.parse(openHM[1]));
            final endTime = DateTime(now.year, now.month, now.day,
                int.parse(closeHM[0]), int.parse(closeHM[1]));
            // final startTime = DateTime(now.year, now.month, now.day, 01, 0);
            // final endTime = DateTime(now.year, now.month, now.day, 23,0);
            final currentTime = DateTime.now();
            (currentTime.isAfter(startTime) && currentTime.isBefore(endTime))
                ? shopOpen = true
                : shopOpen = false;
          }
        }
      }
    } else {
      shopOpen = false;
    }

    print("shopOpen = " + shopOpen.toString());
    return Container(
      width: 10,
      child: Padding(
        padding: const EdgeInsets.only(top: 1),
        child: (shopOpen == true)
            ? Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Style().darkColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Style().textSizeColor('เปิด', 10, Colors.white),
                ),
              )
            : Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Style().textSizeColor('ปิด', 10, Colors.white),
                ),
              ),
      ),
    );
  }

  // _calCostDelivery(String shopLocation, userLocation, int distanceMin,
  //     costStart, costPerKm) {
  //   List<String> locationLatLng = shopLocation.split(",");
  //   double lat1 = double.parse(locationLatLng[0]);
  //   double lng1 = double.parse(locationLatLng[1]);

  //   List<String> userLocationLatLng = nowLocation.split(",");
  //   double lat2 = double.parse(userLocationLatLng[0]);
  //   double lng2 = double.parse(userLocationLatLng[1]);

  //   double distance = 0;
  //   int costDelivery = costStart;

  //   distance = calculateDistance(lat1, lng1, lat2, lng2);

  //   print("distance = " + distance.toString());

  //   int distanceFinal = distance.ceil();
  //   int distanceLeft;
  //   if (distance > distanceMin) {
  //     distanceLeft = distanceFinal - distanceMin;
  //     costDelivery += (costPerKm * distanceLeft);
  //   }

  //   return costDelivery;
  // }

  _serviceSelect(AppDataModel appDataModel, String serviceType) async {
    if (appDataModel.loginStatus == false) {
      Navigator.pop(context);
    } else {
      if (serviceType == "1") {
        appDataModel.allProductCurrentPage = 1;
        await Navigator.pushNamed(context, "/allProduct-page");
        if (appDataModel.currentOrder != null &&
            appDataModel.currentOrder.length > 0) setState(() {});
      } else if (serviceType == "2") {
        if (martSetupData != null && martSetupData.status == "1") {
          if (appDataModel.currentOrder != null &&
              appDataModel.currentOrder.length > 0) {
            var _result = await showOkAlertDialog(
                title: "สินค้าในตะกร้าจะถูกล้าง", message: "");
            print(_result);

            // var _confirm = await Dialogs()
            //     .confirm(context, "มีสินค้าในตะกร้า", "สินค้าในตะกล้าจะถูกลบ");
            // if (_confirm != null && _confirm) {
            //   appDataModel.currentOrder = [];
            //   await Navigator.pushNamed(context, "/martService-page");
            //   setState(() {});
            // }
          }
        } else {
          Dialogs().information(
              context,
              Style().textBlackSize("ยังไม่เปิดให้บริการ", 16),
              Style().textBlackSize(
                  "บริการฝากซื้อของ จะเปิดให้บริการเร็วๆนี้", 14));
        }
      } else if (serviceType == "3") {
        if (gasSetupData != null && gasSetupData.status == "1") {
          if (appDataModel.currentOrder != null &&
              appDataModel.currentOrder.length > 0) {
            var _confirm = await Dialogs()
                .confirm(context, "มีสินค้าในตะกร้า", "สินค้าในตะกล้าจะถูกลบ");
            if (_confirm != null && _confirm) {
              appDataModel.currentOrder = [];
              await Navigator.pushNamed(context, "/gasService-page");
              setState(() {});
            }
          }
        } else {
          Dialogs().information(
              context,
              Style().textBlackSize("ยังไม่เปิดให้บริการ", 16),
              Style()
                  .textBlackSize("บริการเติมแกส จะเปิดให้บริการเร็วๆนี้", 14));
        }
      } else if (serviceType == "4") {
        Dialogs().information(
            context,
            Style().textBlackSize("ยังไม่เปิดให้บริการ", 16),
            Style()
                .textBlackSize("บริการเรียกช่างจะเปิดให้บริการเร็วๆนี้", 14));
      }
    }
  }
}
