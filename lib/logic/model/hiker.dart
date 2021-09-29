import 'package:virtual_hike/logic/model/path.dart';
import 'package:virtual_hike/logic/model/route.dart';
import 'package:latlong2/latlong.dart' hide Path;

class Hiker {
  String _name = "";
  int? _activeRouteIndex;
  List<Route> _routes = [];

  Hiker(String name) {
    this._name = name;
  }

  getName() {
    return this._name;
  }

  void setName(String name) {
    this._name = name;
  }

  Route? getActiveRoute() {
    return _activeRouteIndex != null ? _routes[this._activeRouteIndex!] : null;
  }

  void setActiveRouteIndex(int? route) {
    this._activeRouteIndex = route;
  }

  List<Route> getRoutes() {
    return this._routes;
  }

  void newRoute(LatLng from, LatLng to, Path path) {
    Route route = new Route(from, to, from, path);
    this._routes.add(route);
    this._activeRouteIndex = _routes.indexOf(route);
  }

  Hiker.fromJson(Map json)
      : _name = json['name'],
        _activeRouteIndex =
            (json['activeRoute'] != null) ? json['activeRoute'] : null,
        _routes = List<Route>.from(
            json['routes'].map((e) => Route.fromJson(e)).toList());

  Map toJson() {
    List<Map> routesJson = this._routes.map((e) => e.toJson()).toList();
    return {
      'name': _name,
      'activeRoute': _activeRouteIndex,
      'routes': routesJson
    };
  }
}
