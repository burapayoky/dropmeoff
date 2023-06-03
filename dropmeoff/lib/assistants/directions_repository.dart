import 'package:dropmeoff/global/map_key.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/directions.dart';

class DirectionsRepository extends Directions {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  DirectionsRepository({required super.polylinePoints});

  Future<Directions> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl'
            'origin=${origin.latitude},${origin.longitude}'
            '&destination=${destination.latitude},${destination.longitude}'
            '&key=$mapkey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final directions = Directions.fromMap(data);
      return directions;
    } else {
      throw Exception('Failed to fetch directions');
    }
  }
}
class Directions {
  final List<LatLng> polylinePoints;

  Directions({required this.polylinePoints});

  factory Directions.fromMap(Map<String, dynamic> map) {
    final List<dynamic> routes = map['routes'];
    final Map<String, dynamic> route = routes.first;
    final Map<String, dynamic> overviewPolyline = route['overview_polyline'];
    final String encodedPoints = overviewPolyline['points'];
    final List<LatLng> polylinePoints = _decodePolyline(encodedPoints);
    return Directions(polylinePoints: polylinePoints);
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      final point = LatLng(lat / 1E5, lng / 1E5);
      points.add(point);
    }
    return points;
  }
}