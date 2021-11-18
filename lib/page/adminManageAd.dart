import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/adListModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class AdminAdManagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AdminAdManageState();
  }
}

class AdminAdManageState extends State<AdminAdManagePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<AdListModel> appPromote;

  _setData(AppDataModel appDataModel) async {
    await db.collection("adsApp").get().then((value) {
      var jsonData = setList2Json(value);
      print("promoteData = " + jsonData);
      appPromote = promoteListModelFromJson(jsonData);
    });

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _setData(context.read<AppDataModel>());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: AppBar(
                title: Style().textSizeColor("แบนเนอร์", 14, Colors.black),
                iconTheme: IconThemeData(color: Style().darkColor),
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                actions: [
                  IconButton(
                      onPressed: () async {
                        var result = await Navigator.pushNamed(
                            context, "/adminAdAdd-page");
                        print("resule22 = " + result.toString());
                        if (result != null) {
                          _setData(context.read<AppDataModel>());
                        }
                      },
                      icon: Icon(FontAwesomeIcons.plusCircle))
                ],
              ),
              body: (appPromote == null)
                  ? Center(child: Style().loading())
                  : Container(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildAppPromote(context.read<AppDataModel>())
                          ],
                        ),
                      ),
                    ),
            ));
  }

  _buildAppPromote(AppDataModel appDataModel) {
    return Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        padding: EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Column(
            children: appPromote.map((e) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: CachedNetworkImage(
                        key: UniqueKey(),
                        imageUrl: e.url,
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
                    ),
                  ),
                  Style().textSizeColor(e.name, 14, Colors.black)
                ],
              ),
              IconButton(
                  onPressed: () async {
                    var resule = await Dialogs().confirm(
                        context, "ลบโฆษณา", 'ต้องการลบโฆษณา ' + e.name);
                    if (resule == true) {
                      await FirebaseStorage.instance
                          .refFromURL(e.url)
                          .delete()
                          .then((value) {
                        print('Delete PhotoComplete');
                      });
                    }
                    await db.collection("adsApp").doc(e.id).delete();
                    _setData(context.read<AppDataModel>());
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                  ))
            ],
          );
        }).toList()));
  }
}
