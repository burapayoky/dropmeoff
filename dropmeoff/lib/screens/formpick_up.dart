import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropmeoff/models/directions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../component/cancel_dialog.dart';
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

class FormPickupScreen extends StatefulWidget {
  final String startLocationName;
  final double startLocationLat;
  final double startLocationLng;

  const FormPickupScreen({
    Key? key,
    required this.startLocationName,
    required this.startLocationLat,
    required this.startLocationLng,
  }) : super(key: key);

  @override
  State<FormPickupScreen> createState() => _FormPickupScreenState();
}

class _FormPickupScreenState extends State<FormPickupScreen> {
  late  TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  late TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
  bool isNumeric(String value) {
    if (value == null) {
      return false;
    }
    return double.tryParse(value) != null;
  }
  String _endLocationName = '';
  double _endLocationLat = 0.0;
  double _endLocationLng = 0.0;
  String _username = '';
  String _phoneNumber = '';
  String  _details= '';
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
    _selectedLocation = _geolocations[0];
    _pickupController = TextEditingController(text: widget.startLocationName);
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
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เรียกรถ'),
      ),
      body: Padding(
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
                ),
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
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _endLocationName = _selectedLocation.name;
                    _endLocationLat = _selectedLocation.latitude;
                    _endLocationLng = _selectedLocation.longitude;
                    _username = _usernameController.text;
                    _details = _detailsController.text;
                    _phoneNumber = _phoneNumberController.text;

                    final user = FirebaseAuth.instance.currentUser;
                    final uid = user!.uid;
                    final now = DateTime.now();
                    final thailand = now.toUtc().add(Duration(hours: 7));
                    final formattedDateTime =
                        'เวลา ${thailand.hour.toString().padLeft(2, '0')}:${thailand.minute.toString().padLeft(2, '0')} วันที่ ${thailand.year}-${thailand.month.toString().padLeft(2, '0')}-${thailand.day.toString().padLeft(2, '0')}';
                    // Create a new document in the "requests" collection with the form data
                    final docRef = await FirebaseFirestore.instance.collection('requests').add({
                      'startLocationName': widget.startLocationName,
                      'startLocationLat': widget.startLocationLat,
                      'startLocationLng': widget.startLocationLng,
                      'endLocationName': _endLocationName,
                      'endLocationLat': _endLocationLat,
                      'endLocationLng': _endLocationLng,
                      'phoneNumber': _phoneNumber,
                      'details': _details,
                      'status': 'waiting',
                      'uid': uid,
                      'Time': formattedDateTime,
                    });
                    // Show the finding driver dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return CancelDialog(
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
                          name: widget.startLocationName,
                          latitude: widget.startLocationLat,
                          longitude: widget.startLocationLng,
                        );
                        final endLocation = ALocation(
                          name: _endLocationName,
                          latitude: _endLocationLat,
                          longitude: _endLocationLng,
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TravelScreen(
                              requestId: docRef.id,
                              startLocationName: widget.startLocationName,
                              startLocationLat: widget.startLocationLat,
                              startLocationLng: widget.startLocationLng,
                              endLocationName: _endLocationName,
                              endLocationLat: _endLocationLat,
                              endLocationLng: _endLocationLng,
                              phone: _phoneNumber,
                              uid: uid,
                              traveltype: 'user',
                              details: _details,
                            ),
                          ),
                        );
                      }
                    });
                  }
                },
                child: Text('เรียกรถ'),
              ),



            ],
          ),
        ),
      ),
    );
  }

}
