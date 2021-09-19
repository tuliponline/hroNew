import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/UserListMudel.dart';
import 'package:hro/model/UserOneModel.dart';
import 'package:hro/utility/Dialogs.dart';
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
                title: Style().textDarkAppbar('Admin'),
              ),
              body: Container(
                child: _systemMenu(),
              ),
            ));
  }

  _systemMenu() {
    return Row(
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
    );
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
