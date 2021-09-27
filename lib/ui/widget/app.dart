import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';
import 'dart:async';
import 'package:health/health.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:virtual_hike/infrastructure/openrouteservice/client.dart';
import 'package:virtual_hike/logic/model/hiker.dart';
import 'package:virtual_hike/logic/model/path.dart';
import 'package:virtual_hike/logic/operations/map.dart';
import 'package:virtual_hike/ui/misc.dart';
import 'package:virtual_hike/ui/widget/alerts.dart';
import 'package:virtual_hike/ui/widget/app_bar.dart';
import 'package:virtual_hike/ui/widget/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatefulWidget {
  final Hiker? hiker;

  MyApp(this.hiker);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _stepsAvailable = true;
  Hiker _hiker = new Hiker("Unknown Hiker");
  LatLng? _fromSelection;
  LatLng? _toSelection;
  bool _routeSelectionOn = false;
  MapController _mapctl = MapController();
  Timer? timer;
  Path? _previewPath;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    if (this.widget.hiker == null) {
      _loadSavedState().then((value) {
        setState(() {
          _initPlatformState();
        });
      });
    } else {
      print("loading hiker from widget");
      _hiker = this.widget.hiker!;
      setState(() {
        _initPlatformState();
      });
    }
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) => _fetchStepData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future _loadSavedState() async {
    print("loading state...");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var loadedHiker = prefs.getString("HIKER");
    if (loadedHiker != null) {
      print("got hiker");
      setState(() {
        _hiker = Hiker.fromJson(jsonDecode(loadedHiker));
        _loading = false;
        _mapctl.move(
            _hiker.getActiveRoute()?.getAt() ?? _mapctl.center, _mapctl.zoom);
      });
    } else {
      print("no hiker found");
      _loading = false;
    }
  }

  void saveState() async {
    print("saving state...");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("HIKER", jsonEncode(_hiker));
  }

  _initPlatformState() async {
    if (_hiker.getActiveRoute() == null) {
      _enableLocationServices().then((value) {
        setState(() {
          _loading = false;
        });
      });
    }
    if (!mounted) return;
  }

  Future _enableLocationServices() async {
    _loading = true;
    var locationData = await MapOperations.determinePhysicalLocation();
    var loc = LatLng(locationData.latitude, locationData.longitude);
    _mapctl.move(loc, 13.0);
  }

  Future _fetchStepData() async {
    List<HealthDataPoint> _healthDataList = [];
    var route = _hiker.getActiveRoute();
    if (route != null && route.getStart() != null) {
      DateTime startDate = route.getStart()!;
      DateTime endDate = DateTime.now();

      HealthFactory health = HealthFactory();

      // define the types to get
      List<HealthDataType> types = [
        HealthDataType.STEPS,
      ];

      // you MUST request access to the data types before reading them
      bool accessWasGranted = await health.requestAuthorization(types);

      int steps = 0;

      if (accessWasGranted) {
        try {
          // fetch new data
          List<HealthDataPoint> healthData =
              await health.getHealthDataFromTypes(startDate, endDate, types);

          // save all the new data points
          _healthDataList.addAll(healthData);
        } catch (e) {
          print("Caught exception in getHealthDataFromTypes: $e");
        }
        _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

        // print the results
        _healthDataList.forEach((x) {
          steps += x.value.round();
        });
        setState(() {
          print("Received total steps from system: " + steps.toString());
          var tmp = route.getSteps();
          route.move(steps);
          if (tmp != route.getSteps()) {
            saveState();
            _mapctl.move(route.getAt(), _mapctl.zoom);
          }
        });
      } else {
        print("Authorization not granted");
        setState(() {
          _stepsAvailable = false;
          MyAppAlerts.alertDialogStepsUnavailable(context);
        });
      }
    }
  }

  void _handleMapLongPress(tapPos, latLng) {
    if (_routeSelectionOn) {
      if (_fromSelection == null) {
        setState(() {
          _fromSelection = latLng;
        });
      } else if (_toSelection == null) {
        _calculatePath(_fromSelection!, latLng).then((value) {
          setState(() {
            _toSelection = latLng;
            _previewPath = value;
            _loading = false;
          });
        });
      }
    }
  }

  Future _calculatePath(LatLng from, LatLng to) {
    _loading = true;
    var client = OpenRouteClient(
        startLng: from.longitude,
        startLat: from.latitude,
        endLng: to.longitude,
        endLat: to.latitude);
    return client.getPath();
  }

  void _toggleRouteSelection() {
    setState(() {
      if (_routeSelectionOn) {
        var from = _fromSelection;
        var to = _toSelection;
        if (from != null && to != null) {
          _calculatePath(from, to).then((path) {
            setState(() {
              _hiker.newRoute(from, to, path);
              _hiker.getActiveRoute()?.start();
              _fromSelection = null;
              _toSelection = null;
              _previewPath = null;
              saveState();
              _loading = false;
            });
          });
          _routeSelectionOn = !_routeSelectionOn;
        } else {
          MyAppAlerts.alertDialogRouteNotChosen(context);
        }
      } else {
        _fromSelection = null;
        _toSelection = null;
        _routeSelectionOn = !_routeSelectionOn;
      }
    });
  }

  void _abortRouteSelection() {
    setState(() {
      _fromSelection = null;
      _toSelection = null;
      _previewPath = null;
      _routeSelectionOn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(context, true, _hiker),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                getMapWidget(),
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.13,
            maxChildSize: 0.9,
            builder: (BuildContext context, myscrollController) {
              return Padding(
                  padding: const EdgeInsets.symmetric(),
                  child: Container(
                      child: SingleChildScrollView(
                        controller: myscrollController,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Welcome(_hiker),
                              SizedBox(height: 10),
                              _routeSelectionOn
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                          TextButton(
                                            onPressed: _toggleRouteSelection,
                                            style: TextButton.styleFrom(
                                                backgroundColor: Colors.white70,
                                                primary: Colors.black87),
                                            child: _routeSelectionOn
                                                ? Text('Save')
                                                : Text('Set Route'),
                                          ),
                                          TextButton(
                                            onPressed: _abortRouteSelection,
                                            style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Colors.red.shade400,
                                                primary: Colors.black87),
                                            child: Text('Cancel'),
                                          ),
                                        ])
                                  : TextButton(
                                      onPressed: _toggleRouteSelection,
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.white70,
                                          primary: Colors.black87),
                                      child: _routeSelectionOn
                                          ? Text('Save')
                                          : Text('Set Route'),
                                    ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  MyAppMisc.buildRouteStat("Route started:"),
                                  MyAppMisc.buildRouteStatValue(_hiker
                                          .getActiveRoute()
                                          ?.getStart()
                                          .toString()
                                          .substring(0, 16) ??
                                      "N/A"),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  MyAppMisc.buildRouteStat("Steps taken:"),
                                  MyAppMisc.buildRouteStatValue(_hiker
                                          .getActiveRoute()
                                          ?.getSteps()
                                          .toString() ??
                                      "N/A"),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  MyAppMisc.buildRouteStat("Distance went:"),
                                  MyAppMisc.buildRouteStatValue(_hiker
                                          .getActiveRoute()
                                          ?.parseDistanceStringWithUnit() ??
                                      "N/A"),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  MyAppMisc.buildRouteStat(
                                      "Total path length:"),
                                  MyAppMisc.buildRouteStatValue(_hiker
                                          .getActiveRoute()
                                          ?.getPath()
                                          .parseDistanceStringWithUnit() ??
                                      "N/A")
                                ],
                              )
                            ]),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15)),
                      )));
            },
          ),
          _loading ? Center(child: CircularProgressIndicator()) : Container(),
        ],
      ),
    );
  }

  Widget getMapWidget() {
    return Expanded(
        flex: 10,
        child: FlutterMap(
          mapController: _mapctl,
          options: MapOptions(
              center: _hiker.getActiveRoute()?.getAt(),
              zoom: 13.0,
              onLongPress: (tapPos, latLng) =>
                  _handleMapLongPress(tapPos, latLng)),
          layers: [
            TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
              attributionBuilder: (_) {
                return Text("© OpenStreetMap contributors");
              },
            ),
            MarkerLayerOptions(
              markers: [
                Marker(
                  width: 50.0,
                  height: 50.0,
                  point: _fromSelection ??
                      _hiker.getActiveRoute()?.getAt() ??
                      LatLng(0, 0),
                  builder: (ctx) => Container(
                    child: Icon(Icons.directions_walk),
                  ),
                ),
                Marker(
                  width: 50.0,
                  height: 50.0,
                  point: _fromSelection ??
                      _hiker.getActiveRoute()?.getFrom() ??
                      LatLng(0, 0),
                  builder: (ctx) => Container(
                      child: Icon(
                    Icons.gps_fixed,
                  )),
                ),
                Marker(
                  width: 50.0,
                  height: 50.0,
                  point: _toSelection ??
                      _hiker.getActiveRoute()?.getTo() ??
                      LatLng(0, 0),
                  builder: (ctx) => Container(
                    child: Icon(
                      Icons.location_on,
                    ),
                  ),
                ),
              ],
            ),
            PolylineLayerOptions(
              polylines: _drawPath(),
            )
          ],
        ));
  }

  List<Polyline> _drawPath() {
    List<Polyline> polylines = [];
    List<LatLng> fullPath = [];
    List<LatLng> completedPoints = [];
    if (_previewPath != null) {
      fullPath = _previewPath!.points;
    } else {
      var route = _hiker.getActiveRoute();
      if (route != null) {
        fullPath = route.getPath().points;
        completedPoints = route
            .getPath()
            .points
            .sublist(0, route.getPath().getAtPointInPath() + 1);
      }
    }
    polylines = <Polyline>[
      // full path
      Polyline(points: fullPath, strokeWidth: 5.0, color: Colors.red),
      // completed path
      Polyline(points: completedPoints, strokeWidth: 5.0, color: Colors.green)
    ];
    return polylines;
  }
}
