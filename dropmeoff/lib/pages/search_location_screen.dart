import 'dart:convert';

import 'package:dropmeoff/global/map_key.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({Key? key}) : super(key: key);

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocus;
  List<dynamic> _placePredictions = [];
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
  }

  Future<List<Map<String, dynamic>>> _getPlacePredictions(String inputText) async {
    final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapkey&location=18.7953,98.9524&radius=1000&components=country:TH');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final predictions = json.decode(response.body)['predictions'];
      final places = <Map<String, dynamic>>[];

      for (final prediction in predictions) {
        final placeId = prediction['place_id'];
        final detailsUri = Uri.parse(
            'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapkey');

        final detailsResponse = await http.get(detailsUri);

        if (detailsResponse.statusCode == 200) {
          final details = json.decode(detailsResponse.body)['result'];
          final geometry = details['geometry'];
          final location = geometry?['location'];
          final lat = location?['lat'];
          final lng = location?['lng'];

          places.add({
            'placeId': placeId,
            'description': prediction['description'],
            'lat': lat,
            'lng': lng,
          });
        }
      }

      return places;
    } else {
      throw Exception('Failed to load predictions');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          decoration: InputDecoration(
            hintText: 'Search location',
            border: InputBorder.none,
          ),
          onChanged: (value) async {
            if (value.isNotEmpty) {
              final predictions = await _getPlacePredictions(value);
              setState(() {
                _placePredictions = predictions;
              });
            } else {
              setState(() {
                _placePredictions = [];
              });
            }
          },
        ),
      ),
      body: ListView.builder(
        itemCount: _placePredictions.length,
        itemBuilder: (context, index) {
          final prediction = _placePredictions[index];
          final structuredFormatting = prediction['structured_formatting'];
          final secondaryText = structuredFormatting != null && structuredFormatting.containsKey('secondary_text') ? structuredFormatting['secondary_text'] : '';

          final geometry = prediction['geometry'];
          final location = geometry?['location'];
          final double? latitude = location?['lat'];
          final double? longitude = location?['lng'];

          return Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: Colors.blueAccent,
                ),
                title: Text(prediction['description']),
                subtitle: Text(secondaryText),
                onTap: () {
                  Navigator.pop(context, {
                    'placeName': prediction['description'],
                    'placeLat': latitude,
                    'placeLng': longitude,
                  });
                },
              ),
              Divider(
                color: Colors.black54,
              ),
            ],
          );
        },
      ),
    );
  }
}
