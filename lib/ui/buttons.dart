import 'package:flutter/material.dart';
import 'package:virtual_hike/ui/widget/app.dart';

class MyAppButtons {
  static buildButtonOK(context, text) {
    return TextButton(
      child: Text(text),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  static buildButtonBack(context, text) {
    return TextButton(
      child: Text(text),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (context) => MyApp(null)),
            (route) {
          return false;
        });
      },
    );
  }
}
