import 'package:latlong2/latlong.dart' hide Path;
import 'package:virtual_hike/logic/model/path.dart';
import 'package:virtual_hike/logic/model/point.dart';

class Route {
  LatLng _from;
  LatLng _to;
  LatLng _at;
  int _steps = 0;
  int _distanceInMeter = 0;
  Path _path;
  DateTime? _start;

  Route(this._from, this._to, this._at, this._path);

  LatLng getFrom() {
    return this._from;
  }

  void setFrom(LatLng from) {
    this._from = from;
  }

  LatLng getTo() {
    return this._to;
  }

  void setTo(LatLng to) {
    this._to = to;
  }

  LatLng getAt() {
    return this._at;
  }

  void setAt(LatLng at) {
    this._at = at;
  }

  getSteps() {
    return this._steps;
  }

  void resetProgressInRoute() {
    _steps = 0;
    _distanceInMeter = 0;
  }

  int getDistanceInMeter() {
    return this._distanceInMeter;
  }

  String parseDistanceStringWithUnit() {
    double distance = this._distanceInMeter.toDouble();
    if (distance >= 1000) {
      distance = distance / 1000;
      distance = double.parse(distance.toStringAsFixed(2));
      return distance.toString() + "km";
    }
    return distance.toString() + "m";
  }

  int _calcDistanceInMeter(int steps) {
    int distance = (steps * 0.8).toInt();
    return distance;
  }

  Path getPath() {
    return this._path;
  }

  void setPath(Path path) {
    this._path = path;
  }

  DateTime? getStart() {
    return this._start;
  }

  void start() {
    this._start = DateTime.now();
  }

  void setStart(DateTime date) {
    this._start = date;
  }

  void move(int steps) {
    int stepsChange = steps - _steps;
    if (stepsChange != 0) {
      print("moving steps: " + stepsChange.toString());
      this._steps = steps;
      this._distanceInMeter = _calcDistanceInMeter(_steps);
      _at = _path.moveInPath(_calcDistanceInMeter(stepsChange));
    }
  }

  Map toJson() {
    return {
      'from': PathPoint.toJson(_from),
      'to': PathPoint.toJson(_to),
      'at': PathPoint.toJson(_at),
      'path': _path.toJson(),
      'start': _start?.toIso8601String(),
    };
  }

  Route.fromJson(Map json)
      : _from = PathPoint.fromJson(json['from']),
        _to = PathPoint.fromJson(json['to']),
        _at = PathPoint.fromJson(json['at']),
        _path = Path.fromJson(json['path']),
        _start = DateTime.parse(json['start']);
}
