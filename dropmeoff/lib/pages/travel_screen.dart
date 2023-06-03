import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropmeoff/components/constants.dart';
import 'package:dropmeoff/global/map_key.dart';
import 'package:dropmeoff/pages/driver_homescreen.dart';
import 'package:dropmeoff/pages/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../assistants/directions_repository.dart';
import '../screens/rating_screen.dart';
class TravelScreen extends StatefulWidget {
  final String requestId;
  final String startLocationName;
  final double startLocationLat;
  final double startLocationLng;
  final String endLocationName;
  final double endLocationLat;
  final double endLocationLng;
  final String uid;
  final String phone;
  final String traveltype;
  final String details;


  const TravelScreen({
    Key? key,
    required this.requestId,
    required this.startLocationName,
    required this.startLocationLat,
    required this.startLocationLng,
    required this.endLocationName,
    required this.endLocationLat,
    required this.endLocationLng,
    required this.uid,
    required this.traveltype, required this.phone, required this.details,
  }) : super(key: key);

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  late GoogleMapController _mapController;
  late Position _currentPosition;
  bool _isMyLocationButtonEnabled = false;
  final Set<Marker> _markers = {};
  List<LatLng> _polylines = [];
  late LatLng _startLatLng;
  late LatLng _endLatLng;
  double showtraveldataHeight =410;
  double bottomPaddingOfMap = 0;
  late Location _location;
  late String _driverphone= '';
  late StreamSubscription<LocationData> _locationSubscription;
  late StreamSubscription<DocumentSnapshot> _requestStreamSubscription;
  LatLng _currentLatLng = LatLng(0, 0);
  late String drivername;
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      bottomPaddingOfMap =180;
    });
    _markers.add(Marker(
      markerId: MarkerId('currentLocation'),
      position: _currentLatLng,
    ));
  }
  Future<void> _getPhone() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('requests').doc(widget.requestId).get();
    final data = snapshot.data();
    if (data != null) {
      setState(() {
        _driverphone = data['driverphone'] ?? '';
        drivername =data['drivername'] ?? '';
      });
    }
  }


  void _getPolylines() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        mapkey,
        PointLatLng(_startLatLng.latitude, _startLatLng.longitude),
        PointLatLng(_endLatLng.latitude, _endLatLng.longitude)
    );
    if(result.points.isNotEmpty){
      result.points.forEach(
              (PointLatLng point) => _polylines.add(LatLng(point.latitude, point.longitude))
      );
    }
    setState(() {

    });

  }
  @override
  void initState() {
    _startLatLng = LatLng(widget.startLocationLat, widget.startLocationLng);
    _endLatLng = LatLng(widget.endLocationLat, widget.endLocationLng);
    _getPolylines();
    super.initState();
    _location = Location();
    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      setState(() {
        _currentLatLng = LatLng(locationData.latitude!, locationData.longitude!);
      });
    });
    //getphone
    _getPhone();
    //getCurrentLocation();
    //_addMarkers();
    //check  state done user
    final requestRef = FirebaseFirestore.instance.collection('requests').doc(widget.requestId);

    _requestStreamSubscription = requestRef.snapshots().listen((snapshot) {
      if (snapshot.data() != null && snapshot.data()!['status'] == 'done' && widget.traveltype == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RatingScreen(requestId: widget.requestId)),
        );
      }
    });
  }
  @override
  void dispose() {
    _locationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เดินทาง'),
        automaticallyImplyLeading: false,
      ),
      body:SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GoogleMap(
                padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _startLatLng,
                  zoom: 15.6,
                ),//_markers
                polylines:{
                  Polyline(polylineId: PolylineId('route'),
                  points: _polylines,
                    color: primaryColor,
                    width: 6,
                  ),
                },
                markers: {
                  Marker(
                    markerId: MarkerId('start'),
                    position: _startLatLng,
                  ),
                  Marker(
                    markerId: MarkerId('end'),
                    position: _endLatLng,
                  ),
                },
                myLocationButtonEnabled: _isMyLocationButtonEnabled,
                myLocationEnabled: _isMyLocationButtonEnabled,
                onCameraMove: (CameraPosition position) {
                  _isMyLocationButtonEnabled = true;
                },
              ),
            ),
            widget.traveltype == 'user' ?
            Positioned(
              bottom: 0,
              left: 0,
              right:0,
              child: AnimatedSize(
                curve: Curves.easeIn,
                duration: Duration(milliseconds: 250),
                child: Container(
                  height: 370,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ต้นทาง:",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.place, color: primaryColor),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    widget.startLocationName,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16.0,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ปลายทาง:",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.place, color: primaryColor),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    widget.endLocationName,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ลายละเอียด:",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.chat, color: primaryColor),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    widget.details,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ///////////////////////////////////////
                        SizedBox(height: 16),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ผู้ให้บริการ",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.account_circle, color: primaryColor),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(drivername,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Spacer(),
                                ElevatedButton(onPressed: (){
                                  FlutterPhoneDirectCaller.callNumber(_driverphone);
                                }, child: Icon(Icons.phone,color: Colors.black54,),)
                              ],
                            ),
                          ],
                        ),
                        //////////////////////////////////////
                        SizedBox(height: 16),




                      ],
                    ),
                  ),
                ),
              ),
            )
            :widget.traveltype =='driver'?
            Positioned(
              bottom: 0,
              left: 0,
              right:0,
              child: AnimatedSize(
                curve: Curves.easeIn,
                duration: Duration(milliseconds: 160),
                child: Container(
                  height: showtraveldataHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ต้นทาง:",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.place, color: primaryColor),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    widget.startLocationName,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16.0,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ปลายทาง:",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.place, color: primaryColor),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    widget.endLocationName,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 16),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ลายละเอียด:",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.chat, color: primaryColor),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    widget.details,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 16),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "เบอร์ติดต่อ:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.phone_android, color: primaryColor),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(widget.phone,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    Spacer(),
                                    ElevatedButton(onPressed: (){
                                      FlutterPhoneDirectCaller.callNumber(widget.phone);
                                    }, child: Icon(Icons.phone,color: Colors.black54,),)
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                child: Text("จบการเดินทาง"),
                                onPressed: () {
                                  FirebaseFirestore.instance.collection('requests').doc(widget.requestId).update({
                                    'status': 'done',
                                  }).then((value) {
                                    // Handle success here
                                  }).catchError((error) {
                                    // Handle error here
                                  });
                                  if(widget.traveltype=='driver'){
                                    Navigator.pop(context); // Pop the DriverNotFoundDialog
                                    Navigator.pushReplacement( // Navigate to the HomeScreen
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DriverHomeScreen(),
                                      ),
                                    );
                                  }
                                  // handle button click for driver travel type
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                  textStyle: const TextStyle(fontSize: 15),
                                ),
                              ),
                            )
                          ],

                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
                :SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

/*void _getCurrentLocation() async {
    final currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = currentPosition;
      _isMyLocationButtonEnabled = true;
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition.latitude,
              _currentPosition.longitude,
            ),
            zoom: 15,
          ),
        ),
      );
    });
  }
  LocationData? currentLocation;

  void getCurrentLocation(){
    Location location =Location();
    location.getLocation().then(
          (location) {
        currentLocation =location;
      },
    );
    print(currentLocation);
  }
  */
/*

* */