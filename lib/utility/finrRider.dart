import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/utility/snapshot2list.dart';

Future<List<String>> fineRiderOnlineStatus() async {
  FirebaseFirestore db = FirebaseFirestore.instance;

  var jsonData;
  String _allRiderStatus = "offline";
  int online = 0;
  int inwork = 0;

  await db.collection("drivers").get().then((value) async {
    jsonData = setList2Json(value);
    List<DriversListModel> drivers = driversListModelFromJson(jsonData);

    for (var rider in drivers) {
      if (rider.driverStatus == "1") {
        online++;
      } else if (rider.driverStatus == "2") {
        inwork++;
      }
    }
    if (online > 0) {
      _allRiderStatus = "online";
    } else {
      if (inwork > 0) _allRiderStatus = "inwork";
    }
  });
  return [_allRiderStatus, jsonData];
}
