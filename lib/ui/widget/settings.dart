import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtual_hike/logic/model/hiker.dart';
import 'package:virtual_hike/ui/widget/app_bar.dart';

class Settings extends StatelessWidget {
  final Hiker hiker;

  Settings(this.hiker);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(context, false, hiker),
      body: Center(
          child: Column(
        children: [
          Text("To delete all saved data on your phone (username, routes, steps, calculated paths etc.)" +
              "please press the button below. But beware, this action cannot be undone!"),
          ElevatedButton(
            child: const Text('Delete Data'),
            onPressed: () {
              deleteData();
            },
          )
        ],
      )),
    );
  }

  void deleteData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
