import 'package:virtual_hike/logic/model/path.dart';
import 'package:virtual_hike/logic/model/route.dart';
import 'package:latlong2/latlong.dart' hide Path;

class Hiker {
  String _name = "";
  Route? _activeRoute;
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
    return this._activeRoute;
  }

  void setActiveRoute(Route? route) {
    this._activeRoute = route;
  }

  List<Route> getRoutes() {
    return this._routes;
  }

  void newRoute(LatLng from, LatLng to, Path path) {
    Route route = new Route(from, to, from, path);
    this._routes.add(route);
    this._activeRoute = route;
  }

  Hiker.fromJson(Map json)
      : _name = json['name'],
        _activeRoute = (json['activeRoute'] != null)
            ? Route.fromJson(json['activeRoute'])
            : null,
        _routes = (json['activeRoute'] != null)
            ? List<Route>.from(
                json['routes']?.map((e) => Route.fromJson(e)).toList())
            : [];

  Map toJson() {
    List<Map> routesJson = this._routes.map((e) => e.toJson()).toList();
    return {
      'name': _name,
      'activeRoute': _activeRoute?.toJson(),
      'routes': routesJson
    };
  }
}
