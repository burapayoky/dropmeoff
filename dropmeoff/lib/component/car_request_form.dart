import 'package:dropmeoff/assistants/assistant_methods.dart';
import 'package:dropmeoff/global/map_key.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class CarRequestForm extends StatefulWidget {
  const CarRequestForm({Key? key}) : super(key: key);

  @override
  State<CarRequestForm> createState() => _CarRequestFormState();
}

class _CarRequestFormState extends State<CarRequestForm> {
  String _startLocationName = '';
  double _startLocationLat = 0.0;
  double _startLocationLng = 0.0;
  String _endLocationName = '';
  double _endLocationLat = 0.0;
  double _endLocationLng = 0.0;
  String? _username;
  String? _phoneNumber;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Text('เรียกรถ'),
    ),
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value==null ||value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
              onSaved: (value) {
                _username = value;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'เบอร์โทรศัพท์',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value==null ||value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
              onSaved: (value) {
                _phoneNumber = value;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Starting Location',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value==null ||value.isEmpty) {
                  return 'Please enter a starting location';
                }
                return null;
              },
              onTap: () async {
                await _getCurrentLocation();
                String locationName = await _getLocationName(
                    _startLocationLat, _startLocationLng);
                setState(() {
                  _startLocationName = locationName;
                });
              },
              onSaved: (value) {
                if (value != null) {
                  _startLocationName = value;
                }
              },
              readOnly: true,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Ending Location',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value==null ||value.isEmpty) {
                  return 'Please enter an ending location';
                }
                return null;
              },
              onTap: () async {
                await _getCurrentLocation();
                String locationName = await _getLocationName(
                    _endLocationLat, _endLocationLng);
                setState(() {
                  _endLocationName = locationName;
                });
              },
              onSaved: (value) {
                if (value != null) {
                  _endLocationName = value;
                }
              },
              readOnly: true,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

                  try {
                    List<LatLng> polylineCoordinates = await PolylineDirections.getPolylineDirections(
                      LatLng(_startLocationLat, _startLocationLng),
                      LatLng(_endLocationLat, _endLocationLng),
                      '$mapkey',
                    );

                    await FirebaseFirestore.instance.collection('requests').add(
                      {
                        'startLocationName': _startLocationName,
                        'startLocationLat': _startLocationLat,
                        'startLocationLng': _startLocationLng,
                        'endLocationName': _endLocationName,
                        'endLocationLat': _endLocationLat,
                        'endLocationLng': _endLocationLng,
                        'username': _username,
                        'phoneNumber': _phoneNumber,
                        'uid': uid,
                        'status': 'pending',
                        'polylineCoordinates': polylineCoordinates
                            .map((coord) => [coord.latitude, coord.longitude])
                            .toList(),
                      },
                    );

                    Fluttertoast.showToast(msg: 'Request sent');
                    Navigator.pop(context);
                  } catch (e) {
                    Fluttertoast.showToast(msg: 'Error sending request');
                  }
                }


              },
            ),
          ],
        ),
      ),
    ),
    );
  }
  Future<void> _getCurrentLocation() async {
    bool locationPermissionGranted = await _requestLocationPermission();
    if (locationPermissionGranted) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _startLocationLat = position.latitude;
        _startLocationLng = position.longitude;
        _endLocationLat = position.latitude;
        _endLocationLng = position.longitude;
      });
    }
  }

  Future<bool> _requestLocationPermission() async {
    PermissionStatus permission = await Permission.locationWhenInUse.request();
    return permission == PermissionStatus.granted;
  }

  Future<String> _getLocationName(double latitude, double longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude, longitude);
    Placemark placemark = placemarks.first;
    return '${placemark.street}, ${placemark.locality}, ${placemark
        .administrativeArea}, ${placemark.country}';
  }

}

