import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/GasSetupModel.dart';
import 'package:hro/model/MartSetupModel.dart';
import 'package:hro/model/locationSetupModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/model/setupModel.dart';
import 'package:hro/page/fireBaseFunctions.dart';
import 'package:hro/utility/AppTheme.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/SizeConfig.dart';
import 'package:hro/utility/getAddressName.dart';

import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class ServiceSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ServiceSettingState();
  }
}

class ServiceSettingState extends State<ServiceSettingPage> {
  ThemeData themeData = ThemeData.light();

  var _value = TextEditingController();

  LocationSetupModel locationSetupModel;
  MartSetupModel martSetupModel;
  ProductSetupModel productSetupModel;
  GasSetupModel gasSetupModel;
  bool loading = false;
  String LocationName;
  double cenLat, cenLng, screenW;

  String gasStationName;
  double gasLat, gasLng;
  bool martStatus = false;
  bool gasStatus = false;

  _getSetup(AppDataModel appDataModel) async {
    screenW = appDataModel.screenW;
    var _locaDb =
        await dbGetDataOne("getLocation", "appstatus", "locationSetup");
    if (_locaDb[0]) {
      locationSetupModel = locationSetupModelFromJson(_locaDb[1]);

      var _centerLocation = locationSetupModel.centerLocation.split(",");
      cenLat = double.parse(_centerLocation[0]);
      cenLng = double.parse(_centerLocation[1]);
      LocationName = await getAddressName(cenLat, cenLng);
    }

    var _productDb = await dbGetDataOne("getProductSetup", "setup", "product");
    if (_productDb[0]) {
      productSetupModel = productSetupModelFromJson(_productDb[1]);
    }

    var _martDb = await dbGetDataOne("getMartSetup", "martSetup", "001");
    if (_martDb[0]) {
      martSetupModel = martSetupModelFromJson(_martDb[1]);
      if (martSetupModel.status == "1") martStatus = true;
    }
    var _gasDb = await dbGetDataOne("getGasSetup", "gasSetup", "001");
    if (_gasDb[0]) {
      gasSetupModel = gasSetupModelFromJson(_gasDb[1]);
      var _centerLocation = gasSetupModel.gasLocation.split(",");
      gasLat = double.parse(_centerLocation[0]);
      gasLng = double.parse(_centerLocation[1]);
      gasStationName = await getAddressName(gasLat, gasLng);
      if (gasSetupModel.status == "1") gasStatus = true;
    }
    setState(() {});
  }

