import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:virtual_hike/logic/model/path.dart';
import 'package:latlong2/latlong.dart' hide Path;

class OpenRouteClient {
  final String url = 'https://api.openrouteservice.org/v2/directions/';
  final String apiKey =
      '5b3ce3597851110001cf6248f3e58a4253a04144ab8837833598f5b9';
  final String pathParam = 'foot-hiking';
  final double startLng;
  final double startLat;
  final double endLng;
  final double endLat;

  OpenRouteClient(
      {required this.startLng,
      required this.startLat,
      required this.endLng,
      required this.endLat});

  Future<Path> getPath() async {
    var uri =
        '$url$pathParam?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat';
    print(uri);
    http.Response response = await http.get(Uri.parse(uri));
    List<LatLng> points = [];
    if (response.statusCode == 200) {
      String data = response.body;
      var jsonData = jsonDecode(data);
      var coordinates = jsonData['features'][0]['geometry']['coordinates'];
      for (int i = 0; i < coordinates.length; i++) {
        points.add(LatLng(coordinates[i][1], coordinates[i][0]));
      }
      double distance =
          jsonData['features'][0]['properties']['summary']['distance'] ?? 0;
      Path path = Path(points, distance);
      return path;
    } else {
      print(response.statusCode);
      return Path(points, 0);
    }
  }
}
