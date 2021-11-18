import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/locationSetupModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/checkLocation.dart';
import 'package:hro/utility/dialog.dart';
import 'package:hro/utility/getAddressName.dart';
import 'package:hro/utility/notifySend.dart';
import 'package:hro/utility/style.dart';
import 'package:hro/utility/updateToken.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:time_range_picker/time_range_picker.dart';

class EditShopPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EditShopState();
  }
}

class EditShopState extends State<EditShopPage> {
  Dialogs dialogs = Dialogs();
  File file;
  final picker = ImagePicker();
  bool adding = false;
  String _distanceService;
  LocationSetupModel locationSetupModel;
  ShopModel shopModel;
  FirebaseFirestore db = FirebaseFirestore.instance;

  String shopName,
      shopType,
      shopPhone,
      shopAddress,
      shopLocation,
      shopTime,
      shopPhotoUrl,
      shopStatus;
  List<String> daysName = [
    'จันทร์',
    'อังคาร',
    'พุธ',
    'พฤหัสบดี',
    'ศุกร์',
    'เสาร์',
    'อาทิตย์'
  ];
  List<bool> days = [true, true, true, true, true, true, true];
  List<String> open = ['8:00', '8:00', '8:00', '8:00', '8:00', '8:00', '8:00'];
  List<String> close = [
    '20:00',
    '20:00',
    '20:00',
    '20:00',
    '20:00',
    '20:00',
    '20:00'
  ];

  bool check = false;
  bool getShopDataStatus = false;
  ShopModel shopData;
  double lat, lng;
  String addressName;

