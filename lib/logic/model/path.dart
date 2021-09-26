import 'package:latlong2/latlong.dart';
import 'package:virtual_hike/logic/model/point.dart';

class Path {
  List<LatLng> points = [];
  double distance;
  int _atPointInPath = 0;
  int _progressInCurrent = 0;

  Path(this.points, this.distance);

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

  Map toJson() {
    List<Map> pointsJson = this.points.map((e) => Point.toJson(e)).toList();
    return {
      'points': pointsJson,
      'distance': distance,
      'atPointInPath': _atPointInPath,
      'progressInCurrent': _progressInCurrent,
    };
  }

  Path.fromJson(Map json)
      : points = List<LatLng>.from(
            json['points']?.map((e) => Point.fromJson(e)).toList()),
        distance = json["distance"] ?? 0,
        _atPointInPath = json['atPointInPath'],
        _progressInCurrent = json['progressInCurrent'];
}
