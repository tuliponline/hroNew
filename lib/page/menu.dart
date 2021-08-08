import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/productsModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MenuState();
  }
}

class MenuState extends State<MenuPage> {
  Dialogs dialogs = Dialogs();
  File file;
  final picker = ImagePicker();
  String photoUrl;
  bool popupSelect = false;

  int timeFood = 5;
  bool getProductsStatus = false;
  List<bool> productStatusList = [];
  bool updateTing = false;
  int menuCount = 0;

  _getProduct(AppDataModel appDataModel) async {
    CollectionReference products =
        FirebaseFirestore.instance.collection('products');

    await products
        .where('shop_uid', isEqualTo: appDataModel.userOneModel.uid)
        .get()
        .then((value) async {
      var jsonData = await setList2Json(value);
      print("getProduct = $jsonData");

      var jsobData = setList2Json(value);
      appDataModel.productsData = productsModelFromJson(jsobData);
      menuCount = appDataModel.productsData.length;

      productStatusList = [];
      appDataModel.productsData.forEach((element) {
        (element.productStatus == '2')
            ? productStatusList.add(false)
            : productStatusList.add(true);
      });
    }).catchError((onError) {
      appDataModel.productsData = null;
      print(onError.toString());
    });
    setState(() {
      print("productStatus = " + productStatusList.length.toString());
      print('productAll = ' + appDataModel.productsData.length.toString());
      getProductsStatus = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (getProductsStatus == false) _getProduct(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                iconTheme: IconThemeData(color: Style().darkColor),
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                title: Style().textSizeColor(
                    'สินค้า $menuCount รายการ', 16, Style().darkColor),
                actions: [
                  IconButton(
                      icon: Icon(
                        FontAwesomeIcons.sync,
                        color: Style().darkColor,
                      ),
                      onPressed: () {
                        getProductsStatus = false;
                        _getProduct(context.read<AppDataModel>());
                      }),
                  IconButton(
                      icon: Icon(
                        FontAwesomeIcons.plusCircle,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        var result =
                            await Navigator.pushNamed(context, '/addMenu-Page');
                        print(result);
                        if (result != null) {
                          setState(() {
                            getProductsStatus = false;
                          });
                        }
                      }),
                ],
              ),
              body: Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: ListView(
                    children: [
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 10),
                            child: buildProducts(context.read<AppDataModel>()),
                          ),
                          //buildPopularProduct(),
                          //buildPopularShop((context.read<AppDataModel>()))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  buildProducts(AppDataModel appDataModel) {
    List<ProductsModel> _productsData = appDataModel.productsData;
    return (_productsData != null)
        ? (_productsData.length == 0)
            ? Container(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Style().textBlackSize("กดเมนู ", 16),
                      IconButton(
                          onPressed: () async {
                            var result = await Navigator.pushNamed(
                                context, '/addMenu-Page');
                            print(result);
                            if (result != null) {
                              setState(() {
                                getProductsStatus = false;
                              });
                            }
                          },
                          icon: Icon(
                            FontAwesomeIcons.plusCircle,
                            color: Colors.red,
                          )),
                      Style().textBlackSize("เพื่อเพิ่มสินค้า ", 16)
                    ],
                  ),
                ),
              )
            : Column(
                children: _productsData.map((e) {
                  int i = _productsData.indexOf(e);
                  print("i=" + i.toString());

                  return Column(
                    children: [
                      (e.productStatus == "0")
                          ? Container()
                          : Container(
                              width: appDataModel.screenW,
                              color: Colors.white,
                              margin: EdgeInsets.only(bottom: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin:
                                        EdgeInsets.only(left: 10, bottom: 8),
                                    height: 100,

                                    //color: Colors.green,
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: NetworkImage(
                                                  _productsData[i]
                                                      .productPhotoUrl),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: appDataModel.screenW * 0.5,
                                          padding: EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Style().textBlackSize(
                                                  'สินค้า: ' +
                                                      _productsData[i]
                                                          .productName,
                                                  14),
                                              Style().textBlackSize(
                                                  'รายละเอียด : ' +
                                                      _productsData[i]
                                                          .productDetail,
                                                  12),
                                              Style().textBlackSize(
                                                  'ราคา : ' +
                                                      _productsData[i]
                                                          .productPrice +
                                                      " ฿",
                                                  14),
                                              Style().textBlackSize(
                                                  'เวลาเตรียม : ' +
                                                      _productsData[i]
                                                          .productTime +
                                                      ' นาที',
                                                  14),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                          icon: Icon(
                                            FontAwesomeIcons.edit,
                                            color: Colors.deepOrange,
                                          ),
                                          onPressed: () async {
                                            appDataModel.productEditId =
                                                e.productId;
                                            var result =
                                                await Navigator.pushNamed(
                                                    context, '/editMenu-Page');
                                            if (result != null ||
                                                result == true) {
                                              setState(() {
                                                getProductsStatus = false;
                                              });
                                            }
                                          }),
                                      (e.productStatus == "3")
                                          ? Style().textSizeColor('รอตรวจสอบ',
                                              14, Colors.deepOrangeAccent)
                                          : (productStatusList.length == 0)
                                              ? Container()
                                              : Switch(
                                                  activeColor:
                                                      Style().darkColor,
                                                  value: productStatusList[i],
                                                  onChanged: (e.productStatus ==
                                                              '1' ||
                                                          e.productStatus ==
                                                              '2')
                                                      ? (value) async {
                                                          if (value == true) {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'products')
                                                                .doc(
                                                                    e.productId)
                                                                .update({
                                                              'product_status':
                                                                  '1'
                                                            });
                                                          } else {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'products')
                                                                .doc(
                                                                    e.productId)
                                                                .update({
                                                              'product_status':
                                                                  '2'
                                                            });
                                                          }
                                                          setState(() {
                                                            productStatusList[
                                                                i] = value;
                                                          });
                                                        }
                                                      : null)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ],
                  );
                }).toList(),
              )
        : Container();
  }
}
