import 'dart:convert';
import 'package:hro/model/AppDataModel.dart';
import 'package:http/http.dart' as http;

Future<Null> notifySend(String token, String title, String body) async {
  print("notiserver = " + AppDataModel().notifyServer);
  http.post(
    Uri.parse(AppDataModel().notifyServer),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, String>{'token': token, 'title': title, 'body': body}),
  );
}
