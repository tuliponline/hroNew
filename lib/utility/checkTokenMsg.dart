import 'package:firebase_messaging/firebase_messaging.dart';

Future<String>checkTokenMsg() async{
  String token;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
 token = await firebaseMessaging.getToken();
 return token;
}