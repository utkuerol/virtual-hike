import 'package:latlong2/latlong.dart';

class PathPoint {
  static Map toJson(LatLng point) {
    return {'latitude': point.latitude, 'longtitude': point.longitude};
  }

  static LatLng fromJson(Map json) {
    return LatLng(json['latitude'], json['longtitude']);
  }
}
