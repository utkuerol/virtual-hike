import 'package:flutter/material.dart';

import 'package:virtual_hike/logic/model/hiker.dart';

class Welcome extends Text {
  Welcome(Hiker hiker, bool routeSelectionOn)
      : super.rich(
          TextSpan(children: <TextSpan>[
            TextSpan(
              text: "\nWelcome " + hiker.getName() + "!\n",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.white70),
            ),
            !routeSelectionOn
                ? TextSpan(
                    text:
                        "\nTo create a new route press the \"New Route\" button below.",
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  )
                : TextSpan(
                    text:
                        "\nYou can select your starting point by long pressing on the map. Once you've set the starting point, do the same thing to select your destination point.",
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  ),
          ]),
          textAlign: TextAlign.center,
        );
}
