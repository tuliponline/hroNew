import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/src/list_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminOrderPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AdminOrderState();
  }
}

class AdminOrderState extends State<AdminOrderPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  bool getDataStatus = false;
  List<OrderList> orderList;

  List statusString = [
    {"value": "0", "text": "ร้านค้ายกเลิก"},
    {"value": "1", "text": "รอ Rider ตแบรับ"},
    {"value": "2", "text": "Rider ยืนยันแล้ว"},
    {"value": "3", "text": "ร้านค้ากำลังเตียม"},
    {"value": "4", "text": "กำลังออกส่ง"},
    {"value": "5", "text": "สำเร็จ"},
    {"value": "6", "text": "ส่งไม่สำเร็จ"},
    {"value": "9", "text": "รอ Rider ยืนยัน"}
  ];

  String limitValue = "10";

  _getOrder() async {
    await db
        .collection("orders")
        .orderBy("orderId", descending: true)
        .get()
        .then((value) async {
      var jsonData = await setList2Json(value);
      orderList = orderListFromJson(jsonData);
      setState(() {
        getDataStatus = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (getDataStatus == false) _getOrder();
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              backgroundColor: Color.fromRGBO(242, 244, 251, 1),
              appBar: AppBar(
                iconTheme: IconThemeData(color: Style().darkColor),
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                title: Style().textDarkAppbar("Orders"),
              ),
              body: (orderList == null)
                  ? Center(child: Style().loading())
                  : Container(
                      child: SingleChildScrollView(
                      child: Column(
                        children: [
                          buildLimit(),
                          buildOrderList(context.read<AppDataModel>())
                        ],
                      ),
                    )),
            ));
  }

  checkTimestampNow(int timestamp) {
    var timeNow = DateTime.now().toUtc();
    var d1 = DateTime.utc(timeNow.year, timeNow.month, timeNow.day);
    var timeOrder = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var d2 = DateTime.utc(timeOrder.year, timeOrder.month, timeOrder.day);

    print(d1);
    print(d2);
    //you can add today's date here
    if (d2.compareTo(d1) == 0) {
      print('true');
    } else {
      print('false');
    }
  }

  buildLimit() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Style().textBlackSize("Order ", 12),
        DropdownButton<String>(
          value: limitValue,
          icon: const Icon(Icons.arrow_drop_down_circle_outlined),
          iconSize: 20,
          elevation: 16,
          style: const TextStyle(color: Colors.blueAccent),
          underline: Container(
            height: 2,
            color: Colors.blueAccent,
          ),
          onChanged: (String newValue) {
            setState(() {
              limitValue = newValue;
              setState(() {});
            });
          },
          items: <String>['10', '30', '50', '100', '500']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(fontSize: 18),
              ),
            );
          }).toList(),
        ),
        Style().textBlackSize("รายการ", 12),
      ],
    );
  }

  buildOrderList(AppDataModel appDataModel) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: orderList.mapIndexed((int index, e) {
            int orderTimestamp = int.parse(e.orderId);
            String orderStatusString = "";
            statusString.forEach((element) {
              if (element['value'] == e.status) {
                orderStatusString = element['text'];
              }
            });
            return (index < int.parse(limitValue))
                ? InkWell(
                    onTap: () {
                      appDataModel.orderIdSelected = e.orderId;
                      if (e.comment != null)
                        appDataModel.orderAddressComment = e.comment;
                      print(e.location);
                      List<String> locationLatLng = e.location.split(',');
                      appDataModel.latOrder = double.parse(locationLatLng[0]);
                      appDataModel.lngOrder = double.parse(locationLatLng[1]);

                      Navigator.pushNamed(context, "/order2Rider-page");
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: (e.status == "1")
                            ? Colors.red.shade100
                            : Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(28),
                            blurRadius: 5,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(top: 3, left: 5, right: 5),
                      child: Row(
                        children: [
                          Expanded(
                              child: ListTile(
                            title: Style().textBlackSize(e.orderId, 12),
                            subtitle: Style().textBlackSize(e.startTime, 10),
                          )),
                          Container(
                            margin: EdgeInsets.only(right: 8),
                            child: Style().textBlackSize(orderStatusString, 12),
                          )
                        ],
                      ),
                    ),
                  )
                : Container();
          }).toList(),
        ),
      ),
    );
  }
}
