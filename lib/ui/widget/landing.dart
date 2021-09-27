import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtual_hike/ui/widget/app.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: Container(
        height: 400,
        child: Card(
          color: Colors.black87,
          elevation: 8.0,
          margin: EdgeInsets.all(20.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  "Welcome to Virtual Hike!",
                  style: TextStyle(color: Colors.white70, fontSize: 30),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  "Press the \"Load\" button to load a saved profile or create a new one and overwrite the existing profile by pressing \"Fresh Start\" button.",
                  style: TextStyle(color: Colors.white70, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyApp(null)), (route) {
                            return false;
                          });
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.white70,
                            primary: Colors.black87),
                        child: Text('Load'),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteData().then((value) =>
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyApp(null)),
                                  (route) {
                                return false;
                              }));
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            primary: Colors.black87),
                        child: Text('Fresh Start'),
                      ),
                    ]),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Future deleteData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    print(prefs.getKeys());
  }
}
