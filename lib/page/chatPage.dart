import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/UserOneModel.dart';
import 'package:hro/model/chatListModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/fireBaseFunction.dart';
import 'package:hro/utility/notifySend.dart';

import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';

import 'package:provider/provider.dart';

import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  List<types.Message> _messages = [];
  var _user;

  var chatData;
  UserOneModel userOneModel;
  String orderIdSelect;
  OrderDetail orderDetail;
  String userTypeSelect;

  _setData(AppDataModel appDataModel) async {
    userOneModel = appDataModel.userOneModel;
    orderIdSelect = appDataModel.orderIdSelected;
    orderDetail = appDataModel.orderDetailSelect;
    userTypeSelect = appDataModel.userTypeSelect;
    _user = types.User(id: appDataModel.userOneModel.uid);

    (userTypeSelect == "rider")
        ? await dbUpdate(
            "updateChatOrder", "orders", orderIdSelect, {"chatRider": "0"})
        : await dbUpdate(
            "updateChatOrder", "orders", orderIdSelect, {"chatUser": "0"});

    await db
        .collection("chat")
        .doc(orderIdSelect)
        .collection("chatOrder")
        .orderBy("createdAt", descending: true)
        .get()
        .then((value) async {
      var jsonData = setList2Json(value);

      chatData = jsonData;
      List<ChatListModel> chatListModel = chatListModelFromJson(jsonData);

      chatListModel.asMap().forEach((idx, val) async {
        Author author = val.author;
        print(author.firstName);
        if (author.id != appDataModel.userOneModel.uid) {
          await db
              .collection("chat")
              .doc(orderIdSelect)
              .collection("chatOrder")
              .doc(val.createdAt.toString())
              .update({"status": "seen"});
          chatListModel[idx].status = "seen";
        }
      });
      chatData = (jsonEncode(chatListModel));

      // chatListModel.forEach((element) async {
      //   Author author = element.author;
      //   print(author.firstName);
      //   if (author.id != appDataModel.userOneModel.uid) {
      //     await db
      //         .collection("chat")
      //         .doc(orderIdSelect)
      //         .collection("chatOrder")
      //         .doc(element.createdAt.toString())
      //         .update({"stats": "seen"});
      //   }
      // });
    }).catchError((onError) {
      print(onError);
    });

    _loadMessages();
  }

  _realTimeDB(AppDataModel appDataModel) {
    db
        .collection("chat")
        .doc(orderIdSelect)
        .collection("chatOrder")
        .snapshots()
        .listen((event) async {
      _setData(context.read<AppDataModel>());
    });
  }

  @override
  void initState() {
    super.initState();
    _setData(context.read<AppDataModel>());
    _realTimeDB(context.read<AppDataModel>());
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Photo'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('File'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = _messages[index].copyWith(previewData: previewData);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    if (orderDetail.status == "0" ||
        orderDetail.status == "5" ||
        orderDetail.status == "6") {
      await Dialogs().information(context, Style().textBlackSize("ผิดพลาด", 16),
          Style().textBlackSize("ไม่สามารถส่งข้อความได้", 16));
    } else {
      int timeStamp = DateTime.now().millisecondsSinceEpoch;

      Author author = Author(
          firstName: userOneModel.name, id: userOneModel.uid, imageUrl: null);

      ChatOneModel chatOneModel = ChatOneModel(
          author: author,
          createdAt: timeStamp,
          id: const Uuid().v4(),
          text: message.text,
          status: "sent",
          type: "text");
      Map<String, dynamic> data = chatOneModel.toJson();
      await db
          .collection("chat")
          .doc(orderIdSelect)
          .collection("chatOrder")
          .doc(timeStamp.toString())
          .set(data)
          .then((value) async {
        print("OK");

        await dbUpdate(
            "updateChat", "chat", orderIdSelect, {"updateTime": timeStamp});

        (userTypeSelect == "rider")
            ? await dbUpdate(
                "updateChatOrder", "orders", orderIdSelect, {"chatUser": "1"})
            : await dbUpdate(
                "updateChatOrder", "orders", orderIdSelect, {"chatRider": "1"});

        _setData(context.read<AppDataModel>());

        String dbForToken = orderDetail.driver;
        String notiTitle = "ลูกค้าส่งข้อความถึงคุณ";
        if (userTypeSelect == "rider") {
          dbForToken = orderDetail.customerId;
          notiTitle = "Riderส่งข้อความถึงคุณ";
        }

        var _dbResult = await dbGetDataOne("getUser", 'users', dbForToken);
        if (_dbResult[0]) {
          UserOneModel _userOneModel = userOneModelFromJson(_dbResult[1]);
          notifySend(_userOneModel.token, notiTitle, message.text);
        }
      }).catchError((onError) {
        print(onError);
      });
    }

    // final textMessage = types.TextMessage(
    //   author: _user,
    //   createdAt: DateTime.now().millisecondsSinceEpoch,
    //   id: const Uuid().v4(),
    //   text: message.text,
    // );
    // print(textMessage);

    // _addMessage(textMessage);
  }

  void _loadMessages() async {
    final messages = (jsonDecode(chatData) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _messages = messages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: AppBar(
                title: Style().textBlackSize("Order $orderIdSelect", 14),
                backgroundColor: Colors.white,
                elevation: 0.5,
                leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Style().darkColor,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              body: SafeArea(
                bottom: false,
                child: (_user == null)
                    ? Center(child: Style().loading())
                    : Chat(
                        theme: DefaultChatTheme(
                            primaryColor: Style().darkColor,
                            inputBackgroundColor: Style().darkColor,
                            inputTextDecoration: InputDecoration(
                              label: Style().textSizeColor(
                                  "พิมพ์ข้อความ", 14, Colors.white),
                              hintText: "test",
                              border: InputBorder.none,
                            )),
                        messages: _messages,
                        onPreviewDataFetched: _handlePreviewDataFetched,
                        onSendPressed: _handleSendPressed,
                        user: _user,
                        emptyState: Center(
                            child: Style().textSizeColor(
                                "เริ่มแชตเลย", 16, Style().darkColor)),
                      ),
              ),
            ));
  }
}
