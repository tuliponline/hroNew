import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/UserOneModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/utility/Dialogs.dart';

import 'package:hro/utility/getAddressName.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Order2RiderPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Order2RiderState();
  }
}

class Order2RiderState extends State<Order2RiderPage> {
  Dialogs dialogs = Dialogs();
  bool loadData = false;
  OrderDetail orderDetail;
  List<OrderProduct> orderProduct;
  FirebaseFirestore db = FirebaseFirestore.instance;
  String orderIdSelect;
  String shopAddressName, customerAddress;

  double shopLat, shopLng, customerLat, customerLng;

  bool showAddress = false;
  String shopName, customerName, shopPhone, customerPhone;
  int amount = 0;

  DriversModel riderDetail;

  _getData(AppDataModel appDataModel) async {
    orderIdSelect = appDataModel.orderIdSelected;
    db.collection('orders').doc(orderIdSelect).get().then((value) async {
      orderDetail = orderDetailFromJson(jsonEncode(value.data()));
      db
          .collection('orders')
          .doc(orderIdSelect)
          .collection('product')
          .get()
          .then((value) async {
        var jsonData = await setList2Json(value);
        orderProduct = orderProductFromJson(jsonData);

        await db
            .collection('shops')
            .doc(orderDetail.shopId)
            .get()
            .then((shopValue) async {
          ShopModel shopModel = shopModelFromJson(jsonEncode(shopValue.data()));
          shopName = shopModel.shopName;
          shopPhone = shopModel.shopPhone;
          List<String> locationLatLng = shopModel.shopLocation.split(',');
          shopLat = double.parse(locationLatLng[0]);
          shopLng = double.parse(locationLatLng[1]);
          shopAddressName = await getAddressName(shopLat, shopLng);
          print('shopAddress = ' + shopAddressName);
        });

        await db
            .collection('users')
            .doc(orderDetail.customerId)
            .get()
            .then((userValue) async {
          UserOneModel userOneModel =
              userOneModelFromJson(jsonEncode(userValue.data()));
          customerName = userOneModel.name;
          customerPhone = userOneModel.phone;
          List<String> locationLatLng = userOneModel.location.split(',');
          // customerLat = double.parse(locationLatLng[0]);
          // customerLng = double.parse(locationLatLng[1]);
          customerLat = appDataModel.latOrder;
          customerLng = appDataModel.lngOrder;

          customerAddress = await getAddressName(customerLat, customerLng);
          print('CustomerAddress = ' + customerAddress);

          if (orderDetail.driver != null && orderDetail.driver != "0") {
            await db
                .collection("drivers")
                .doc(orderDetail.driver)
                .get()
                .then((value) {
              var jsonData = jsonEncode(value.data());
              riderDetail = driversModelFromJson(jsonData);
            });
          }
          setState(() {
            loadData = true;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loadData == false) _getData(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              backgroundColor: Colors.grey.shade200,
              appBar: (orderProduct == null)
                  ? null
                  : AppBar(
                      iconTheme: IconThemeData(color: Style().darkColor),
                      backgroundColor: Colors.white,
                      bottomOpacity: 0.0,
                      elevation: 0.0,
                      title: Style()
                          .textSizeColor('ข้อมูล Order', 18, Style().darkColor),
                    ),
              body: Container(
                child: (orderProduct == null)
                    ? Center(child: Style().loading())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Style().textSizeColor(
                                          'Order $orderIdSelect',
                                          14,
                                          Style().textColor),
                                      Style().textSizeColor(
                                          'วันที่ ' + orderDetail.startTime,
                                          12,
                                          Style().textColor)
                                    ],
                                  ),
                                  (appDataModel.lastPage == "user")
                                      ? Container()
                                      : InkWell(
                                          onTap: () async {
                                            print("Qr Code");
                                            appDataModel.qrAmount = (int.parse(
                                                        orderDetail
                                                            .costDelivery) +
                                                    amount)
                                                .toString();

                                            var result = await Dialogs().confirm(
                                                context,
                                                "หมายเลขโทรศัพต้องเป็นพร้อมเพย์",
                                                "ตรวจสอบให้แน่ใจว่าหมายเลยโทรศัพท์ได้ลงทะเบียนพร้อมเพย์แล้ว");
                                            if (result == true)
                                              Navigator.pushNamed(context,
                                                  "/qrCodeRider2User-page");
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(right: 5),
                                            child: Column(
                                              children: [
                                                Icon(Icons.qr_code),
                                                Style().textSizeColor(
                                                    'รับชำระ Qr Code',
                                                    12,
                                                    Style().darkColor)
                                              ],
                                            ),
                                          ),
                                        )
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              child: Column(
                                children: [
                                  _buildRider(context.read<AppDataModel>()),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: ListTile(
                                        title: Style().textSizeColor(
                                            'ตำแหน่งร้านค้า และ สถานที่จัดส่ง',
                                            14,
                                            Style().textColor),
                                      )),
                                      IconButton(
                                        onPressed: () {
                                          (showAddress == true)
                                              ? showAddress = false
                                              : showAddress = true;
                                          setState(() {});
                                        },
                                        icon: Icon(
                                          (showAddress == false)
                                              ? FontAwesomeIcons.angleDown
                                              : FontAwesomeIcons.angleUp,
                                          color: Style().textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  (appDataModel.lastPage == "user")
                                      ? Container()
                                      : InkWell(
                                          onTap: () {
                                            appDataModel.orderDetailSelect =
                                                orderDetailFromJson(
                                                    jsonEncode(orderDetail));
                                            appDataModel.userTypeSelect =
                                                "rider";
                                            appDataModel.orderIdSelected =
                                                orderDetail.orderId;
                                            Navigator.pushNamed(
                                                context, "/chat-page");
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(left: 8),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons
                                                      .facebookMessenger,
                                                  color: Style().darkColor,
                                                ),
                                                Style().textBlackSize(
                                                    " แชตกับลูกค้า", 16),
                                              ],
                                            ),
                                          ),
                                        ),
                                  if (showAddress == true)
                                    buildShopAddress(
                                        context.read<AppDataModel>()),
                                  if (showAddress == true)
                                    buildCustomerAddress(
                                        context.read<AppDataModel>()),
                                  buildProductDetail(
                                      context.read<AppDataModel>()),
                                  buildAmount()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ));
  }

  buildAmount() {
    amount = 0;
    orderProduct.forEach((e) {
      amount += (int.parse(e.price) * int.parse(e.pcs));
    });

    return Container(
      margin: EdgeInsets.all(5),
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
              Style().textSizeColor('รวมค่าสินค้า', 14, Style().textColor),
              Style().textSizeColor('$amount ฿', 14, Style().textColor)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Style().textSizeColor('ค่าส่ง', 14, Style().textColor),
              Style().textSizeColor(
                  orderDetail.costDelivery + ' ฿', 14, Style().textColor)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Style().textSizeColor('ส่วนลด', 14, Style().textColor),
              (orderDetail.discount == null)
                  ? Style().textSizeColor("-0 ฿", 14, Style().textColor)
                  : Style().textSizeColor(
                      "-" + orderDetail.discount + ' ฿', 14, Style().textColor)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Style().textSizeColor('รวม', 16, Style().textColor),
              Style().textSizeColor(
                  (int.parse(orderDetail.costDelivery) +
                              amount -
                              int.parse(orderDetail.discount))
                          .toString() +
                      " ฿",
                  16,
                  Style().darkColor)
            ],
          )
        ],
      ),
    );
  }

  Container buildProductDetail(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(top: 5, right: 10),
      child: Column(
        children: [
          Container(
            child: Style().textSizeColor('รายการสินค้า', 14, Style().textColor),
          ),
          Container(
              margin: EdgeInsets.only(top: 1),
              child: Divider(
                color: Colors.grey,
                height: 0,
              )),
          Column(
            children: orderProduct.map((e) {
              String productDetail = "";
              appDataModel.allProductsData.forEach((element) {
                if (e.productId == element.productId) {
                  productDetail = element.productDetail;
                }
              });

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        ListTile(
                          title: (e.name?.isEmpty ?? true)
                              ? Text('')
                              : Style().textFlexibleBackSize(e.name, 2, 14),
                          subtitle: (productDetail?.isEmpty ?? true)
                              ? Text('')
                              : Style().textFlexibleColorSize(
                                  productDetail,
                                  2,
                                  12,
                                  Style().textColor,
                                ),
                        ),
                        (e.comment?.isEmpty ?? true)
                            ? Container()
                            : Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Style().textFlexibleColorSize(
                                  e.comment,
                                  2,
                                  12,
                                  Colors.red,
                                ),
                              ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Style().textSizeColor(
                          (int.parse(e.pcs) * int.parse(e.price)).toString() +
                              ' ฿',
                          14,
                          Style().textColor),
                      Row(
                        children: [
                          Style().textSizeColor(
                              e.price + " ฿", 12, Style().darkColor),
                          Style().textSizeColor(
                              '/จำนวน x ' + e.pcs, 12, Style().darkColor)
                        ],
                      )
                    ],
                  )
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Container buildShopAddress(AppDataModel appDataModel) {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(top: 3),
      color: Colors.grey.shade200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Style().textFlexibleBackSize(
                  'ร้านค้า : ' + shopName + " โทร " + shopPhone,
                  2,
                  14,
                ),
              ),
              IconButton(
                  onPressed: () {
                    _callNumber(shopPhone);
                  },
                  icon: Icon(
                    Icons.call,
                    color: Style().darkColor,
                  ))
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  FontAwesomeIcons.mapMarked,
                  color: Style().drivePrimaryColor,
                ),
              ),
              Expanded(
                  child: ListTile(
                title: (shopAddressName?.isEmpty ?? true)
                    ? Text('')
                    : Style().textFlexibleBackSize(shopAddressName, 2, 14),
              )),
              // IconButton(icon: Icon(Icons.navigate_next), onPressed: () {})
            ],
          ),
          (shopLat == null || shopLng == null)
              ? Center(
                  child: Style().circularProgressIndicator(Style().darkColor),
                )
              : showMapShop(shopLat, shopLng, shopName),
        ],
      ),
    );
  }

  Container buildCustomerAddress(AppDataModel appDataModel) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 3),
      color: Colors.grey.shade200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Style().textFlexibleBackSize(
                  'ลูกค้า : ' + customerName + " โทร" + customerPhone,
                  2,
                  14,
                ),
              ),
              IconButton(
                  onPressed: () {
                    _callNumber(customerPhone);
                  },
                  icon: Icon(
                    Icons.call,
                    color: Style().darkColor,
                  ))
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  FontAwesomeIcons.mapMarked,
                  color: Style().darkColor,
                ),
              ),
              Expanded(
                  child: ListTile(
                title: (customerAddress?.isEmpty ?? true)
                    ? Text('')
                    : Style().textFlexibleBackSize(customerAddress, 2, 14),
                subtitle: Style().textFlexibleColorSize(
                    appDataModel.orderAddressComment, 2, 12, Colors.red),
              )),
              // IconButton(icon: Icon(Icons.navigate_next), onPressed: () {})
            ],
          ),
          (customerLat == null)
              ? Center(
                  child: Style().circularProgressIndicator(Style().darkColor),
                )
              : showMapShop(customerLat, customerLng, customerName),
        ],
      ),
    );
  }

  Container showMapShop(double lat, double lng, String name) {
    print("shopLng" + shopLng.toString());
    LatLng firstLocation = LatLng(lat, lng);
    CameraPosition cameraPosition = CameraPosition(
      target: firstLocation,
      zoom: 16.0,
    );

    return Container(
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
        height: 200,
        child: GoogleMap(
          // myLocationEnabled: true,
          initialCameraPosition: cameraPosition,
          mapType: MapType.normal,
          onMapCreated: (controller) {},
          markers: shopMarker(lat, lng, name),
        ));
  }

  Set<Marker> shopMarker(double lat, double lng, String name) {
    return <Marker>[
      Marker(
          onTap: () => _openOnGoogleMapApp(lat, lng),
          markerId: MarkerId('youMarker'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: 'ตำแหน่ง', snippet: name)),
    ].toSet();
  }

  _callNumber(String number) async {
    bool res = await FlutterPhoneDirectCaller.callNumber(number);
  }

  _openOnGoogleMapApp(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      // Could not open the map.
    }
  }

  _buildRider(AppDataModel appDataModel) {
    return (orderDetail.driver == null ||
            orderDetail.driver == "0" ||
            riderDetail == null)
        ? Container()
        : Container(
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.only(top: 3),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.all(3),
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(riderDetail.driverPhotoUrl),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Style().textBlackSize("ช้อมูล Rider", 14),
                            Style().textBlackSize(riderDetail.driverName, 14),
                            Style().textBlackSize(riderDetail.driverPhone, 10),
                          ],
                        )
                      ],
                    ),
                  ],
                )
              ],
            ));
  }
}