  @override
  void initState() {
    _getSetup(context.read<AppDataModel>());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              backgroundColor: themeData.scaffoldBackgroundColor,
              appBar: AppBar(
                iconTheme: IconThemeData(color: Style().darkColor),
                backgroundColor: themeData.scaffoldBackgroundColor,
                bottomOpacity: 0.0,
                elevation: 0.0,
                title: Style().textDarkAppbar("ตั้งค่าบริการ"),
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios)),
                actions: [],
              ),
              body: (locationSetupModel == null)
                  ? Center(child: Style().loading())
                  : Container(
                      margin: EdgeInsets.only(left: 5),
                      child: ListView(
                        padding: EdgeInsets.all(8),
                        children: [
                          _buildCeterPoint(context.read<AppDataModel>()),
                          Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: Style().underLine()),
                          _buildFoodSeting(),
                          Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: Style().underLine()),
                          _buildMartSeting(),
                          Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: Style().underLine()),
                          _buildGasSeting(context.read<AppDataModel>())
                        ],
                      ),
                    ),
            ));
  }

  _buildCeterPoint(AppDataModel appDataModel) {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 0),
            child: Row(
              children: [Style().textBlackSize("บริการ", 16)],
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.mapMarkerAlt),
                        Style().textBlackSize("Location หลัก", 14)
                      ],
                    ),
                    Row(
                      children: [
                        (LocationName == null)
                            ? Container()
                            : Container(
                                width: screenW * 0.5,
                                child: Style()
                                    .textFlexibleBackSize(LocationName, 2, 14)),
                        IconButton(
                            onPressed: () async {
                              appDataModel.userLat = cenLat;
                              appDataModel.userLng = cenLng;
                              var result = await Navigator.pushNamed(
                                  context, "/googleMap-page");
                              if (result != null) {
                                setState(() {
                                  loading = true;
                                });
                                List latlngNew = result;
                                cenLat = latlngNew[0];
                                cenLng = latlngNew[1];
                                appDataModel.userLat = cenLat;
                                appDataModel.userLng = cenLng;
                                LocationName =
                                    await getAddressName(cenLat, cenLng);
                                await dbUpdate(
                                    "updateLocationCenter",
                                    "appstatus",
                                    "locationSetup",
                                    {"centerLocation": "$cenLat,$cenLng"});
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                            icon: Icon(Icons.navigate_next))
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildFoodSeting() {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 5, bottom: 0),
            child: Row(
              children: [Style().textBlackSize("สั่งสินค้า", 16)],
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [Style().textBlackSize("รัศมีเริมต้น", 14)],
                    ),
                    Row(
                      children: [
                        Style().textBlackSize(
                            locationSetupModel.distanceStart + " กม.", 16),
                        IconButton(
                            onPressed: () async {
                              var _result = await inputDialog(
                                  context,
                                  "ระยะทาง",
                                  "ระยะทาง",
                                  locationSetupModel.distanceStart,
                                  "number");
                              if (_result[0]) {
                                setState(() {
                                  loading = true;
                                });
                                locationSetupModel.distanceStart = _result[1];

                                await dbUpdate(
                                    "updateLocationCenter",
                                    "appstatus",
                                    "locationSetup",
                                    {"distanceStart": _result[1]});
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                            icon: Icon(Icons.navigate_next))
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Style().textBlackSize("ระยะทางให้บริการสูงสุด", 14)
                      ],
                    ),
                    Row(
                      children: [
                        Style().textBlackSize(
                            locationSetupModel.distanceMax + ' กม.', 16),
                        IconButton(
                            onPressed: () async {
                              var _result = await inputDialog(
                                  context,
                                  "ระยะทางให้บริการ",
                                  "ระยะทางให้บริการ",
                                  locationSetupModel.distanceMax,
                                  "number");
                              if (_result[0]) {
                                setState(() {
                                  loading = true;
                                });
                                locationSetupModel.distanceMax = _result[1];

                                await dbUpdate(
                                    "updateLocationCenter",
                                    "appstatus",
                                    "locationSetup",
                                    {"distanceMax": _result[1]});
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                            icon: Icon(Icons.navigate_next))
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Style().textBlackSize("ค่าบริการเริ่มต้น", 14)
                      ],
                    ),
                    Row(
                      children: [
                        Style().textBlackSize(
                            "฿ " + locationSetupModel.costDeliveryMin, 16),
                        IconButton(
                            onPressed: () async {
                              var _result = await inputDialog(
                                  context,
                                  "ค่าบริการเริ่มต้น",
                                  "ค่าบริการเริ่มต้น",
                                  locationSetupModel.costDeliveryMin,
                                  "number");
                              if (_result[0]) {
                                setState(() {
                                  loading = true;
                                });
                                locationSetupModel.costDeliveryMin = _result[1];

                                await dbUpdate(
                                    "updateLocationCenter",
                                    "appstatus",
                                    "locationSetup",
                                    {"costDeliveryMin": _result[1]});
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                            icon: Icon(Icons.navigate_next))
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [Style().textBlackSize("ค่าบริการ/กม. ", 14)],
                    ),
                    Row(
                      children: [
                        Style().textBlackSize(
                            "฿ " + locationSetupModel.costDeliveryPerKm, 16),
                        IconButton(
                            onPressed: () async {
                              var _result = await inputDialog(
                                  context,
                                  "ค่าบริการส่วนเกิน",
                                  "ค่าบริการส่วนเกิน",
                                  locationSetupModel.costDeliveryPerKm,
                                  "number");
                              if (_result[0]) {
                                setState(() {
                                  loading = true;
                                });
                                locationSetupModel.costDeliveryPerKm =
                                    _result[1];

                                await dbUpdate(
                                    "updateLocationCenter",
                                    "appstatus",
                                    "locationSetup",
                                    {"costDeliveryPerKm": _result[1]});
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                            icon: Icon(Icons.navigate_next))
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Style().textBlackSize(
                            "ค่าบริการต่อชิ้น(ชิ้นที่2ขึ้นไป)", 14)
                      ],
                    ),
                    Row(
                      children: [
                        Style().textBlackSize(
                            "฿ " + locationSetupModel.costDeliveryPerPcs, 16),
                        IconButton(
                            onPressed: () async {
                              var _result = await inputDialog(
                                  context,
                                  "ค่าบริการต่อชิ้น",
                                  "ค่าบริการต่อชิ้น",
                                  locationSetupModel.costDeliveryPerPcs,
                                  "number");
                              if (_result[0]) {
                                setState(() {
                                  loading = true;
                                });
                                locationSetupModel.costDeliveryPerPcs =
                                    _result[1];

                                await dbUpdate(
                                    "updateLocationCenter",
                                    "appstatus",
                                    "locationSetup",
                                    {"costDeliveryPerPcs": _result[1]});
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                            icon: Icon(Icons.navigate_next))
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [Style().textBlackSize("+ราคาสินค้า %", 14)],
                    ),
                    Row(
                      children: [
                        Style().textBlackSize(productSetupModel.gp + " %", 16),
                        IconButton(
                            onPressed: () async {
                              var _result = await inputDialog(
                                  context,
                                  "+ราคาสินค้า %",
                                  "+ราคาสินค้า %",
                                  productSetupModel.gp,
                                  "number");
                              if (_result[0]) {
                                setState(() {
                                  loading = true;
                                });
                                productSetupModel.gp = _result[1];

                                await dbUpdate("updateProductSetup", "setup",
                                    "product", {"gp": _result[1]});
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                            icon: Icon(Icons.navigate_next))
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [Style().textBlackSize("% ค่าส่ง", 14)],
                    ),
                    Row(
                      children: [
                        Style().textBlackSize(
                            productSetupModel.shareForApp + " %", 16),
                        IconButton(
                            onPressed: () async {
                              var _result = await inputDialog(
                                  context,
                                  "% ค่าส่ง",
                                  "% ค่าส่ง",
                                  productSetupModel.shareForApp,
                                  "number");
                              if (_result[0]) {
                                setState(() {
                                  loading = true;
                                });
                                productSetupModel.shareForApp = _result[1];

                                await dbUpdate("updateProductSetup", "setup",
                                    "product", {"shareForApp": _result[1]});
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                            icon: Icon(Icons.navigate_next))
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildMartSeting() {
    return (martSetupModel == null)
        ? Container()
        : Container(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 5, bottom: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Style().textBlackSize("ฝากซื้อของ", 16),
                      Switch(
                          activeColor: Style().darkColor,
                          value: martStatus,
                          onChanged: (value) async {
                            String text = "";
                            String _status = "0";

                            if (value == true) {
                              text = "เปิดบริการฝากซื้อ";
                              _status = "1";
                            } else {
                              text = "ปิดบริการฝากซื้อ";
                              _status = "0";
                            }

                            var _result = await Dialogs()
                                .confirm(context, text, 'ยืนยัน $text');
                            if (_result == true) {
                              await dbUpdate("changeStatusMart", "martSetup",
                                  "001", {"status": _status});

                              setState(() {
                                martStatus = value;
                              });
                            }
                          })
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Style().textBlackSize("รัศมีเริมต้น", 14)
                            ],
                          ),
                          Row(
                            children: [
                              Style().textBlackSize(
                                  martSetupModel.distancsStart + " กม.", 16),
                              IconButton(
                                  onPressed: () async {
                                    var _result = await inputDialog(
                                        context,
                                        "รัศมีเริมต้น",
                                        "รัศมีเริมต้น",
                                        martSetupModel.distancsStart,
                                        "number");
                                    if (_result[0]) {
                                      setState(() {
                                        loading = true;
                                      });
                                      martSetupModel.distancsStart = _result[1];

                                      await dbUpdate(
                                          "updatemartConfig",
                                          "martSetup",
                                          "001",
                                          {"distancsStart": _result[1]});
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.navigate_next))
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Style()
                                  .textBlackSize("ระยะทางให้บริการสูงสุด", 14)
                            ],
                          ),
                          Row(
                            children: [
                              Style().textBlackSize(
                                  martSetupModel.distancsMax + " กม.", 16),
                              IconButton(
                                  onPressed: () async {
                                    var _result = await inputDialog(
                                        context,
                                        "ระยะทาง",
                                        "ระยะทาง",
                                        martSetupModel.distancsMax,
                                        "number");
                                    if (_result[0]) {
                                      setState(() {
                                        loading = true;
                                      });
                                      martSetupModel.distancsMax = _result[1];

                                      await dbUpdate(
                                          "updatemartConfig",
                                          "martSetup",
                                          "001",
                                          {"distancsMax": _result[1]});
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.navigate_next))
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Style().textBlackSize("ค่าบริการเริ่มต้น", 14)
                            ],
                          ),
                          Row(
                            children: [
                              Style().textBlackSize(
                                  "฿ " + martSetupModel.costDeliveryStart, 16),
                              IconButton(
                                  onPressed: () async {
                                    var _result = await inputDialog(
                                        context,
                                        "ค่าบริการเริ่มต้น",
                                        "ค่าบริการเริ่มต้น",
                                        martSetupModel.costDeliveryStart,
                                        "number");
                                    if (_result[0]) {
                                      setState(() {
                                        loading = true;
                                      });
                                      martSetupModel.costDeliveryStart =
                                          _result[1];

                                      await dbUpdate(
                                          "updatemartConfig",
                                          "martSetup",
                                          "001",
                                          {"costDeliveryStart": _result[1]});
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.navigate_next))
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Style().textBlackSize("ค่าบริการ/กม.", 14)
                            ],
                          ),
                          Row(
                            children: [
                              Style().textBlackSize(
                                  "฿ " + martSetupModel.costPerKm, 16),
                              IconButton(
                                  onPressed: () async {
                                    var _result = await inputDialog(
                                        context,
                                        "ค่าบริการ/กม.",
                                        "ค่าบริการ/กม.",
                                        martSetupModel.costPerKm,
                                        "number");
                                    if (_result[0]) {
                                      setState(() {
                                        loading = true;
                                      });
                                      martSetupModel.costPerKm = _result[1];

                                      await dbUpdate(
                                          "updatemartConfig",
                                          "martSetup",
                                          "001",
                                          {"costPerKm": _result[1]});
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.navigate_next))
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Style().textBlackSize(
                                  "ค่าบริการต่อชิ้น(ชิ้นที่2ขึ้นไป)", 14)
                            ],
                          ),
                          Row(
                            children: [
                              Style().textBlackSize(
                                  "฿ " + martSetupModel.costPerPcs, 16),
                              IconButton(
                                  onPressed: () async {
                                    var _result = await inputDialog(
                                        context,
                                        "ค่าบริการต่อชิ้น",
                                        "ค่าบริการต่อชิ้น",
                                        martSetupModel.costPerPcs,
                                        "number");
                                    if (_result[0]) {
                                      setState(() {
                                        loading = true;
                                      });
                                      martSetupModel.costPerPcs = _result[1];

                                      await dbUpdate(
                                          "updatemartConfig",
                                          "martSetup",
                                          "001",
                                          {"costPerPcs": _result[1]});
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.navigate_next))
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Style().textBlackSize(
                                  "ค่าบริกการต่อจุดซื้อ(จุดที่2ชึ้นไป)", 14)
                            ],
                          ),
                          Row(
                            children: [
                              Style().textBlackSize(
                                  "฿ " + martSetupModel.costPerShop, 16),
                              IconButton(
                                  onPressed: () async {
                                    var _result = await inputDialog(
                                        context,
                                        "ค่าบริกการต่อจุด",
                                        "ค่าบริกการต่อจุด",
                                        martSetupModel.costPerShop,
                                        "number");
                                    if (_result[0]) {
                                      setState(() {
                                        loading = true;
                                      });
                                      martSetupModel.costPerShop = _result[1];

                                      await dbUpdate(
                                          "updatemartConfig",
                                          "martSetup",
                                          "001",
                                          {"costPerShop": _result[1]});
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.navigate_next))
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [Style().textBlackSize("% ค่าส่ง", 14)],
                          ),
                          Row(
                            children: [
                              Style().textBlackSize(
                                  martSetupModel.shareForApp + " %", 16),
                              IconButton(
                                  onPressed: () async {
                                    var _result = await inputDialog(
                                        context,
                                        "% ค่าส่ง",
                                        "% ค่าส่ง",
                                        martSetupModel.shareForApp,
                                        "number");
                                    if (_result[0]) {
                                      setState(() {
                                        loading = true;
                                      });
                                      martSetupModel.shareForApp = _result[1];

                                      await dbUpdate(
                                          "updatemartConfig",
                                          "martSetup",
                                          "001",
                                          {"shareForApp": _result[1]});
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.navigate_next))
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  _buildGasSeting(AppDataModel appDataModel) {
    return (gasSetupModel == null)
        ? Container()
        : Container(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 5, bottom: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Style().textBlackSize("เติมแก๊ส", 16),
                      Switch(
                          activeColor: Style().darkColor,
                          value: gasStatus,
                          onChanged: (value) async {
                            String text = "";
                            String _status = "0";

                            if (value == true) {
                              text = "เปิดบริการเติมแก๊ส";
                              _status = "1";
                            } else {
                              text = "ปิดบริการเติมแก๊ส";
                              _status = "0";
                            }

                            var _result = await Dialogs()
                                .confirm(context, text, 'ยืนยัน $text');
                            if (_result == true) {
                              await dbUpdate("changeStatusMart", "gasSetup",
                                  "001", {"status": _status});

                              setState(() {
                                gasStatus = value;
                              });
                            }
                          })
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(FontAwesomeIcons.mapMarkerAlt),
                              Style().textBlackSize("ปั้มแก๊ส", 14)
                            ],
                          ),
                          Row(
                            children: [
                              (LocationName == null)
                                  ? Container()
                                  : Container(
                                      width: screenW * 0.5,
                                      child: Style().textFlexibleBackSize(
                                          gasStationName, 2, 14)),
                              IconButton(
                                  onPressed: () async {
                                    appDataModel.userLat = gasLat;
                                    appDataModel.userLng = gasLng;
                                    var result = await Navigator.pushNamed(
                                        context, "/googleMap-page");
                                    if (result != null) {
                                      setState(() {
                                        loading = true;
                                      });
                                      List latlngNew = result;
                                      gasLat = latlngNew[0];
                                      gasLng = latlngNew[1];
                                      appDataModel.userLat = gasLat;
                                      appDataModel.userLng = gasLng;
                                      gasStationName =
                                          await getAddressName(gasLat, gasLng);
                                      await dbUpdate(
                                          "ipdategaStation",
                                          "gasSetup",
                                          "001",
                                          {"gasLocation": "$gasLat,$gasLng"});
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.navigate_next))
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Style().textBlackSize("รัศมีเริมต้น", 14)
                            ],
                          ),
                          Row(
                            children: [
                              Style().textBlackSize(
                                  gasSetupModel.startDistancs + " กม.", 16),
                              IconButton(
                                  onPressed: () async {
                                    var _result = await inputDialog(
                                        context,
                                        "รัศมีเริมต้น",
                                        "รัศมีเริมต้น",
                                        gasSetupModel.startDistancs,
                                        "number");
                                    if (_result[0]) {
                                      setState(() {
                                        loading = true;
                                      });
                                      gasSetupModel.startDistancs = _result[1];

                                      await dbUpdate(
                                          "updatemartConfig",
                                          "gasSetup",
                                          "001",
                                          {"startDistancs": _result[1]});
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.navigate_next))
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Style()
                                  .textBlackSize("ระยะทางให้บริการสูงสุด", 14)
                            ],
                          ),
                          Row(
                            children: [
                              Style().textBlackSize(
                                  gasSetupModel.maxDistancs + " กม.", 16),
                              IconButton(
                                  onPressed: () async {
                                    var _result = await inputDialog(
                                        context,
                                        "ระยะทาง",
                                        "ระยะทาง",
                                        gasSetupModel.maxDistancs,
                                        "number");
                                    if (_result[0]) {
                                      setState(() {
                                        loading = true;
                                      });
                                      gasSetupModel.maxDistancs = _result[1];

                                      await dbUpdate(
                                          "updatemartConfig",
                                          "gasSetup",
                                          "001",
                                          {"maxDistancs": _result[1]});
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.navigate_next))
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Style().textBlackSize(
                                  "ค่าบริการเริ่มต้น(ถังเล็ก)", 14)
                            ],
                          ),
                          Row(
                            children: [
                              Style().textBlackSize(
                                  "฿ " + gasSetupModel.costServiceSmallStartl,
                                  16),
                              IconButton(
                                  onPressed: () async {
                                    var _result = await inputDialog(
                                        context,
                                        "ค่าบริการเริ่มต้น",
                                        "ค่าบริการเริ่มต้น",
                                        gasSetupModel.costServiceSmallStartl,
                                        "number");
                                    if (_result[0]) {
                                      setState(() {
                                        loading = true;
                                      });
                                      gasSetupModel.costServiceSmallStartl =
                                          _result[1];

                                      await dbUpdate("updatemartConfig",
                                          "gasSetup", "001", {
                                        "costServiceSmallStartl": _result[1]
                                      });
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.navigate_next))
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Style().textBlackSize(
                                  "ค่าบริการเริ่มต้น(ถังใหญ่)", 14)
                            ],
                          ),
                          Row(
                            children: [
                              Style().textBlackSize(
                                  "฿ " + gasSetupModel.costServiceBigStart, 16),
                              IconButton(
                                  onPressed: () async {
                                    var _result = await inputDialog(
                                        context,
                                        "ค่าบริการเริ่มต้น",
                                        "ค่าบริการเริ่มต้น",
                                        gasSetupModel.costServiceBigStart,
                                        "number");
                                    if (_result[0]) {
                                      setState(() {
                                        loading = true;
                                      });
                                      gasSetupModel.costServiceBigStart =
                                          _result[1];

                                      await dbUpdate(
                                          "updatemartConfig",
                                          "gasSetup",
                                          "001",
                                          {"costServiceBigStart": _result[1]});
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.navigate_next))
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Style().textBlackSize("ค่าบริการ/กม.", 14)
                            ],
                          ),
                          Row(
                            children: [
                              Style().textBlackSize(
                                  "฿ " + gasSetupModel.costPerKm, 16),
                              IconButton(
                                  onPressed: () async {
                                    var _result = await inputDialog(
                                        context,
                                        "ค่าบริการ/กม.",
                                        "ค่าบริการ/กม.",
                                        gasSetupModel.costPerKm,
                                        "number");
                                    if (_result[0]) {
                                      setState(() {
                                        loading = true;
                                      });
                                      gasSetupModel.costPerKm = _result[1];

                                      await dbUpdate(
                                          "updatemartConfig",
                                          "gasSetup",
                                          "001",
                                          {"costPerKm": _result[1]});
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.navigate_next))
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [Style().textBlackSize("% ค่าส่ง", 14)],
                          ),
                          Row(
                            children: [
                              Style().textBlackSize(
                                  gasSetupModel.shareForApp + " %", 16),
                              IconButton(
                                  onPressed: () async {
                                    var _result = await inputDialog(
                                        context,
                                        "% ค่าส่ง",
                                        "% ค่าส่ง",
                                        gasSetupModel.shareForApp,
                                        "number");
                                    if (_result[0]) {
                                      setState(() {
                                        loading = true;
                                      });
                                      gasSetupModel.shareForApp = _result[1];

                                      await dbUpdate(
                                          "updatemartConfig",
                                          "gasSetup",
                                          "001",
                                          {"shareForApp": _result[1]});
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.navigate_next))
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  inputDialog(BuildContext context, String title, String hinText, value, type) {
    _value.text = "";
    if (value != "") {
      _value.text = value;
    }

    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Style().textBlackSize(title, 16),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  TextField(
                    keyboardType: (type == "text")
                        ? TextInputType.text
                        : TextInputType.number,
                    decoration: InputDecoration(
                        hintText: hinText,
                        hintStyle:
                            TextStyle(fontFamily: 'Prompt', fontSize: 14)),
                    controller: _value,
                  )
                ],
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context, [false, 'Prompt']);
                  },
                  child: Text('ยกเลิก')),
              FlatButton(
                  onPressed: () {
                    if (_value.text.length > 0) {
                      Navigator.pop(context, [true, _value.text]);
                    } else {
                      Fluttertoast.showToast(
                          msg: "โปรดกรอกข้อมูล",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  },
                  child: Text('ตกลง'))
            ],
          );
        });
  }
}
