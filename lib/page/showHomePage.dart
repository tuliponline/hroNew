import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/UserOneModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/page/riderPage.dart';
import 'package:hro/page/shop.dart';
import 'package:hro/page/userPage.dart';
import 'package:hro/utility/checkHaveShopAndRider.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';
import 'homePage.dart';

class ShowHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ShowHomeState();
  }
}

class ShowHomeState extends State<ShowHomePage> {
  String goPage = "";
  String title = '';
  String body = "";

  int _selectedPageIndex = 0;
  List<Widget> _children = [];
  bool haveShop = false;
  bool haveRider = false;
  Widget menuSelect = Container();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  FirebaseFirestore db = FirebaseFirestore.instance;

  UserOneModel userOneModel;

  int riderNoti = 0;
  bool shopNoti = false;
  bool orderNoti = false;

  _setUserOneModel(AppDataModel appDataModel) {
    userOneModel = appDataModel.userOneModel;
    appDataModel.profileUid = appDataModel.userOneModel.uid;
  }

  checkNoti(AppDataModel appDataModel) async {
    print("uid = " + userOneModel.uid);

    riderNoti = 0;
    shopNoti = false;
    orderNoti = false;
    print("check noti");
    await db.collection("orders").get().then((value) {
      if (value.docs.length > 0) {
        List<OrderList> _orderList;
        var jsonData = setList2Json(value);
        _orderList = orderListFromJson(jsonData);
        _orderList.forEach((e) {
          if (e.status == "1") {
            riderNoti = 1;
            if (e.customerId == appDataModel.userOneModel.uid) {
              orderNoti = true;
            }
          } else {
            if (e.driver == userOneModel.uid) {
              if (e.status == "2" || e.status == "3" || e.status == "4") {
                if (e.customerId == appDataModel.userOneModel.uid) {
                  orderNoti = true;
                }

                riderNoti = 2;
              }
            }
            if (e.status == "2" || e.status == "3" || e.status == "4") {
              if (e.customerId == appDataModel.userOneModel.uid) {
                orderNoti = true;
              }
            }
            if ((e.status == "2" || e.status == "3") &&
                e.shopId == appDataModel.userOneModel.uid) {
              shopNoti = true;
            }
          }
        });
      } else {
        riderNoti = 0;
      }
    }).catchError((onError) {
      riderNoti = 0;
    });

    _checkHaveShop();
    setState(() {
      print("riderNoti = " + riderNoti.toString());
      print("notiSetState");
    });
  }

  _checkHaveShop() async {
    haveShop = await checkHaveShop(userOneModel.uid);
    haveRider = await checkHaveRider(userOneModel.uid);

    print("haveShop $haveShop");
    print("haveRider $haveRider");

    if (haveShop == false && haveRider == false) {
      _children = [HomePage(), HomePage(), UserPage()];
      menuSelect = menu1();
    }
    if (haveShop == true && haveRider == true) {
      _children = [HomePage(), HomePage(), ShopPage(), RiderPage(), UserPage()];
      menuSelect = menu2();
    }
    if (haveShop == true && haveRider == false) {
      _children = [HomePage(), HomePage(), ShopPage(), UserPage()];
      menuSelect = menu3();
    }
    if (haveShop == false && haveRider == true) {
      _children = [HomePage(), HomePage(), RiderPage(), UserPage()];
      menuSelect = menu4();
    }
    setState(() {});
  }

  _realTimeDB(AppDataModel appDataModel) async {
    db.collection("orders").snapshots().listen((event) async {
      checkNoti(context.read<AppDataModel>());
    });
  }

