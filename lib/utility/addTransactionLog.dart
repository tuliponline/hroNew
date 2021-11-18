import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hro/model/CreditTransactionOneModel.dart';
import 'package:hro/utility/getTimeNow.dart';

Future<Null> addTransactionLog(
    String userId, cmd, from, to, value, type, text, comment) async {
  String timeStamp = await getTimeStampNow();
  String timeNow = await getTimeStringNow();

  FirebaseFirestore db = FirebaseFirestore.instance;
  CreditTransactionOneModel creditTransactionOneModel;
  creditTransactionOneModel = CreditTransactionOneModel(
      id: timeStamp,
      date: timeNow,
      userId: userId,
      cmd: cmd,
      from: from,
      to: to,
      value: value,
      type: type,
      text: text,
      comment: comment);
  Map<String, dynamic> data = creditTransactionOneModel.toJson();
  await db.collection("creditTransaction").doc(timeStamp).set(data);
}
