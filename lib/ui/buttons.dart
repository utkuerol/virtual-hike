import 'package:flutter/material.dart';

class MyAppButtons {
  static buildButtonOK(context, text) {
    return TextButton(
      child: Text(text),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
