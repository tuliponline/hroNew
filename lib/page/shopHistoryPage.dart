import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/riderHistoryListModel.dart';
import 'package:hro/utility/calRating.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ShopHistoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ShopHistoryState();
  }
}

class ShopHistoryState extends State<ShopHistoryPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<RiderHistoryListModel> riderHistoryListModel;

  int amountAll = 0;
  int orderCount = 0;

  double shopRating = 0;
  DateTime startDate = DateTime.now();
  DateTime stopDate = DateTime.now();

  _getDriverHistory(AppDataModel appDataModel) async {
    print("stopDateFrist = " + stopDate.toString());
    startDate = DateTime.parse(
        DateFormat('yyyy-MM-dd 00:00').format(startDate).toString());
    stopDate = DateTime.parse(
        DateFormat('yyyy-MM-dd 00:00').format(stopDate).toString());

    print("FfstartDate = " + startDate.toString());
    stopDate = stopDate.add(Duration(hours: 23, minutes: 59));
    print("stopDate = " + stopDate.toString());

    amountAll = 0;
    orderCount = 0;
    List ratingResult = await calRatingShop(appDataModel.userOneModel.uid);
    shopRating = ratingResult[0];
    appDataModel.shopRatingList = ratingResult[1];
    print(startDate);
    await db
        .collection("orders")
        .where("shopId", isEqualTo: appDataModel.userOneModel.uid)
        .where("status", isEqualTo: "5")
        .get()
        .then((value) {
      var jsonData = setList2Json(value);
      riderHistoryListModel = riderHistoryListModelFromJson(jsonData);
      riderHistoryListModel.forEach((e) {
        final DateTime timeStamp =
            DateTime.fromMillisecondsSinceEpoch(int.parse(e.orderId));
        if (timeStamp.isAfter(startDate) && timeStamp.isBefore(stopDate)) {
          int am = int.parse(e.amount);
          amountAll += am;
          orderCount += 1;
        }
      });
    });

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getDriverHistory(context.read<AppDataModel>());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: AppBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Style().textBlackSize("Shop Stars", 14),
                        (shopRating == 0.0)
                            ? Style().textBlackSize("ยังไม่มีคะแนน", 12)
                            : Row(
                                children: [
                                  RatingBar.builder(
                                    itemSize: 15,
                                    initialRating: shopRating,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 2.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                    },
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, "/shopReview-page");
                                    },
                                    child: Style().textSizeColor(
                                        " ดูรีวิว", 10, Style().darkColor),
                                  )
                                ],
                              ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.motorcycle))
                ],
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
              body: (riderHistoryListModel == null)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Style().loading(),
                      ],
                    )
                  : Container(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                    child:
                                        Style().textBlackSize("วันที่  ", 12)),
                                Row(
                                  children: [
                                    Style().textBlackSize(
                                        appDataModel.dateShowFormat
                                            .format(startDate),
                                        12),
                                    IconButton(
                                      onPressed: () {
                                        DatePicker.showDatePicker(context,
                                            showTitleActions: true,
                                            minTime: DateTime(2021, 01, 01),
                                            maxTime: DateTime.now(),
                                            theme: DatePickerTheme(
                                                headerColor: Style().darkColor,
                                                backgroundColor: Colors.white,
                                                itemStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily:
                                                        Style().masterFont,
                                                    fontSize: 16),
                                                doneStyle: TextStyle(
                                                    fontFamily:
                                                        Style().masterFont,
                                                    color: Colors.white,
                                                    fontSize: 16),
                                                cancelStyle: TextStyle(
                                                    fontFamily:
                                                        Style().masterFont,
                                                    color: Colors.white,
                                                    fontSize: 16)),
                                            onChanged: (date) {
                                          print('change $date in time zone ' +
                                              date.timeZoneOffset.inHours
                                                  .toString());
                                        }, onConfirm: (date) {
                                          setState(() {
                                            print('confirm $date');

                                            startDate = date;
                                          });
                                        },
                                            currentTime: startDate,
                                            locale: LocaleType.th);
                                      },
                                      icon: Icon(
                                        Icons.calendar_today,
                                        size: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                    child: Style().textBlackSize("ถึง  ", 12)),
                                Row(
                                  children: [
                                    Style().textBlackSize(
                                        appDataModel.dateShowFormat
                                            .format(stopDate),
                                        12),
                                    IconButton(
                                      onPressed: () {
                                        DatePicker.showDatePicker(context,
                                            showTitleActions: true,
                                            minTime: startDate,
                                            maxTime: DateTime.now(),
                                            theme: DatePickerTheme(
                                                headerColor: Style().darkColor,
                                                backgroundColor: Colors.white,
                                                itemStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily:
                                                        Style().masterFont,
                                                    fontSize: 16),
                                                doneStyle: TextStyle(
                                                    fontFamily:
                                                        Style().masterFont,
                                                    color: Colors.white,
                                                    fontSize: 16),
                                                cancelStyle: TextStyle(
                                                    fontFamily:
                                                        Style().masterFont,
                                                    color: Colors.white,
                                                    fontSize: 16)),
                                            onChanged: (date) {
                                          print('change $date in time zone ' +
                                              date.timeZoneOffset.inHours
                                                  .toString());
                                        }, onConfirm: (date) {
                                          setState(() {
                                            print('confirmStopTime $date');

                                            stopDate = date;
                                          });
                                        },
                                            currentTime: stopDate,
                                            locale: LocaleType.th);
                                      },
                                      icon: Icon(
                                        Icons.calendar_today,
                                        size: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Style().darkColor,
                                    child: IconButton(
                                      onPressed: () {
                                        _getDriverHistory(
                                            context.read<AppDataModel>());
                                      },
                                      icon: Icon(Icons.search),
                                      iconSize: 15,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 2),
                            padding: EdgeInsets.all(10),
                            color: Colors.black12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Style().textSizeColor(
                                    "รายได้รวม", 14, Colors.black),
                                Style().textSizeColor(
                                    appDataModel.moneyFormat
                                            .format((amountAll)) +
                                        " ฿",
                                    14,
                                    Colors.black)
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 2),
                            padding: EdgeInsets.all(10),
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Style().textSizeColor(
                                    "จำนวน order", 14, Colors.black),
                                Style().textSizeColor(
                                    AppDataModel()
                                        .moneyFormat
                                        .format(orderCount),
                                    14,
                                    Colors.black)
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 2),
                            padding: EdgeInsets.all(10),
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Style().textSizeColor(
                                    "ค่าสินค้า", 14, Colors.black),
                                Style().textSizeColor(
                                    appDataModel.moneyFormat.format(amountAll) +
                                        " ฿",
                                    14,
                                    Colors.black)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ));
  }
}
