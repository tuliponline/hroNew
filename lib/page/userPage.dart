import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/UserOneModel.dart';
import 'package:hro/model/contactmodel.dart';
import 'package:hro/page/fireBaseFunctions.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/checkHaveShopAndRider.dart';
import 'package:hro/utility/checkVersion.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserState();
  }
}

class UserState extends State<UserPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Dialogs dialogs = Dialogs();
  final GoogleSignIn googleSignIn = GoogleSignIn();

  double screenW;
  bool haveShop = true;
  bool haveRider = true;
  UserOneModel userOneModel;
  String loginPrivider;

  bool showShopAndDriver = false;
  double screeW;

  String appVersion;

  ContactModel contactModel;

  _checkHaveShop(AppDataModel appDataModel) async {
    var _contactDb = await dbGetDataOne("getContact", "contactUs", "001");
    if (_contactDb[0]) {
      contactModel = contactModelFromJson(_contactDb[1]);
    }
    appVersion = await checkAppVersion();

    var _userDB =
        await dbGetDataOne("getUser", "users", appDataModel.userOneModel.uid);
    if (_userDB[0]) {
      appDataModel.userOneModel = userOneModelFromJson(_userDB[1]);
    }

    screeW = appDataModel.screenW;
    print("appDataModel.screenW = " + appDataModel.screenW.toString());
    loginPrivider = appDataModel.loginProvider;
    screenW = appDataModel.screenW;
    userOneModel = appDataModel.userOneModel;
    haveShop = await checkHaveShop(appDataModel.userOneModel.uid);
    haveRider = await checkHaveRider(appDataModel.userOneModel.uid);
    print("haveShop $haveShop");
    print("haveRider $haveRider");
    //haveShop = true;
    //haveRider = true;
    setState(() {});
  }

  _realTimeDB(AppDataModel appDataModel) async {
    db
        .collection("users")
        .doc(appDataModel.userOneModel.uid)
        .snapshots()
        .listen((event) async {
      _checkHaveShop(context.read<AppDataModel>());
    });
  }

  @override
  void initState() {
    super.initState();
    _checkHaveShop(context.read<AppDataModel>());
    _realTimeDB(context.read<AppDataModel>());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              backgroundColor: Colors.grey.shade100,
              body: (userOneModel == null)
                  ? Style().loading()
                  : SafeArea(
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                  margin: EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Style().textBlackSize(
                                              '????????????????????? ????????? Rider', 14),
                                          IconButton(
                                              onPressed: () {
                                                if (showShopAndDriver) {
                                                  showShopAndDriver = false;
                                                } else {
                                                  showShopAndDriver = true;
                                                }
                                                setState(() {});
                                              },
                                              icon: (showShopAndDriver
                                                  ? Icon(Icons.arrow_drop_up)
                                                  : Icon(
                                                      Icons.arrow_drop_down)))
                                        ],
                                      ),
                                      (showShopAndDriver)
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                haveShop == false
                                                    ? topmenuShop()
                                                    : Container(),
                                                haveRider == false
                                                    ? topmenuRider()
                                                    : Container()
                                              ],
                                            )
                                          : Container()
                                    ],
                                  )),
                              _showProfile(),
                              // _showOrderMenu(),
                              _showWallet(), _buildContactUs(),
                              Container(
                                margin: EdgeInsets.all(8),
                                child: Style().textBlackSize(
                                    "??????????????????????????????????????????????????? $appVersion", 14),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: screenW * 0.9,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          var resule = await dialogs.confirm(
                                            context,
                                            "??????????????????????????????",
                                            "?????????????????????????????????????????????????????????",
                                          );
                                          if (resule) {
                                            await FirebaseAuth.instance
                                                .signOut();
                                            await googleSignIn.signOut();
                                            Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                '/first-page',
                                                (route) => false);
                                          }
                                        },
                                        child: Style().textSizeColor(
                                            "??????????????????????????????", 16, Colors.white),
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.red),
                                            textStyle:
                                                MaterialStateProperty.all(
                                                    TextStyle(fontSize: 30))),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
            ));
  }

  _showProfile() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black12,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: userOneModel.photoUrl == null
                          ? CircleAvatar(
                              radius: 40.0,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  AssetImage('assets/images/person-icon.png'))
                          : CachedNetworkImage(
                              key: UniqueKey(),
                              imageUrl: userOneModel.photoUrl,
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

                      // FadeInImage.assetNetwork(
                      //   fit: BoxFit.fitHeight,
                      //   placeholder:
                      //       'assets/images/loading.gif',
                      //   image: ranProductModel[index]
                      //       .productPhotoUrl,
                      // ),
                    )),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: screeW * 0.4,
                          child: Style().textBlackSize(userOneModel.name, 16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.phone,
                            color: Style().darkColor,
                            size: 15,
                          ),
                          userOneModel.phone == null
                              ? Style()
                                  .textSizeColor(" ?????????????????????", 12, Colors.red)
                              : Style().textBlackSize(userOneModel.phone, 12),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/profile-page');
              _checkHaveShop(context.read<AppDataModel>());
            },
            icon: Icon(Icons.edit, size: 30, color: Colors.red),
          )
        ],
      ),
    );
  }

  _showOrderMenu() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                FontAwesomeIcons.clipboard,
                size: 20,
              ),
              Style().textBlackSize(" ??????????????????????????????????????????", 14),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        FontAwesomeIcons.clock,
                        color: Colors.yellow.shade700,
                        size: 35,
                      )),
                  Style().textBlackSize("????????????????????????????????????????????????????????????", 10)
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        FontAwesomeIcons.checkCircle,
                        color: Colors.green,
                        size: 35,
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Style().textBlackSize("????????????????????????????????????", 10),
                    ],
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        FontAwesomeIcons.timesCircle,
                        color: Colors.red,
                        size: 35,
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Style().textBlackSize("??????????????????/???????????????????????????", 10),
                    ],
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  _showWallet() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, "/creditTransection-page");
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              FontAwesomeIcons.wallet,
                              color: Colors.orange,
                              size: 20,
                            )),
                        Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Style().textBlackSize("??????????????????", 14))
                      ],
                    ),
                    Row(
                      children: [
                        Style().textBlackSize("??? " + userOneModel.credit, 16),
                        Icon(Icons.navigate_next)
                      ],
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            FontAwesomeIcons.coins,
                            color: Colors.yellow.shade700,
                            size: 20,
                          )),
                      Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Style().textBlackSize("????????????", 14))
                    ],
                  ),
                  Style().textBlackSize(userOneModel.potin, 16)
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  topmenuShop() {
    return haveShop == true
        ? Container()
        : InkWell(
            onTap: () {
              print("Add Shop");
              Navigator.pushNamed(context, '/addShop-Page');
            },
            child: new Container(
                width: screenW / 2.5,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Style().bottomBlue,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.store, size: 20, color: Colors.white),
                      Style().textSizeColor("?????????????????????????????????????????????", 14, Colors.white)
                    ])),
          );
  }

  topmenuRider() {
    return haveRider == true
        ? Container()
        : InkWell(
            onTap: () {
              print("tap Rider");
              Navigator.pushNamed(context, '/addRider-Page', arguments: "NEW");
            },
            child: new Container(
                width: screenW / 2.5,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Style().bottomPink,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.motorcycle, size: 20, color: Colors.white),
                      Style().textSizeColor("??????????????? Rider", 14, Colors.white)
                    ])),
          );
  }

  _buildContactUs() {
    return (contactModel == null)
        ? Container()
        : Container(
            margin: EdgeInsets.only(top: 5),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Style().textBlackSize("???????????????????????????", 16)],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Icon(
                          FontAwesomeIcons.phoneSquare,
                          color: Colors.blue,
                        ),
                        (contactModel.phone == "0")
                            ? Text("")
                            : Style().textBlackSize(contactModel.phone, 14)
                      ],
                    ),
                    Column(
                      children: [
                        Icon(
                          FontAwesomeIcons.line,
                          color: Colors.green,
                        ),
                        (contactModel.line == "0")
                            ? Text("")
                            : Style().textBlackSize(contactModel.line, 14)
                      ],
                    ),
                  ],
                )
              ],
            ),
          );
  }
}
