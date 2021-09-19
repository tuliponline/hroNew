import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hro/utility/style.dart';

Future<Null> normalDialog(
    BuildContext context, String title, String subTitle) async {
  showDialog(
      context: context,
      builder: (context) => SimpleDialog(
            title: ListTile(
              title: Style().textBlackSize(title, 16),
              subtitle: Style().textBlackSize(subTitle, 14),
            ),
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Style().textDark('OK'))
            ],
          ));
}
