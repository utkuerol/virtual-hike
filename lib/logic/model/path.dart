import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:simplify/simplify.dart';
import 'package:virtual_hike/logic/model/point.dart';
import 'package:geopoint/geopoint.dart';

class Path {
  List<LatLng> points = [];
  double distance;
  int _atPointInPath = 0;
  int _progressInCurrent = 0;

  Path(points, this.distance) {
    this.points = simplifyPath(points);
  }

  int getAtPointInPath() {
    return _atPointInPath;
  }

  String parseDistanceStringWithUnit() {
    double distance = this.distance;
    if (distance >= 1000) {
      distance = distance / 1000;
      distance = double.parse(distance.toStringAsFixed(2));
      return distance.toString() + "km";
    }
    return distance.toString() + "m";
  }

  LatLng moveInPath(int meters) {
    Distance distance = new Distance();
    int diffNextPoint = distance
        .distance(points[_atPointInPath], points[_atPointInPath + 1])
        .toInt();
    diffNextPoint -= _progressInCurrent;
    while (meters >= diffNextPoint) {
      print("Moving from " +
          _atPointInPath.toString() +
          " to" +
          (_atPointInPath + 1).toString());
      _atPointInPath++;
      meters -= diffNextPoint;
      diffNextPoint = distance
          .distance(points[_atPointInPath], points[_atPointInPath + 1])
          .toInt();
    }
    _progressInCurrent += meters;

    print("Current point in path: " + _atPointInPath.toString());
    print("Meters until next point in path: " + diffNextPoint.toString());
    print("Progress in current subpath (m): " + _progressInCurrent.toString());

    var bearing =
        distance.bearing(points[_atPointInPath], points[_atPointInPath + 1]);
    var at =
        distance.offset(points[_atPointInPath], _progressInCurrent, bearing);
    return at;
  }

  List<LatLng> simplifyPath(List<LatLng> points) {
    if (points.length <= 3000) {
      return points;
    }
    print("Total points before simplification: " + points.length.toString());
    List<LatLng> toReturn = [];
    var simpBegin = 500;
    var simpEnd = points.length - 500;
    var beginUnsimplified = points.sublist(0, simpBegin);
    var endUnsimplified = points.sublist(simpEnd, points.length);
    var toSimplify = points.sublist(simpBegin, simpEnd);
    List<Point> sp = [];
    toSimplify.forEach((e) => sp.add(new Point(e.latitude, e.longitude)));
    List<LatLng> simplified = [];
    simplify(sp, tolerance: 0.001)
        .forEach((e) => simplified.add(LatLng(e.x.toDouble(), e.y.toDouble())));

    toReturn.addAll(beginUnsimplified);
    toReturn.addAll(simplified);
    toReturn.addAll(endUnsimplified);
    print("Total points after simplification: " + toReturn.length.toString());
    return toReturn;
  }

  Map toJson() {
    List<Map> pointsJson = this.points.map((e) => PathPoint.toJson(e)).toList();
    return {
      'points': pointsJson,
      'distance': distance,
      'atPointInPath': _atPointInPath,
      'progressInCurrent': _progressInCurrent,
    };
  }

  Path.fromJson(Map json)
      : points = List<LatLng>.from(
            json['points']?.map((e) => PathPoint.fromJson(e)).toList()),
        distance = json["distance"] ?? 0,
        _atPointInPath = json['atPointInPath'],
        _progressInCurrent = json['progressInCurrent'];
}
