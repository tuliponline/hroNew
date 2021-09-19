import 'package:flutter/material.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeRider2UserPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return QrCodeRider2UserState();
  }
}

class QrCodeRider2UserState extends State<QrCodeRider2UserPage> {
  String qrCodeData;

  _genQrData(AppDataModel appDataModel) async {
    var respone = await http.get(Uri.parse(appDataModel.qrGenServer +
        "?phone=" +
        appDataModel.driverData.driverPhone +
        "&amount=" +
        appDataModel.qrAmount));
    qrCodeData = respone.body;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _genQrData(context.read<AppDataModel>());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              backgroundColor: Colors.grey.shade200,
              appBar: AppBar(
                iconTheme: IconThemeData(color: Style().darkColor),
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                title: Style()
                    .textSizeColor('Qr Code ชำระเงิน', 18, Style().darkColor),
              ),
              body: (qrCodeData == null)
                  ? Style().loading()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          margin: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(30.0),
                                            topLeft: Radius.circular(30.0),
                                          ),
                                          color: Style().darkColor),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Style().textSizeColor(
                                              appDataModel.moneyFormat.format(
                                                      int.parse(appDataModel
                                                          .qrAmount)) +
                                                  " ฿",
                                              40,
                                              Colors.white)
                                        ],
                                      )),
                                  Container(
                                    padding:
                                        EdgeInsets.only(top: 20, bottom: 10),
                                    margin: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        QrImage(
                                          data: qrCodeData,
                                          version: QrVersions.auto,
                                          size: 200.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Style().textBlackSize(
                                            appDataModel.driverData.driverName,
                                            16)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.check_circle,
                                size: 50, color: Style().darkColor))
                      ],
                    ),
            ));
  }
}