  @override
  void initState() {
    super.initState();
    _realTimeDB(context.read<AppDataModel>());
    _setUserOneModel(context.read<AppDataModel>());
    _checkHaveShop();
    checkNoti(context.read<AppDataModel>());
    _Notififation();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/launcher_icon');
    var iOS = new IOSInitializationSettings();
    var initSetttings = InitializationSettings(iOS: iOS, android: android);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: SelectNotification);
  }

  Future SelectNotification(String payload) {
    debugPrint("payload : $payload");
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: Style().textBlackSize(title, 14),
        content: Style().textFlexibleBackSize(body, 5, 14),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Style().textSizeColor('ออก', 14, Colors.black)),
          (goPage?.isEmpty ?? true)
              ? (Container())
              : TextButton(
                  onPressed: () async {
                    if (goPage == "/driver-page" || goPage == "/shop-page") {
                      print(goPage);
                      Navigator.pop(context);
                      await Navigator.pushNamed(context, goPage);
                    }
                  },
                  child:
                      Style().textSizeColor('ดูOrder', 14, Colors.blueAccent))
        ],
      ),
    );
  }

  _Notififation() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      checkNoti(context.read<AppDataModel>());
      print('notify foreground! ShowHomePage');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        print(message.notification.title);

        title = message.notification.title;
        body = message.notification.body;

        goPage = "";
        if (message.notification.title.contains("Rider")) {
          goPage = "/driver-page";
        } else if (message.notification.title.contains("Shop")) {
          goPage = '/shop-page';
        }

        showNotification(title, body, goPage);
      }
    });
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
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
            body: DoubleBackToCloseApp(
              child: _children.length > 0
                  ? _children[_selectedPageIndex]
                  : Container(),
              snackBar: const SnackBar(
                content: Text(
                  'กดอีกครั้งเพื่อออก',
                  style: TextStyle(
                      fontSize: 14, fontFamily: 'Prompt', color: Colors.white),
                ),
              ),
            ),
            bottomNavigationBar: _children.length > 0 ? menuSelect : null));
  }

  BottomNavigationBar menu1() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'หน้าแรก',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_basket),
          label: 'ตะกร้า',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'คุณ',
          backgroundColor: Colors.white,
        ),
      ],
      selectedLabelStyle: TextStyle(fontSize: 10, fontFamily: 'Prompt'),
      unselectedLabelStyle: TextStyle(fontSize: 10, fontFamily: 'Prompt'),
      currentIndex: _selectedPageIndex,
      selectedItemColor: Style().darkColor,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
    );
  }

  BottomNavigationBar menu2() {
    print("riderOnBT = " + riderNoti.toString());
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'หน้าแรก',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: (orderNoti == false)
              ? Icon(Icons.shopping_bag_sharp)
              : Badge(
                  badgeColor: Colors.red,
                  position: BadgePosition.topEnd(top: -5, end: -5),
                  shape: BadgeShape.circle,
                  borderRadius: BorderRadius.circular(100),
                  child: Icon(Icons.shopping_bag_sharp),
                  badgeContent: null),
          label: 'ตะกร้า',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: (shopNoti == false)
              ? Icon(Icons.store)
              : Badge(
                  badgeColor: Colors.red,
                  position: BadgePosition.topEnd(top: -5, end: -5),
                  shape: BadgeShape.circle,
                  borderRadius: BorderRadius.circular(100),
                  child: Icon(Icons.store),
                  badgeContent: null),
          label: 'ร้านค้า',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: (riderNoti == 0)
              ? Icon(Icons.motorcycle)
              : (riderNoti == 1)
                  ? Badge(
                      badgeColor: Colors.red,
                      position: BadgePosition.topEnd(top: -5, end: -5),
                      shape: BadgeShape.circle,
                      borderRadius: BorderRadius.circular(100),
                      child: Icon(Icons.motorcycle),
                      badgeContent: null)
                  : Badge(
                      badgeColor: Colors.yellow,
                      position: BadgePosition.topEnd(top: -5, end: -5),
                      shape: BadgeShape.circle,
                      borderRadius: BorderRadius.circular(100),
                      child: Icon(Icons.motorcycle),
                      badgeContent: null),
          label: 'Rider',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'คุณ',
          backgroundColor: Colors.white,
        ),
      ],
      selectedLabelStyle: TextStyle(fontSize: 10, fontFamily: 'Prompt'),
      unselectedLabelStyle: TextStyle(fontSize: 10, fontFamily: 'Prompt'),
      currentIndex: _selectedPageIndex,
      selectedItemColor: Style().darkColor,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
    );
  }

  BottomNavigationBar menu3() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'หน้าแรก',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_basket),
          label: 'ตะกร้า',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'ร้านค้า',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'คุณ',
          backgroundColor: Colors.white,
        ),
      ],
      selectedLabelStyle: TextStyle(fontSize: 10, fontFamily: 'Prompt'),
      unselectedLabelStyle: TextStyle(fontSize: 10, fontFamily: 'Prompt'),
      currentIndex: _selectedPageIndex,
      selectedItemColor: Style().darkColor,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
    );
  }

  BottomNavigationBar menu4() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'หน้าแรก',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_basket),
          label: 'ตะกร้า',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Badge(
            shape: BadgeShape.circle,
            borderRadius: BorderRadius.circular(100),
            child: Icon(Icons.settings),
            badgeContent: Container(
              height: 5,
              width: 5,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            ),
          ),
          label: 'Rider',
          backgroundColor: Colors.white,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'คุณ',
          backgroundColor: Colors.white,
        ),
      ],
      selectedLabelStyle: TextStyle(fontSize: 10, fontFamily: 'Prompt'),
      unselectedLabelStyle: TextStyle(fontSize: 10, fontFamily: 'Prompt'),
      currentIndex: _selectedPageIndex,
      selectedItemColor: Style().darkColor,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
    );
  }

  void _onItemTapped(int index) {
    print(index);
    setState(() {
      _selectedPageIndex = index;
    });
  }
}