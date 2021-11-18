import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hro/page/ServiceSetup.dart';
import 'package:hro/page/addCode.dart';
import 'package:hro/page/addCreditPage.dart';
import 'package:hro/page/addMenu.dart';
import 'package:hro/page/addRiderPage.dart';
import 'package:hro/page/addShopPage.dart';
import 'package:hro/page/adminAdAdd.dart';
import 'package:hro/page/adminBanlAccount.dart';
import 'package:hro/page/adminCodePage.dart';
import 'package:hro/page/adminContactData.dart';
import 'package:hro/page/adminHomePage.dart';
import 'package:hro/page/adminManageAd.dart';
import 'package:hro/page/adminOrder.dart';
import 'package:hro/page/adminSenNotify.dart';
import 'package:hro/page/adminSystem.dart';
import 'package:hro/page/allProductPage.dart';
import 'package:hro/page/chatPage.dart';
import 'package:hro/page/creditTransection.dart';
import 'package:hro/page/editMenu.dart';
import 'package:hro/page/editRiderPage.dart';
import 'package:hro/page/editShopPage.dart';
import 'package:hro/page/frist.dart';
import 'package:hro/page/gasService.dart';
import 'package:hro/page/googleMapPage.dart';
import 'package:hro/page/googleMapPlaces.dart';
import 'package:hro/page/googleMapShoeDistancsPage.dart';
import 'package:hro/page/homePage.dart';
import 'package:hro/page/martServiceAddDetail.dart';
import 'package:hro/page/martServicePage.dart';
import 'package:hro/page/menu.dart';
import 'package:hro/page/order2rider.dart';
import 'package:hro/page/orderDetailPage.dart';
import 'package:hro/page/orderTrack.dart';
import 'package:hro/page/profile.dart';
import 'package:hro/page/qrCodeRider2User.dart';
import 'package:hro/page/rating4customer.dart';
import 'package:hro/page/register.dart';
import 'package:hro/page/riderHistoryPage.dart';
import 'package:hro/page/riderPage.dart';
import 'package:hro/page/riderReview.dart';
import 'package:hro/page/shop.dart';
import 'package:hro/page/shopHistoryPage.dart';
import 'package:hro/page/shopReview.dart';
import 'package:hro/page/showFristPage.dart';
import 'package:hro/page/showHomePage.dart';
import 'package:hro/page/showOrderGas.dart';
import 'package:hro/page/showOrderMart.dart';
import 'package:hro/page/showProduct.dart';
import 'package:hro/page/splash.dart';
import 'package:hro/page/storePage.dart';
import 'package:hro/page/transactionTicket.dart';
import 'package:provider/provider.dart';
import 'model/AppDataModel.dart';
import 'package:firebase_core/firebase_core.dart';

String initialRoute = '/splash-page';
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
  showNotification("testbackG", "BG Body", "test");
}

showNotification(String title, String body, String goPage) async {
  var android = new AndroidNotificationDetails(
      'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
      priority: Priority.high, importance: Importance.max);
  var iOS = new IOSNotificationDetails();
  var platform = new NotificationDetails(android: android, iOS: iOS);
  var flutterLocalNotificationsPlugin;
  await flutterLocalNotificationsPlugin.show(0, title, body, platform,
      payload: 'mag PlayLoad');
}

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp().then((value) async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/launcher_icon');
    var iOS = new IOSInitializationSettings();
    var initSetttings = InitializationSettings(iOS: iOS, android: android);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: SelectNotification);
    runApp(MyApp());
  });
}

Future SelectNotification(String payload) {
  print("payload = " + payload);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // setProfile(context.read<AppDataModel>());
    return Provider(
      create: (_) => AppDataModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'เฮาะ เดลิเวอรี่',
        routes: {
          '/splash-page': (context) => SplashPage(),
          '/home-page': (context) => HomePage(),
          '/first-page': (context) => FirstPage(),
          '/showHome-page': (context) => ShowHomePage(),
          '/profile-page': (context) => ProfilePage(),
          '/addShop-Page': (context) => AddShopPage(),
          '/shop-Page': (context) => ShopPage(),
          '/menu-Page': (context) => MenuPage(),
          '/addMenu-Page': (context) => AddMenuPage(),
          '/editMenu-Page': (context) => EditMenuPage(),
          '/editShop-Page': (context) => EditShopPage(),
          '/rider-Page': (context) => RiderPage(),
          '/addRider-Page': (context) => AddRiderPage(),
          '/editRider-Page': (context) => EditRiderPage(),
          '/riderHistory-Page': (context) => RiderHistoryPagr(),
          '/store-Page': (context) => StorePage(),
          "/allProduct-page": (context) => AllProductsPage(),
          "/showProduct-page": (context) => ShowProductPage(),
          "/orderDetail-page": (context) => OrderDetailPage(),
          "/order2Rider-page": (context) => Order2RiderPage(),
          "/qrCodeRider2User-page": (context) => QrCodeRider2UserPage(),
          "/orderTrack-page": (context) => OrderTrackPage(),
          "/shopReview-page": (context) => ShopReviewPage(),
          "/riderReview-page": (context) => RiderReviewPage(),
          "/Rating4Customer-page": (context) => Rating4CustomerPage(),
          "/shopHistory-page": (context) => ShopHistoryPage(),
          "/adminHome-page": (context) => AdminHomePage(),
          "/adminSystem-page": (context) => AdminSystemPage(),
          "/adminOrder-page": (context) => AdminOrderPage(),
          "/register-page": (context) => RegisterPage(),
          "/showFrist-page": (context) => ShowFristPage(),
          "/googleMap-page": (context) => GoogleMapPage(),
          "/adminAdmanage-page": (context) => AdminAdManagePage(),
          '/googleMapShowDistancs-page': (context) =>
              GoogleMapShowDistancsPage(),
          "/chat-page": (context) => ChatPage(),
          "/martService-page": (context) => MartServicePage(),
          "/martServiceAddDetail-page": (context) => MartServiceAddDetailPage(),
          "/showOrderMart-page": (context) => ShowOrderMartPage(),
          "/creditTransection-page": (context) => CreditTransactionPage(),
          "/gasService-page": (context) => GasServicePage(),
          "/showOrderGas-page": (context) => ShowOrderGasPage(),
          "/adminDoce-page": (context) => AdminCodePage(),
          "/addCode-page": (context) => addCodePage(),
          "/adminAdManage-page": (context) => AdminAdManagePage(),
          "/adminAdAdd-page": (context) => AddminAddAdPage(),
          "/serviceSetting-page": (context) => ServiceSettingPage(),
          "/adminContactData-page": (context) => AdminContactDataPage(),
          "/adminBankAccount-page": (context) => AdminBankAccountPage(),
          "/addCreditPage-page": (context) => AddCreditPage(),
          "/transectionTicket-page": (context) => TransactionTicketPage(),
          "/adminSendNotify-page": (context) => AdminSendNotifyPage(),
          "/RoutesWidget-page": (context) => RoutesWidget(),
        },
        initialRoute: initialRoute,
      ),
    );
  }
}
