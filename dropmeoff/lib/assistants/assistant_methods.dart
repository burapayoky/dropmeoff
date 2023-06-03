import 'dart:convert';

import 'package:dropmeoff/global/map_key.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dropmeoff/assistants/request_assistant.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../infoHandler/app_info.dart';
import '../models/directions.dart';
import 'package:dropmeoff/models/direction_details_info.dart';
import 'package:http/http.dart' as http;
class AssistantMethods
{
  static Future<String> searchAddressForGeographicCoOrdinates(Position position, context) async
  {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapkey";
    String humanReadableAddress="";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if(requestResponse != "Error Occurred, Failed. No Response.")
    {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude.toString();
      userPickUpAddress.locationLongitude = position.longitude.toString();
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetialsInfo?> obtainOriginToDestinationDirectionDetials(LatLng origionPosition,LatLng detionationPosition) async
  {
    String urlOriginToDestinationDirectionDetials ='https://maps.googleapis.com/maps/api/directions/json?origin=${origionPosition.latitude},${origionPosition.longitude}&destination=${detionationPosition.latitude},${detionationPosition.longitude}&key=$mapkey';
    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetials);
    if (responseDirectionApi == "Error Occured, Failed.No Response")
    {
      return null;
    }
    DirectionDetialsInfo directionDetialsInfo =DirectionDetialsInfo();
    directionDetialsInfo.e_points= responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetialsInfo.distance_text= responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetialsInfo.distance_value= responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetialsInfo.distance_text= responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetialsInfo.distance_value= responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetialsInfo;
  }
}
class PolylineDirections {
  static Future<List<LatLng>> getPolylineDirections(LatLng origin, LatLng destination, String apiKey) async {
    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$mapkey';

    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      if (data['status'] == 'OK') {
        List<dynamic> legs = data['routes'][0]['legs'];
        List<LatLng> polylineCoordinates = [];

        for (int i = 0; i < legs.length; i++) {
          List<dynamic> steps = legs[i]['steps'];

          for (int j = 0; j < steps.length; j++) {
            Map<String, dynamic> polyline = steps[j]['polyline'];
            String points = polyline['points'];
            List<LatLng> coordinates = _decodePolyline(points);
            polylineCoordinates.addAll(coordinates);
          }
        }

        return polylineCoordinates;
      } else {
        throw Exception('Failed to get polyline directions');
      }
    } else {
      throw Exception('Failed to get polyline directions');
    }
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      LatLng position = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      polylineCoordinates.add(position);
    }

    return polylineCoordinates;
  }
}