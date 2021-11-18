import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/UserOneModel.dart';

import 'package:hro/utility/checkTokenMsg.dart';

import 'package:hro/utility/regexText.dart';
import 'package:hro/utility/style.dart';

import 'package:provider/provider.dart';

import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class FirstPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FirstState();
  }
}

class FirstState extends State<FirstPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final TheAppleSignIn appleSignIn = TheAppleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  bool checkSystemStatus = false;
  bool locationStatus = false;
  bool versionStatus = false;

  bool locationPermission = false;
  bool locationServiceEnabled = false;

  var _email = TextEditingController(), _password = TextEditingController();
  String _userName;
  _getOs(AppDataModel appDataModel) async {
    if (Platform.isAndroid) {
      appDataModel.os = "android";
      print("OS = " + appDataModel.os);
    } else if (Platform.isIOS) {
      appDataModel.os = "ios";
      print("OS = " + appDataModel.os);
    }
  }

  // _checkLocation(AppDataModel appDataModel) async {
  //   appDataModel.screenW = MediaQuery.of(context).size.width;
  //   locationServiceEnabled = await checkLocationService();
  //   if (locationServiceEnabled) {
  //     locationPermission = await checkLocationSPermission();
  //   } else {
  //     AwesomeDialog(
  //       context: context,
  //       dialogType: DialogType.WARNING,
  //       body: Center(
  //         child: Padding(
  //           padding: const EdgeInsets.only(top: 15),
  //           child: Style().textBlackSize('ตั้งค่า และเปิดตำแแหน่งของคุณ', 14),
  //         ),
  //       ),
  //       title: 'This is Ignored',
  //       desc: 'This is also Ignored',
  //       btnOkText: "ตั้งค่า",
  //       buttonsTextStyle: TextStyle(
  //         fontSize: 14,
  //         fontFamily: 'Prompt',
  //         color: Colors.blueAccent,
  //       ),
  //       btnOkColor: Colors.white,
  //       btnOkOnPress: () async {
  //         (appDataModel.os == "ios")
  //             ? AppSettings.openSecuritySettings()
  //             : await Geolocator.openLocationSettings();
  //         exit(0);
  //       },
  //     )..show();
  //   }
  //   if (locationServiceEnabled && locationPermission) {
  //     Position position = await checkLocationPosition();
  //     appDataModel.userLat = position.latitude;
  //     appDataModel.userLng = position.longitude;
  //     locationStatus = true;
  //     appDataModel.locationStatus = locationStatus;
  //     await _checkVersion(context.read<AppDataModel>());

  //     _checkLogin(context.read<AppDataModel>());
  //   } else {
  //     appDataModel.userLat = 13.758576654702438;
  //     appDataModel.userLng = 100.49302608352504;
  //     locationStatus = false;
  //     appDataModel.locationStatus = locationStatus;
  //     checkSystemStatus = true;
  //     await _checkVersion(context.read<AppDataModel>());

  //     _checkLogin(context.read<AppDataModel>());
  //     setState(() {});
  //   }
  //   print(locationServiceEnabled);
  //   print(locationPermission);
  // }

  // _checkVersion(AppDataModel appDataModel) async {
  //   await db.collection('appstatus').doc('001').get().then((value) async {
  //     appDataModel.appConfigModel =
  //         appConfigModelFromJson(jsonEncode(value.data()));
  //     print("Server Version = " + appDataModel.appConfigModel.projectVersion);
  //     versionStatus = true;
  //     // double appVersion = await checkAppVersion();
  //     // double serverVersion =
  //     //     double.parse(appDataModel.appConfigModel.projectVersion);
  //     // if (appVersion < serverVersion) {
  //     //   AwesomeDialog(
  //     //       context: context,
  //     //       dialogType: DialogType.WARNING,
  //     //       body: Center(
  //     //         child: Padding(
  //     //           padding: const EdgeInsets.only(top: 15),
  //     //           child: Style().textBlackSize('โปรดอัพเดทเวอร์ชั่นแอพ', 14),
  //     //         ),
  //     //       ),
  //     //       title: 'This is Ignored',
  //     //       desc: 'This is also Ignored',
  //     //       btnOkText: "ตกลง",
  //     //       buttonsTextStyle: TextStyle(
  //     //         fontSize: 14,
  //     //         fontFamily: 'Prompt',
  //     //         color: Colors.blueAccent,
  //     //       ),
  //     //       btnOkColor: Colors.white,
  //     //       btnOkOnPress: () async {
  //     //         if (appDataModel.os == 'android') {
  //     //           _launchURL(appDataModel.playStoreUrl);
  //     //         }else{
  //     //           _checkLocation(context.read<AppDataModel>());
  //     //         }
  //     //       });
  //     // }
  //   }).catchError((onError) => print(onError));
  // }

  // _launchURL(String url) async {
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  _checkLogin(AppDataModel appDataModel) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;

    if (user != null) {
      print("UserId= " + user.uid);
      String token = await checkTokenMsg();
      print("token = $token");
      print("uid _checkLogin= " + user.uid);

      _userName = user.displayName;
      (user.displayName == null)
          ? _userName = user.email
          : _userName = user.displayName;

      await db.collection('users').doc(user.uid).get().then((value) async {
        appDataModel.userOneModel =
            userOneModelFromJson(jsonEncode(value.data()));

        appDataModel.loginStatus = true;
        appDataModel.screenW = MediaQuery.of(context).size.width;

        if (appDataModel.userOneModel.name == null) {
          print("Not have User Update checklogin");
          if (appDataModel.profilePhotoUrl == null) {
            appDataModel.profilePhotoUrl =
                "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png";
          }
          UserOneModel model = UserOneModel(
            uid: user.uid,
            name: _userName,
            phone: user.phoneNumber,
            email: user.email,
            photoUrl: appDataModel.profilePhotoUrl,
            location: appDataModel.userLat.toString() +
                ',' +
                appDataModel.userLng.toString(),
            token: token,
            potin: "0",
            credit: "0",
            status: '2',
          );
          Map<String, dynamic> data = model.toJson();
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update(data)
              .then((value) {
            appDataModel.userOneModel = model;
            print('addNewUser complete =' + appDataModel.userOneModel.name);
          });
        }
        appDataModel.screenW = MediaQuery.of(context).size.width;
        Navigator.pushNamedAndRemoveUntil(
            context, '/showHome-page', (route) => false);
      }).catchError((onError) async {
        print("error2 $onError");

        if (appDataModel.profilePhotoUrl == null) {
          appDataModel.profilePhotoUrl =
              "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png";
        }
        UserOneModel model = UserOneModel(
          uid: user.uid,
          name: _userName,
          phone: user.phoneNumber,
          email: user.email,
          photoUrl: appDataModel.profilePhotoUrl,
          location: appDataModel.userLat.toString() +
              ',' +
              appDataModel.userLng.toString(),
          token: token,
          potin: "0",
          credit: "0",
          status: '2',
        );
        Map<String, dynamic> data = model.toJson();
        await db.collection('users').doc(user.uid).set(data).then((value) {
          appDataModel.userOneModel = model;
        });
        appDataModel.screenW = MediaQuery.of(context).size.width;
        Navigator.pushNamedAndRemoveUntil(
            context, '/showHome-page', (route) => false);
        // _auth.signOut();
      });
    } else {
      appDataModel.screenW = MediaQuery.of(context).size.width;
      print("nonlogin");
      appDataModel.loginStatus = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        appDataModel.screenW = MediaQuery.of(context).size.width;
        Navigator.pushNamed(context, "/home-page");
      });

      setState(() {
        checkSystemStatus = true;
      });
    }
  }

  Future<Null> signInWithGoogle(AppDataModel appDataModel) async {
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    var authResult = await _auth.signInWithCredential(credential);
    if (authResult != null) {
      print("login Pass");
      appDataModel.profileEmail = authResult.user.email;
      appDataModel.profileName = authResult.user.displayName;
      appDataModel.profileUid = authResult.user.uid;
      appDataModel.profilePhotoUrl = authResult.user.photoURL;
      appDataModel.profilePhone = authResult.user.phoneNumber;
      appDataModel.profileEmailVerify = authResult.user.emailVerified;
      appDataModel.loginProvider = 'google';

      _userName = authResult.user.displayName;
      if (authResult.user.displayName == null) {
        _userName = authResult.user.email;
      }
      print("google Login");
      _checkHaveUser(context.read<AppDataModel>());
    } else {
      Fluttertoast.showToast(
          msg: "เข้าสู่ระบบไม่สำเร็จ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<Null> signInWithApple(AppDataModel appDataModel) async {
    if (await TheAppleSignIn.isAvailable()) {
      final AuthorizationResult result = await TheAppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);
      AuthCredential credential;
      switch (result.status) {
        case AuthorizationStatus.authorized:
          final appleIdCredential = result.credential;
          final oAuthProvider = OAuthProvider('apple.com');
          final credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken),
            accessToken:
                String.fromCharCodes(appleIdCredential.authorizationCode),
          );
          final authResult = await _auth.signInWithCredential(credential);
          if (authResult != null) {
            print("login Pass");
            appDataModel.profileEmail = authResult.user.email;
            appDataModel.profileName = authResult.user.email;
            appDataModel.profileUid = authResult.user.uid;
            appDataModel.profilePhotoUrl = authResult.user.photoURL;
            appDataModel.profilePhone = authResult.user.phoneNumber;
            appDataModel.profileEmailVerify = authResult.user.emailVerified;
            appDataModel.loginProvider = 'apple';
            _userName = authResult.user.email;
            print("apple Login = " + appDataModel.profileEmail);
            _checkHaveUser(context.read<AppDataModel>());
          } else {
            Fluttertoast.showToast(
                msg: "เข้าสู่ระบบไม่สำเร็จ",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
          break;
        case AuthorizationStatus.error:
          print("Error: " + result.error.localizedDescription);

          break;
        case AuthorizationStatus.cancelled:
          print("User Cancelled");

          break;
      }
    } else {
      print("Unsupported sign in with apple");
    }
  }

  Future<Null> singInWithEmail(AppDataModel appDataModel) {
    if (_email.text.length > 0 && _password.text.length > 0) {
      if (emailRegex(_email.text)) {
        _auth
            .signInWithEmailAndPassword(
                email: _email.text, password: _password.text)
            .then((value) {
          print("value = " + value.user.displayName);
          _checkLogin(context.read<AppDataModel>());
        }).catchError((onError) {
          Fluttertoast.showToast(
              msg: "email or password is incorrect",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        });
      } else {
        Fluttertoast.showToast(
            msg: "wrong Email",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      Fluttertoast.showToast(
          msg: "Email or Password is emply",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<Null> _checkHaveUser(AppDataModel appDataModel) async {
    appDataModel.loginStatus = true;
    String token = await checkTokenMsg();
    print("token = $token");
    print("uid = " + appDataModel.profileUid);
    await db
        .collection('users')
        .doc(appDataModel.profileUid)
        .get()
        .then((value) async {
      if (value.data() != null) {
        appDataModel.userOneModel =
            userOneModelFromJson(jsonEncode(value.data()));

        if (appDataModel.userOneModel.name == null) {
          print("Not have User Update");
          if (appDataModel.profilePhotoUrl == null) {
            appDataModel.profilePhotoUrl =
                "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png";
          }
          UserOneModel model = UserOneModel(
            uid: appDataModel.profileUid,
            name: _userName,
            phone: appDataModel.profilePhone,
            email: appDataModel.profileEmail,
            photoUrl: appDataModel.profilePhotoUrl,
            location: appDataModel.userLat.toString() +
                ',' +
                appDataModel.userLng.toString(),
            token: token,
            potin: "0",
            credit: "0",
            status: '2',
          );
          Map<String, dynamic> data = model.toJson();
          await FirebaseFirestore.instance
              .collection('users')
              .doc(appDataModel.profileUid)
              .update(data)
              .then((value) {
            appDataModel.userOneModel = model;
            print('addNewUser complete =' + appDataModel.userOneModel.name);
          });
        }
        print("have User = " + appDataModel.userOneModel.name);
        appDataModel.screenW = MediaQuery.of(context).size.width;
        Navigator.pushNamedAndRemoveUntil(
            context, '/showHome-page', (route) => false);
      } else {
        print("Not have User");
        if (appDataModel.profilePhotoUrl == null) {
          appDataModel.profilePhotoUrl =
              "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png";
        }
        UserOneModel model = UserOneModel(
          uid: appDataModel.profileUid,
          name: _userName,
          phone: appDataModel.profilePhone,
          email: appDataModel.profileEmail,
          photoUrl: appDataModel.profilePhotoUrl,
          location: appDataModel.userLat.toString() +
              ',' +
              appDataModel.userLng.toString(),
          token: token,
          potin: "0",
          credit: "0",
          status: '2',
        );
        Map<String, dynamic> data = model.toJson();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(appDataModel.profileUid)
            .set(data)
            .then((value) {
          appDataModel.userOneModel = model;
          print('addNewUser complete =' + appDataModel.userOneModel.name);
          appDataModel.screenW = MediaQuery.of(context).size.width;
          Navigator.pushNamedAndRemoveUntil(
              context, '/showHome-page', (route) => false);
        });
      }
    }).catchError((onError) {
      print("Error $onError");
    });
  }

  @override
  void initState() {
    super.initState();
    _getOs(context.read<AppDataModel>());
  }

  Widget build(BuildContext context) {
    if (checkSystemStatus == false) _checkLogin(context.read<AppDataModel>());

    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              backgroundColor: Colors.white,
              body: Container(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Style().textSizeColor(
                              "เฮาะ", 60, Style().primaryColorHro),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Style().textSizeColor("ส่งถึงที่", 20, Colors.black),
                        ],
                      ),
                      (appDataModel.screenW == null)
                          ? Container()
                          : _buildEmailLogin(context.read<AppDataModel>()),
                      (checkSystemStatus == false ||
                              appDataModel.screenW == null)
                          ? Style().loading()
                          : (locationServiceEnabled == false ||
                                  locationPermission == false)
                              ?
                              // Container(
                              //     child: Style().textSizeColor(
                              //         "เข้าถึงตำแหน่งของคุณไม่ได้",
                              //         14,
                              //         Colors.red))
                              Container(
                                  child: Column(
                                    children: [
                                      (appDataModel.os == "android")
                                          ? SignInButton(
                                              Buttons.Google,
                                              text: "Sign in with Google",
                                              onPressed: () async {
                                                await signInWithGoogle(context
                                                    .read<AppDataModel>());
                                              },
                                            )
                                          : SignInButton(
                                              Buttons.Apple,
                                              text: "Sign in with Apple",
                                              onPressed: () async {
                                                signInWithApple(appDataModel);
                                              },
                                            ),
                                      (appDataModel.os == "ios")
                                          ? SignInButton(
                                              Buttons.Google,
                                              text: "Sign in with Google",
                                              onPressed: () async {
                                                await signInWithGoogle(context
                                                    .read<AppDataModel>());
                                              },
                                            )
                                          : Container()
                                    ],
                                  ),
                                )
                              : Container(
                                  child: Column(
                                    children: [
                                      (appDataModel.os == "android")
                                          ? SignInButton(
                                              Buttons.Google,
                                              text: "Sign in with Google",
                                              onPressed: () async {
                                                await signInWithGoogle(context
                                                    .read<AppDataModel>());
                                              },
                                            )
                                          : SignInButton(
                                              Buttons.Apple,
                                              text: "Sign in with Apple",
                                              onPressed: () async {
                                                signInWithApple(appDataModel);
                                              },
                                            ),
                                      (appDataModel.os == "ios")
                                          ? SignInButton(
                                              Buttons.Google,
                                              text: "Sign in with Google",
                                              onPressed: () async {
                                                await signInWithGoogle(context
                                                    .read<AppDataModel>());
                                              },
                                            )
                                          : Container()
                                    ],
                                  ),
                                )
                    ],
                  ),
                ),
              ),
            ));
  }

  _buildEmailLogin(AppDataModel appDataModel) {
    return Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        width: appDataModel.screenW * 0.7,
        child: Column(
          children: [
            TextField(
              style: TextStyle(
                  fontFamily: "prompt", fontSize: 14, color: Style().darkColor),
              decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(
                      fontFamily: "prompt",
                      fontSize: 14,
                      color: Style().darkColor),
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
                  suffixIcon: Icon(
                    Icons.email,
                    color: Style().darkColor,
                  ),
                  filled: true,
                  fillColor: Color.fromRGBO(243, 244, 247, 1)),
              controller: _email,
              onChanged: (value) {
                setState(() {});
              },
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: TextField(
                obscureText: true,
                style: TextStyle(
                    fontFamily: "prompt",
                    fontSize: 14,
                    color: Style().darkColor),
                decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(
                        fontFamily: "prompt",
                        fontSize: 14,
                        color: Style().darkColor),
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
                    suffixIcon: Icon(
                      Icons.lock,
                      color: Style().darkColor,
                    ),
                    filled: true,
                    fillColor: Color.fromRGBO(243, 244, 247, 1)),
                controller: _password,
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Container(
              width: appDataModel.screenW * 0.7,
              margin: EdgeInsets.only(top: 10),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Style().darkColor,
                  ),
                  onPressed: () async {
                    singInWithEmail(context.read<AppDataModel>());
                  },
                  child: Style().textSizeColor(
                      "เข้าสู่ระบบด้วย Email", 14, Colors.white)),
            ),
            Container(
                margin: EdgeInsets.only(top: 10),
                child: InkWell(
                    // onTap: () async {
                    //   print("Register");
                    //   var result =
                    //       Navigator.pushNamed(context, "/register-page");
                    //   if (result != null) {
                    //     _checkLogin(context.read<AppDataModel>());
                    //   }
                    // },
                    child: Style().textSizeColor("or", 16, Style().darkColor)))
          ],
        ));
  }

  Future<Null> registerFirebase() async {
    await Firebase.initializeApp().then((value) {
      print('Connect Firebase Success');
    });
  }
}
