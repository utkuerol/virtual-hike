import 'package:flutter/material.dart';
import 'package:virtual_hike/logic/model/hiker.dart';
import 'package:virtual_hike/ui/ui_elements.dart';
import 'package:virtual_hike/ui/widget/history.dart';

class MyAppBar extends AppBar {
  MyAppBar(context, bool mainPage, Hiker hiker)
      : super(title: Text(UIElements.APP_NAME), actions: <Widget>[
          mainPage
              ? ElevatedButton(
                  child: const Text('My Routes'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => History(hiker: hiker)),
                    );
                  },
                )
              : Container(),
          mainPage
              ? ElevatedButton(
                  child: const Text('Settings'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => History(hiker: hiker)),
                    );
                  },
                )
              : Container()
        ]);
}
