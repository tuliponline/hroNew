import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hro/utility/getTimeNow.dart';

addErrorLog(String errorLog) {
  FirebaseFirestore db = FirebaseFirestore.instance;
  String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
  String timeNow = getTimeStringNow();
  db
      .collection('errorLog')
      .doc(timeStamp)
      .set({"error": errorLog, "time": timeNow})
      .then((value) {})
      .catchError((onError) {
        print('addLogError = $onError');
      });
}
