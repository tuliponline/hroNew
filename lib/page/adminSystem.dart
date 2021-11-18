import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/UserListMudel.dart';
import 'package:hro/model/UserOneModel.dart';
import 'package:hro/model/productsModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/fireBaseFunction.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class AdminSystemPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AdminSystemState();
  }
}

class AdminSystemState extends State<StatefulWidget> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  String collection, document, field, dataValue;
  String os;
  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: AppBar(
                iconTheme: IconThemeData(color: Style().darkColor),
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                title: Style().textDarkAppbar('Admin cmd'),
              ),
              body: Container(
                child: _addBd(),
              ),
            ));
  }

  _addBd() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            child: TextField(
              style: TextStyle(fontSize: 17),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Style().labelColor)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Style().labelColor)),
                  hintText: "collection",
                  hintStyle: TextStyle(fontSize: 14)),
              onChanged: (value) => collection = value.trim(),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: TextField(
              style: TextStyle(fontSize: 17),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Style().labelColor)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Style().labelColor)),
                  hintText: "document",
                  hintStyle: TextStyle(fontSize: 14)),
              onChanged: (value) => document = value.trim(),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: TextField(
              style: TextStyle(fontSize: 17),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Style().labelColor)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Style().labelColor)),
                  hintText: "field",
                  hintStyle: TextStyle(fontSize: 14)),
              onChanged: (value) => field = value.trim(),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: TextField(
              style: TextStyle(fontSize: 17),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Style().labelColor)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Style().labelColor)),
                  hintText: "value",
                  hintStyle: TextStyle(fontSize: 14)),
              onChanged: (value) => dataValue = value.trim(),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: ElevatedButton(
              onPressed: () async {
                var _resule = await Dialogs()
                    .confirm(context, "เพิ่มข้อมูล", "ยืนยันการเพิ่มข้อมูล ?");
                if (_resule) {
                  _addUserData();
                  // var _dbAll =
                  //     await dbGetDataAll("get $collection", collection);
                  // if (_dbAll[0]) {
                  //   var jsonData = setList2Json(_dbAll[1]);
                  //   List<UserListModel> _userListData =
                  //       userListModelFromJson(jsonData);
                  //   _userListData.forEach((element) async {
                  //     if (element.name == null) {
                  //       await dbDeleteData("deleteID", "users", element.uid);
                  //       await dbAddData("Add DeleteIDid", "deleteID",
                  //           element.uid, {"uid": element.uid});
                  //       // await dbUpdate("addCredit", collection, element.uid,
                  //       //     {"credit": dataValue});
                  //       print("OK");
                  //     }
                  //   });
                  // }
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Style().textSizeColor("สมัคร", 14, Colors.white),
                ],
              ),
              style: ElevatedButton.styleFrom(
                  primary: Style().primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
            ),
          )
        ],
      ),
    );
  }

  _addUserData() async {
    var get_dbAll =
        await db.collection("deleteID").get().then((user_value) async {
      user_value.docs.forEach((element) async {
        print(element.id);
        var profilePhotoUrl =
            "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png";

        UserOneModel model = UserOneModel(
          uid: element.id,
          name: "_userName",
          phone: null,
          email: "email@email.com",
          photoUrl: profilePhotoUrl,
          location: null,
          token: null,
          potin: "0",
          credit: "0",
          status: '2',
        );
        Map<String, dynamic> data = model.toJson();
        await db.collection('users').doc(element.id).set(data).then((value) {
          print("Ok");
        });
      });
    });
  }

  _systemMenu() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(right: 5),
              child: ElevatedButton(
                  onPressed: () {
                    _addField2AllDoc("users", "os", "unknow");
                  },
                  child: Text("add File os to user")),
            ),
            Container(
              margin: EdgeInsets.only(right: 5),
              child: ElevatedButton(
                  onPressed: () {
                    _addPhotoUrlToUserNull();
                  },
                  child: Text("add photo url to user null")),
            )
          ],
        ),
        Container(
          margin: EdgeInsets.only(right: 5),
          child: ElevatedButton(
              onPressed: () {
                _addOriPrice();
              },
              child: Text("add oriProce to Product")),
        )
      ],
    );
  }

  _addOriPrice() async {
    var _productDb = await dbGetDataAll("getProduct", "products");
    if (_productDb[0]) {
      var jsonData = setList2Json(_productDb[1]);
      List<ProductsModel> productsModel;
      productsModel = productsModelFromJson(jsonData);
      for (var product in productsModel) {
        var _addProductDb = await dbUpdate("addOriProctProduct", "products",
            product.productId, {"product_OriPrice": product.productPrice});
        if (_addProductDb) {
          print("ok");
        } else {
          print("fail");
        }
      }
    }
  }

  _addPhotoUrlToUserNull() async {
    var result = await Dialogs()
        .confirm(context, "แก้ไข photo Url", "เพิ่มค่าใส่ Url ที่ว่างใน Users");
    if (result == true) {
      db
          .collection("users")
          .where("photo_url", isEqualTo: null)
          .get()
          .then((value) {
        var jsonData = setList2Json(value);
        List<UserListModel> userListModel = userListModelFromJson(jsonData);
        userListModel.forEach((e) {
          if (e.photoUrl == null) {
            db.collection("users").doc(e.uid).update({
              "photo_url":
                  "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png"
            }).then((value) {
              print("photoUrl Updated");
            });
          }
        });
      });
    }
  }

  _addField2AllDoc(String collection, field, value) async {
    var result = await Dialogs()
        .confirm(context, "add Field Os", "add Field Os To Users");
    if (result == true) {
      await db.collection(collection).get().then((value) {
        var jsonData = setList2Json(value);
        List<UserListModel> userListModel = userListModelFromJson(jsonData);
        print("userList = " + userListModel.length.toString());
        userListModel.forEach((e) async {
          print(e.uid);
          await db.collection("users").doc(e.uid).update({"os": "unknow"});
          // await db
          //     .collection(collection)
          //     .doc(e.uid)
          //     .update({field: value}).then((value) {
          //   print("update Os Suscess");
          // });
        });
      });
    }
  }
}
