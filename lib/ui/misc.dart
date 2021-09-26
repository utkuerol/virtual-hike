import 'package:flutter/material.dart';

class MyAppMisc {
  static const Divider divider = Divider(
    height: 20,
    thickness: 5,
    indent: 20,
    endIndent: 20,
  );

  static Widget buildRouteStat(desc) {
    return Expanded(
      child: Text(
        desc,
        style: TextStyle(color: Colors.white70, fontSize: 20),
        textAlign: TextAlign.center,
      ),
    );
  }

  static Widget buildRouteStatValue(val) {
    return Expanded(
      child: Text(
        val,
        style: TextStyle(color: Colors.white70, fontSize: 30),
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.fade,
      ),
    );
  }
}
