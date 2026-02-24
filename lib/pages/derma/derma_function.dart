import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<String?> showDermaActionSheet(
    BuildContext context, List<String> options) async {
  return await showCupertinoModalPopup<String>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      actions: options
          .map(
            (text) => CupertinoActionSheetAction(
              child: Text(
                text,
                style: TextStyle(
                    color: text == 'Derma Tanpa Nama'
                        ? const Color.fromARGB(255, 255, 95, 95)
                        : null),
              ),
              isDestructiveAction: false,
              onPressed: () {
                Navigator.pop(context, text);
              },
            ),
          )
          .toList(),
      // cancelButton: CupertinoActionSheetAction(
      //   child: Text('Cancel'),
      //   isDefaultAction: true,
      //   onPressed: () {
      //     Navigator.pop(context, null); // Return null for cancel action
      //   },
      // ),
    ),
  );
}
