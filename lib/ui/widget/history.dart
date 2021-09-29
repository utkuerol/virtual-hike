import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtual_hike/logic/model/hiker.dart';
import 'package:virtual_hike/ui/misc.dart';
import 'package:virtual_hike/ui/alerts.dart';
import 'package:virtual_hike/ui/widget/app.dart';
import 'package:virtual_hike/ui/widget/app_bar.dart';

class History extends StatefulWidget {
  final Hiker hiker;

  History({Key? key, required this.hiker}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState(hiker);
}

class _HistoryState extends State<History> {
  Hiker _hiker;

  _HistoryState(this._hiker);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (context) => MyApp(_hiker)),
            (route) {
          return false;
        });
        return Future.value(true);
      },
      child: Scaffold(
        appBar: MyAppBar(context, false, _hiker),
        body: Center(
          child: ListView.builder(
            itemCount: _hiker.getRoutes().length,
            itemBuilder: (context, index) {
              return card(context, index);
            },
          ),
        ),
      ),
    );
  }

  void deleteRoute(int index) {
    setState(() {
      _hiker.getRoutes().removeAt(index);
      if (_hiker.getRoutes().isEmpty) {
        _hiker.setActiveRouteIndex(null);
        if (_hiker.getRoutes().isEmpty) {
          MyAppAlerts.alertDialogRoutesEmpty(context);
        }
      }
      saveState();
    });
  }

  void saveState() async {
    print("saving state...");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("HIKER", jsonEncode(_hiker));
  }

  Widget card(context, int i) {
    var route = _hiker.getRoutes()[i];
    return Card(
      color: Colors.black87,
      elevation: 8.0,
      margin: EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            "Route Nr. " + (i + 1).toString(),
            style: TextStyle(color: Colors.white70, fontSize: 40),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MyAppMisc.buildRouteStat("Route started:"),
              MyAppMisc.buildRouteStatValue(
                  route.getStart().toString().substring(0, 16)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MyAppMisc.buildRouteStat("Steps taken:"),
              MyAppMisc.buildRouteStatValue(route.getSteps().toString()),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MyAppMisc.buildRouteStat("Distance went:"),
              MyAppMisc.buildRouteStatValue(
                  route.parseDistanceStringWithUnit()),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MyAppMisc.buildRouteStat("Total path length:"),
              MyAppMisc.buildRouteStatValue(
                  route.getPath().parseDistanceStringWithUnit())
            ],
          ),
          SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            TextButton(
              onPressed: () {
                _hiker.setActiveRouteIndex(_hiker.getRoutes().indexOf(route));
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) => MyApp(_hiker)),
                    (route) {
                  return false;
                });
              },
              style: TextButton.styleFrom(
                  backgroundColor: Colors.white70, primary: Colors.black87),
              child: Text('Set Active'),
            ),
            TextButton(
              onPressed: () => deleteRoute(i),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  primary: Colors.black87),
              child: Text('Delete'),
            ),
          ]),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
