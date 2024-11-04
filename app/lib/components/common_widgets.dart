import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 경고 대화상자를 표시하는 함수
void showWarningDialog(BuildContext context, String message, String title) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

/// 텍스트 필드를 생성하는 함수
Widget buildTextField(TextEditingController controller, String hintText,
    {bool enabled = true}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hintText,
      border: const OutlineInputBorder(),
    ),
    enabled: enabled,
  );
}