  Future<Null> _getLocation(AppDataModel appDataModel) async {
    await db
        .collection("shops")
        .doc(appDataModel.userOneModel.uid)
        .get()
        .then((value) async {
      var jsonData = jsonEncode(value.data());
      shopModel = shopModelFromJson(jsonData);

      shopName = shopModel.shopName;
      shopPhotoUrl = shopModel.shopPhotoUrl;
      shopType = shopModel.shopType;
      shopPhone = shopModel.shopPhone;
      shopAddress = shopModel.shopAddress;
      shopLocation = shopModel.shopLocation;
      shopTime = shopModel.shopTime;
      shopStatus = shopModel.shopStatus;
      _distanceService = shopModel.shopDistanceService;

      print("shoptime = " + shopModel.shopTime);

      List<String> dateFull = shopTime.split(",");
      for (int i = 0; i < 7; i++) {
        List<String> statusTime = dateFull[i].split("/");
        (statusTime[0] == "open") ? days[i] = true : days[i] = false;
        List<String> openClose = statusTime[1].split('-');
        open[i] = openClose[0];
        close[i] = openClose[1];
      }

      locationSetupModel = appDataModel.locationSetupModel;
      List<String> _location = shopLocation.split(",");

      lat = double.parse(_location[0]);
      lng = double.parse(_location[1]);

      addressName = await getAddressName(lat, lng);

      shopLocation = '$lat,$lng';
      print('address = $addressName');

      setState(() {
        lat = double.parse(_location[0]);
        lng = double.parse(_location[1]);
        print('location = $lat,$lng');
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getLocation(context.read<AppDataModel>());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: AppBar(
                title: Style().textBlackSize("ข้อมูลร้านค้า", 14),
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
                actions: [
                  Container(
                    child: (lat == null || adding == true || shopModel == null)
                        ? Container()
                        : Container(
                            margin: EdgeInsets.only(right: 10),
                            width: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (shopTime?.isEmpty ?? true)
                                      shopTime =
                                          'open/8:0-21:20,open/8:00-20:00,open/8:00-20:00,open/8:00-20:00,open/8:00-20:00,open/8:00-20:00,open/8:0-6:45';
                                    if ((shopName?.isEmpty ?? true) ||
                                        (shopType?.isEmpty ?? true) ||
                                        (shopPhone?.isEmpty ?? true) ||
                                        (shopAddress?.isEmpty ?? true) ||
                                        (shopLocation?.isEmpty ?? true) ||
                                        (shopTime?.isEmpty ?? true)) {
                                      normalDialog(context, 'ข้อมูลไม่ครบ',
                                          'โปรดกรอกข้อมูลให้ครบทุกช่อง');
                                    } else {
                                      _saveShopData(
                                          context.read<AppDataModel>());
                                    }
                                  },
                                  child: Style().textSizeColor(
                                      'บันทึก', 14, Colors.white),
                                  style: ElevatedButton.styleFrom(
                                      primary: Style().darkColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5))),
                                ),
                              ],
                            ),
                          ),
                  )
                ],
              ),
              body: Container(
                child: Center(
                  child: (lat == null || adding == true)
                      ? Style().loading()
                      : ListView(
                          children: [
                            Column(
                              children: [
                                Container(
                                  height: 150,
                                  width: appDataModel.screenW,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      fit: BoxFit.fitWidth,
                                      image: (file == null)
                                          ? (shopPhotoUrl?.isEmpty ?? true)
                                              ? AssetImage(
                                                  'assets/images/shop-icon.png')
                                              : NetworkImage(shopPhotoUrl)
                                          : FileImage(file),
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () async {
                                      var result =
                                          await dialogs.photoSelect(context);
                                      if (result == false) {
                                        chooseImage(ImageSource.camera);
                                      } else if (result == true) {
                                        chooseImage(ImageSource.gallery);
                                      }
                                    },
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 12.0,
                                        child: Icon(
                                          Icons.camera_enhance,
                                          size: 15.0,
                                          color: Color(0xFF404040),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                ),
                                buildShopDetail(context.read<AppDataModel>()),

                                // buildUser(context.read<AppDataModel>()),
                                // buildPhone(context.read<AppDataModel>()),
                                // buildEmail(context.read<AppDataModel>()),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ));
  }

  _saveShopData(AppDataModel appDataModel) async {
    var resule = await dialogs.confirm(
        context, 'แก้ไขข้อมูล', "ยืนยันการแก้ไขข้อมูลร้านค้า");

    if (resule) {
      setState(() {
        adding = true;
      });
      await _calTimeSave();
      if (file != null) {
        Random random = Random();
        int i = random.nextInt(100000);
        final _firebaseStorage = FirebaseStorage.instance;
        var snapshot = await _firebaseStorage
            .ref()
            .child('/shopPhoto/shop$i.jpg')
            .putFile(file);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        shopPhotoUrl = downloadUrl;
        print(shopPhotoUrl);
      }
      if (shopTime?.isEmpty ?? true)
        shopTime =
            'open/8:0-21:20,open/8:00-20:00,open/8:00-20:00,open/8:00-20:00,open/8:00-20:00,open/8:00-20:00,open/8:0-6:45';
      if (shopPhotoUrl != null) {
        ShopModel model = ShopModel(
            shopUid: appDataModel.userOneModel.uid,
            shopName: shopName,
            shopPhotoUrl: shopPhotoUrl,
            shopType: shopType,
            shopPhone: shopPhone,
            shopAddress: shopAddress,
            shopLocation: '$lat,$lng',
            shopTime: shopTime,
            shopDistanceService: _distanceService,
            token: appDataModel.userOneModel.token,
            shopStatus: "3");
        Map<String, dynamic> data = model.toJson();
        await FirebaseFirestore.instance
            .collection('shops')
            .doc(appDataModel.userOneModel.uid)
            .update(data)
            .then((value) async {
          await updateToken(appDataModel.profileUid, appDataModel.token);
          print('update complete');
          await notifySend(
              appDataModel.adminToken, "แก้ไข", "ร้าน " + shopName + " สำเร็จ");
          await dialogs.information(
              context,
              Style().textSizeColor('สำเร็จ', 14, Style().textColor),
              Style().textSizeColor(
                  'บีนทึกข้อมูลร้านเรียบร้อยแล้ว', 12, Style().textColor));
          Navigator.pop(context);
        }).catchError((onError) {
          normalDialog(context, 'ผิดพลาด', 'โปรดลองใหม่อีกครั้ง');
          setState(() {
            adding = false;
          });
        });
      }
    }
  }

  _calTimeSave() {
    String timeSave = "";
    daysName.map((e) {
      int index = daysName.indexOf(e);

      String status = 'close';
      (days[index] == true) ? status = 'open' : status = 'close';
      timeSave += status + "/" + open[index] + "-" + close[index] + ',';
    }).toList();
    shopTime = timeSave;
  }

  Container buildShopDetail(AppDataModel appDataModel) {
    return Container(
        width: appDataModel.screenW * 0.9,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Style().textSizeColor('ชื่อร้าน', 12, Style().textColor),
                    (shopName == null)
                        ? Container()
                        : Style().textSizeColor(shopName, 16, Style().textColor)
                  ],
                ),
                IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () async {
                      var shopNewNameList = await dialogs.inputDialog(
                          context,
                          Style()
                              .textSizeColor('ชื่อร้าน', 14, Style().textColor),
                          'กรอกชื่อร้าน');
                      var shopNewName;
                      if (shopNewNameList[0] == true)
                        shopNewName = shopNewNameList[1].toString();

                      if (shopNewName != null && shopNewName != 'cancel') {
                        print('shopName ' + shopNewName);
                        setState(() {
                          shopName = shopNewName;
                        });
                      }
                    }),
              ],
            ),
            Container(
                margin: EdgeInsets.all(1),
                child: Divider(
                  color: Colors.grey,
                  height: 0,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Style()
                        .textSizeColor('ประเภทสินค้า', 12, Style().textColor),
                    (shopType == null)
                        ? Container()
                        : Style().textSizeColor(shopType, 16, Style().textColor)
                  ],
                ),
                IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () async {
                      var shopTypeNewList = await dialogs.inputDialog(
                          context,
                          Style().textSizeColor(
                              'ประเถทสินค้า', 14, Style().textColor),
                          'เช่น ตามสั่ง,ยำ,ก๋วยเตียว,เครื่องดื่ม');
                      var ShopTypeNew;
                      if (shopTypeNewList[0] == true)
                        ShopTypeNew = shopTypeNewList[1];
                      if (ShopTypeNew != null && ShopTypeNew != 'cancel') {
                        print('shopName ' + ShopTypeNew);
                        setState(() {
                          shopType = ShopTypeNew;
                        });
                      }
                    }),
              ],
            ),
            Container(
                margin: EdgeInsets.all(1),
                child: Divider(
                  color: Colors.grey,
                  height: 0,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Style().textSizeColor('เบอร์โทร', 12, Style().textColor),
                    (shopPhone == null)
                        ? Container()
                        : Style()
                            .textSizeColor(shopPhone, 16, Style().textColor)
                  ],
                ),
                IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () async {
                      String shopNewPhone = await dialogs.inputPhoneDialog(
                          context,
                          Style().textSizeColor(
                              'หมายเลขโทรศัพท์', 14, Style().textColor),
                          'กรอกหมายเลขโทรศัพท 10หลัก');
                      if (shopNewPhone != null && shopNewPhone != 'cancel') {
                        setState(() {
                          shopPhone = shopNewPhone;
                        });
                      }
                    }),
              ],
            ),
            Container(
                margin: EdgeInsets.all(1),
                child: Divider(
                  color: Colors.grey,
                  height: 0,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Style()
                        .textSizeColor('เวลา เปิด-ปิด', 16, Style().textColor),
                  ],
                ),
                IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () {
                      _timeOpenDialog(Style().textSizeColor(
                          'ระบบเวลา เปิด-ปิด ร้าน', 14, Style().textColor));
                    }),
              ],
            ),
            Container(
                margin: EdgeInsets.all(1),
                child: Divider(
                  color: Colors.grey,
                  height: 0,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Style().textSizeColor('ที่ตั้ง', 12, Style().textColor),
                    (shopAddress == null)
                        ? Container()
                        : Style()
                            .textSizeColor(shopAddress, 16, Style().textColor)
                  ],
                ),
                IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () async {
                      var ShopAddressNewList = await dialogs.inputDialog(
                          context,
                          Style().textSizeColor('ที่ตั้งร้าน *ระบุให้ชัดเจน',
                              14, Style().textColor),
                          'เช่น ข้างคิวรถฝั่งขวา,ตรงข้าม ธ.ออมสิน');
                      var ShopAddressNew;
                      if (ShopAddressNewList[0] == true)
                        ShopAddressNew = ShopAddressNewList[1];
                      print('shopName ' + ShopAddressNew);
                      if (ShopAddressNew != null &&
                          ShopAddressNew != 'cancel') {
                        setState(() {
                          shopAddress = ShopAddressNew;
                        });
                      }
                    }),
              ],
            ),
            Container(
                margin: EdgeInsets.all(1),
                child: Divider(
                  color: Colors.grey,
                  height: 0,
                )),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Style().textBlackSize("ระยะให้บริการ", 14),
              _selectDistanceService()
            ]),
            Container(
                margin: EdgeInsets.all(1),
                child: Divider(
                  color: Colors.grey,
                  height: 0,
                )),
            (lat == null || lng == null)
                ? Center(
                    child: Style().circularProgressIndicator(Style().darkColor),
                  )
                : Container(
                    margin: EdgeInsets.only(left: 0, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Style().textBlackSize("ตำแหน่งร้านค้า", 14),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Style().darkColor,
                              size: 14,
                            ),
                            (addressName == null)
                                ? Style()
                                    .textBlackSize("ระบุตำแหน่งร้านค้า", 14)
                                : Container(
                                    width: appDataModel.screenW * 0.7,
                                    child:
                                        Style().textBlackSize(addressName, 12)),
                            InkWell(
                              onTap: () async {
                                appDataModel.userLat = lat;
                                appDataModel.userLng = lng;

                                var result = await Navigator.pushNamed(
                                    context, "/googleMap-page");

                                if (result != null) {
                                  List locationResuleNew = result;

                                  lat = locationResuleNew[0];
                                  lng = locationResuleNew[1];

                                  addressName = await getAddressName(lat, lng);
                                }
                                setState(() {});

                                // appDataModel.userLat = lat;
                                // appDataModel.userLng = lng;

                                // var result = await Navigator.pushNamed(
                                //     context, "/googleMap-page");
                                // if (result != null) {
                                //   List latlngNew = result;
                                //   lat = latlngNew[0];
                                //   lng = latlngNew[1];

                                //   addressName = await getAddressName(lat, lng);

                                //   setState(() {});
                                // }
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
                  ),
          ],
        ));
  }

  Future<void> chooseImage(ImageSource imageSource) async {
    final XFile pickedFile = await picker.pickImage(
        source: imageSource, maxWidth: 800, maxHeight: 800);
    print("pickedFile" + pickedFile.toString());
    setState(() {
      if (pickedFile != null) {
        file = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _timeOpenDialog(Text title) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: title,
              content: Container(
                height: 350,
                child: Column(
                  children: daysName.map((e) {
                    int index = daysName.indexOf(e);
                    List<String> openList = open[index].split(":");
                    List<String> closeList = close[index].split(":");
                    return Row(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 45,
                              child: Style().textSizeColor(
                                  daysName[index], 12, Style().textColor),
                            ),
                            Checkbox(
                                value: days[index],
                                onChanged: (value) {
                                  setState(() {
                                    days[index] = value;
                                    print(days[index]);
                                  });
                                }),
                          ],
                        ),
                        (days[index] == true)
                            ? Row(
                                children: [
                                  Style().textSizeColor(
                                      'เปิด ', 10, Style().textColor),
                                  Style().textSizeColor(
                                      open[index], 12, Style().shopDarkColor),
                                  Style().textSizeColor(
                                      '/ ปิด ', 10, Style().textColor),
                                  Style().textSizeColor(
                                      close[index], 12, Style().shopDarkColor),
                                  IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        TimeRange result =
                                            await showTimeRangePicker(
                                          context: context,
                                          fromText: 'เวลาเปิด',
                                          toText: 'เวลาปิด',
                                          paintingStyle: PaintingStyle.fill,
                                          start: TimeOfDay(
                                              hour: (int.parse(openList[0])),
                                              minute: (int.parse(openList[1]))),
                                          end: TimeOfDay(
                                              hour: (int.parse(closeList[0])),
                                              minute:
                                                  (int.parse(closeList[1]))),
                                          disabledTime: TimeRange(
                                              startTime: TimeOfDay(
                                                  hour: 23, minute: 55),
                                              endTime: TimeOfDay(
                                                  hour: 00, minute: 5)),
                                          disabledColor:
                                              Colors.red.withOpacity(0.5),
                                        );
                                        setState(() {
                                          print("timeResult = $result");
                                          if (result != null) {
                                            open[index] = result.startTime.hour
                                                    .toString() +
                                                ":" +
                                                result.startTime.minute
                                                    .toString();
                                            close[index] =
                                                result.endTime.hour.toString() +
                                                    ":" +
                                                    result.endTime.minute
                                                        .toString();
                                            shopTime = result.endTime.minute
                                                .toString();
                                          }
                                        });
                                      })
                                ],
                              )
                            : Row(
                                children: [Text('')],
                              )
                      ],
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('ยกเลิก'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text('ตกลง'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
        });
  }

  _selectDistanceService() {
    List<String> genItem = [];
    int limit = int.parse(locationSetupModel.distanceMax);

    for (int i = 0; i < limit; i++) {
      genItem.add((i + 1).toString());
    }

    return DropdownButton<String>(
      focusColor: Colors.white,
      value: _distanceService,
      //elevation: 5,
      style: TextStyle(color: Colors.white),
      iconEnabledColor: Colors.black,

      items: genItem.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value + " กิโลเมตร",
            style: TextStyle(color: Colors.black, fontFamily: 'Prompt'),
          ),
        );
      }).toList(),
      hint: Text(
        "โปรดเลือก",
        style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Prompt'),
      ),
      onChanged: (String value) {
        print(value);
        setState(() {
          _distanceService = value;
        });
      },
    );
  }
}
