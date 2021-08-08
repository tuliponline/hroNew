import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> checkHaveShop(String shopId) async {
  bool haveShop = false;
  await FirebaseFirestore.instance
      .collection("shops")
      .doc(shopId)
      .get()
      .then((value) {
    if (value.data() == null) {
      haveShop = false;
    } else {
      haveShop = true;
    }
  }).catchError((onError) {
    haveShop = false;
  });
  return haveShop;
}

Future<bool> checkHaveRider(String riderId) async {
  bool haveRider = false;
  await FirebaseFirestore.instance
      .collection("drivers")
      .doc(riderId)
      .get()
      .then((value) {
    if (value.data() == null) {
      haveRider = false;
    } else {
      haveRider = true;
    }
  }).catchError((onError) {
    haveRider = false;
  });
  return haveRider;
}
