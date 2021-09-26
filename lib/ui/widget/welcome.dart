import 'package:flutter/material.dart';

import 'package:virtual_hike/logic/model/hiker.dart';

class Welcome extends Text {
  Welcome(Hiker hiker)
      : super.rich(
          TextSpan(children: <TextSpan>[
            TextSpan(
              text: "\nWelcome " + hiker.getName() + "!\n",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.white70),
            ),
            TextSpan(
              text: "\nTo create a route press the \"Set Route\" button below.",
              style: TextStyle(fontSize: 20, color: Colors.white70),
            )
          ]),
          textAlign: TextAlign.center,
        );
}
