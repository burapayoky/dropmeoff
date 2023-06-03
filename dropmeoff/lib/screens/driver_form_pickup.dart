import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropmeoff/pages/driver_travel_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../assistants/assistant_methods.dart';
import '../component/cancel_dialog.dart';
import '../component/user_cancel_dialog.dart';
import '../pages/travel_screen.dart';
class ALocation {
  final String name;
  final double latitude;
  final double longitude;

  ALocation({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}
class DriverFrompickup extends StatefulWidget {
  const DriverFrompickup({Key? key}) : super(key: key);

  @override
  State<DriverFrompickup> createState() => _DriverFrompickupState();
}

class _DriverFrompickupState extends State<DriverFrompickup> {
  late TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  late TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _startLocationName;
  double? _startLocationLat;
  double? _startLocationLng;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();
  GoogleMapController?  newGoogleMapController;//googlemaps controller
  late ALocation _selectedLocation;
  final List<ALocation> _geolocations = [
    ALocation(
      name: 'อาคารเรียนรวม 5',
      latitude: 18.801118230050697,
      longitude: 98.95264514357598,
    ),
    ALocation(
      name: 'คณะมนุษยศาสตร์',
      latitude: 18.803634678207988,
      longitude: 98.9509344952787,
    ),
    ALocation(
      name: 'วิศวะ',
      latitude: 18.79620486731312,
      longitude: 98.95281404520136,
    ),
    ALocation(
      name: 'คณะวิจิตรศิลป์',
      latitude: 18.793035477490776,
      longitude: 98.95808501264203,
    ),
    ALocation(
      name: 'คณะบริหารธุรกิจ',
      latitude: 18.794131393617395,
      longitude: 98.95698816379209,
    ),
    ALocation(
      name: 'คณะสถาปัตยกรรมศาสตร์',
      latitude: 18.798340185677514,
      longitude: 98.94924548559858,
    ),
    ALocation(
      name: 'คณะการสื่อสารมวลชน',
      latitude: 18.80156253669052,
      longitude: 98.94752157097845,
    ),

  ];
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  GlobalKey<ScaffoldState> sKey =GlobalKey<ScaffoldState>();
  //double searchLocationContainerHeight =220.0;
  Position? userCurrentPosition;
  static const LatLng destination = LatLng(18.79620486731312, 98.95281404520136);


  var geoLocator = Geolocator();
  //map permission
  LocationPermission? _locationPermission;
  Future<bool> checkIfLocationPermissionAllowed() async {
    final permissionStatus = await Permission.locationWhenInUse.status;
    if (permissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      final permissionResult = await Permission.locationWhenInUse.request();
      return permissionResult == PermissionStatus.granted;
    }

  }
  locateUserPosition() async{
    bool locationPermissionAllowed = await checkIfLocationPermissionAllowed();
    if (locationPermissionAllowed) {
      Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      userCurrentPosition =cPosition;

      LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      CameraPosition cameraPosition =CameraPosition(target: latLngPosition,zoom: 14);
      newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(userCurrentPosition!, context);
      print("this is your address = " + humanReadableAddress);

      setState(() {
        _startLocationName = humanReadableAddress;
        _startLocationLat = userCurrentPosition!.latitude;
        _startLocationLng = userCurrentPosition!.longitude;
        _pickupController = TextEditingController(text: _startLocationName);
        print(_startLocationName);
        print(_startLocationLng);
        print(_startLocationLat);
      });
    } else {
      print('Location permission not allowed');
    }
  }
  bool isNumeric(String value) {
    if (value == null) {
      return false;
    }
    return double.tryParse(value) != null;
  }
  ///data
  late String newUid;
  late User? usercerrent;
  final CollectionReference _referenceUser = FirebaseFirestore.instance.collection('users');
  late String currentphone ;
  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _initializePoints();

  }
  void _initializeLocation(){
    checkIfLocationPermissionAllowed();
    locateUserPosition();
    _selectedLocation = _geolocations[0];
  }
  void _initializePoints(){
    usercerrent = FirebaseAuth.instance.currentUser;
    newUid = usercerrent != null ? usercerrent!.uid : 'N/A';

    // Retrieve user's points from Firestore
    FirebaseFirestore.instance.collection('users').doc(newUid).get().then((docSnapshot) {
      if (docSnapshot.exists) {
        setState(() {
          currentphone = docSnapshot.data()!['phone'];
          _phoneNumberController =TextEditingController(text: currentphone);
        });
      }
    });
  }
  @override
  void dispose() {
    _destinationController.dispose();
    _usernameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('ให้บริการรถจักรยานยนต์'),
        automaticallyImplyLeading: false,
      ),
      body:Stack(
        children: [
          
          Offstage(
            child: GoogleMap(
              onMapCreated: (controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _pickupController,
                    decoration: InputDecoration(
                      labelText: 'จาก',
                    ),style: TextStyle(color: Colors.black),
                    enabled: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a pickup location';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<ALocation>(
                    value: _selectedLocation,
                    items: _geolocations.map((location) {
                      return DropdownMenuItem<ALocation>(
                        value: location,
                        child: Text(location.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'เลือกสถานที่',
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _detailsController,
                    decoration: InputDecoration(
                      labelText: 'รายละเอียดเพิ่มเติม',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ใส่รายละเอียดเพิ่มเติม';
                      }
                      return null;
                    },

                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'เบอร์โทรศัพท์',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!isNumeric(value)) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },

                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String _endLocationName = _selectedLocation.name;
                        double _endLocationLat = _selectedLocation.latitude;
                        double _endLocationLng = _selectedLocation.longitude;
                        String _username = _usernameController.text;
                        String _detail =_detailsController.text;
                        String _phoneNumber = _phoneNumberController.text;

                        final user = FirebaseAuth.instance.currentUser;
                        final uid = user!.uid;

                        // Create a new document in the "requests" collection with the form data
                        final docRef = await FirebaseFirestore.instance.collection('driverrequests').add({
                          'startLocationName': _startLocationName,
                          'startLocationLat': _startLocationLat,
                          'startLocationLng': _startLocationLng,
                          'endLocationName': _endLocationName,
                          'endLocationLat': _endLocationLat,
                          'endLocationLng': _endLocationLng,
                          'phoneNumber': _phoneNumber,
                          'detail':_detail,
                          'status': 'waiting',
                          'uid': uid,
                        });
                        // Show the finding driver dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return UserCancelDialog(
                              requestReference: docRef,
                              onStatusChange: (status) {
                                Fluttertoast.showToast(msg: 'Request $status');
                              },
                            );
                          },
                        );
                        docRef.snapshots().listen((snapshot) {
                          final status = snapshot.data()?['status'];

                          // If the status changes to "accept", navigate to the TravelScreen
                          if (status == 'accept') {
                            final startLocation = ALocation(
                              name: _startLocationName!,
                              latitude: _startLocationLat!,
                              longitude: _startLocationLng!,
                            );
                            final endLocation = ALocation(
                              name: _endLocationName,
                              latitude: _endLocationLat,
                              longitude: _endLocationLng,
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DriverTravelScreen(
                                  requestId: docRef.id,
                                  startLocationName: _startLocationName!,
                                  startLocationLat: _startLocationLat!,
                                  startLocationLng:_startLocationLng!,
                                  endLocationName: _endLocationName,
                                  endLocationLat: _endLocationLat,
                                  endLocationLng: _endLocationLng,
                                  phone: _phoneNumber,
                                  details: _detail,
                                  uid: uid,
                                  traveltype: 'driver',
                                ),
                              ),
                            );
                          }
                        });
                        /*Navigator.pushReplacement(
                          context,

                        );*/
                      }
                    },
                    child: Text('ให้บริการรถจักรยานยนต์'),
                  ),



                ],
              ),
            ),
          ),
        ],
      )

    );
  }
}
