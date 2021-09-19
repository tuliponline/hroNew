import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/allShopModel.dart';
import 'package:hro/model/productsModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/page/frist.dart';
import 'package:hro/utility/getAddressName.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class ShowFristPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ShowFristState();
  }
}

class ShowFristState extends State<ShowFristPage> {
  double screenW;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<ProductsModel> allProductModel;
  List<AllShopModel> allShopModel;

  List<ProductsModel> ranProductModel;
  int productLength;

  String nowLocation;
  TextEditingController _locationSelect = TextEditingController();
  String address;

  _getProduct(AppDataModel appDataModel) async {
    address = await getAddressName(appDataModel.userLat, appDataModel.userLng);
    _locationSelect.text = address;
    await db.collection("shops").get().then((value) {
      var jsonData = setList2Json(value);
      allShopModel = allShopModelFromJson(jsonData);
    });
    await db
        .collection("products")
        .where("product_status", isEqualTo: "1")
        .get()
        .then((value) {
      var jsonData = setList2Json(value);
      allProductModel = productsModelFromJson(jsonData);
    });

    List<dynamic> indexRemove = [];
    allProductModel.asMap().forEach((i, e) {
      allShopModel.forEach((element) {
        if (e.shopUid == element.shopUid) {
          if (element.shopStatus != "1") {
            indexRemove.add(e);
          }
        }
      });
    });
    indexRemove.forEach((element) async {
      allProductModel.remove(element);
    });
    productLength = allProductModel.length;
    List<String> ranProductList = [];
    for (int i = 0; i < productLength;) {
      var randomItem = (allProductModel..shuffle()).first;
      bool sameData = false;
      ranProductList.forEach((element) {
        if (element == jsonEncode(randomItem)) sameData = true;
      });
      if (sameData == false) {
        ranProductList.add(jsonEncode(randomItem));
        i++;
      }
    }
    print(ranProductList.length);
    String rowData = ranProductList.toString();
    ranProductModel = productsModelFromJson(rowData);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getProduct(context.read());
  }

  @override
  Widget build(BuildContext context) {
    screenW = MediaQuery.of(context).size.width;
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: (Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 50,
                          color: Colors.white,
                        ),
                        SafeArea(
                            child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Style()
                                  .textSizeColor("เฮาะ", 24, Style().darkColor),
                            ],
                          ),
                        ))
                      ],
                    ),
                    _addressBar(appDataModel),
                    _buildProduct()
                  ],
                ),
              ),
            ))));
  }

  _addressBar(AppDataModel appDataModel) {
    int textfieldw = 30;
    return Container(
        margin: EdgeInsets.only(top: 3, right: 5, left: 5),
        alignment: Alignment.topRight,
        child: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  height: double.parse(textfieldw.toString()),
                  child: TextField(
                    readOnly: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "prompt",
                        fontSize: 10,
                        color: Colors.black),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(
                          left: 5,
                          bottom: textfieldw / 4, // HERE THE IMPORTANT PART
                        ),
                        hintText: 'สถานที่จัดส่ง',
                        hintStyle: TextStyle(
                            fontFamily: "prompt",
                            fontSize: 10,
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
                          onTap: () async {
                            print("text Icon select");

                            var result = await Navigator.pushNamed(
                                context, "/googleMap-page");

                            if (result != null) {
                              print("locationResult = " + result.toString());
                              List dataRow = result;
                              appDataModel.userLat = dataRow[0];
                              appDataModel.userLng = dataRow[1];

                              print("locationResult = " +
                                  appDataModel.userLng.toString());

                              _updateAddress(appDataModel);
                            }
                          },
                          child: Icon(
                            FontAwesomeIcons.mapMarkerAlt,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white),
                    controller: _locationSelect,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  _updateAddress(AppDataModel appDataModel) async {
    nowLocation =
        appDataModel.userLat.toString() + "," + appDataModel.userLng.toString();

    address = await getAddressName(appDataModel.userLat, appDataModel.userLng);
    _locationSelect.text = address;
    setState(() {});
  }

  _buildProduct() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Style().textSizeColor("แนะนำ", 16, Style().darkColor),
            ],
          ),
          (ranProductModel == null)
              ? Container(height: 150, child: Style().loading())
              : StaggeredGridView.countBuilder(
                  shrinkWrap: true,
                  primary: false,
                  crossAxisCount: 2,
                  staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: ranProductModel.length,
                  itemBuilder: (BuildContext context, int index) {
                    int costDeliveryStr;
                    ShopModel shopModel;
                    for (var shop in allShopModel) {
                      if (shop.shopUid == ranProductModel[index].shopUid) {
                        shopModel = shopModelFromJson(jsonEncode(shop));
                      }
                    }
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
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
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
          // Container(
          //   width: screenW * 0.7,
          //   child: ElevatedButton(
          //       style: ElevatedButton.styleFrom(primary: Style().darkColor),
          //       onPressed: () {},
          //       child:
          //           Style().textSizeColor("เลือกสินค้าต่อ", 14, Colors.white)),
          // )
        ],
      ),
    );
  }
}
