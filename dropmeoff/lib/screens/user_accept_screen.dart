import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropmeoff/pages/driver_travel_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../component/my_drawer.dart';
import '../pages/travel_screen.dart';
class UserAcceptScreen extends StatefulWidget {
  const UserAcceptScreen({Key? key}) : super(key: key);

  @override
  State<UserAcceptScreen> createState() => _UserAcceptScreenState();
}

class _UserAcceptScreenState extends State<UserAcceptScreen> {
  GlobalKey<ScaffoldState> sKey =GlobalKey<ScaffoldState>();
  final CollectionReference _referenceRequests = FirebaseFirestore.instance.collection('driverrequests');
  late String uid;
  late TextEditingController _phoneNumberController = TextEditingController();
  late String newUid;
  late String _phone = '';
  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    uid = user!.uid;
    _getPhone();
  }
  Future<void> _getPhone() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snapshot.data();
    if (data != null) {
      setState(() {
        _phone = data['phone'] ?? '';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      drawer: MyDrawer(name: 'burapa', email:'burapav2'),
      body: Stack(
        children:[
          RefreshIndicator(
          onRefresh: () async {
            // Refresh the data from the database
            setState(() {});
          },
          child:
          StreamBuilder<QuerySnapshot>(
            stream: _referenceRequests.where('status', isEqualTo: 'waiting').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              final List<QueryDocumentSnapshot<Object?>> documents = snapshot.data!.docs;
              if (documents.isEmpty) {
                return Center(
                  child: Text(
                    'ไม่การให้บริการ',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.only(top: 55),
                child: ListView.builder(

                  itemCount: documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic>? data = documents[index].data() as Map<String, dynamic>?;
                    if (data == null) {
                      print('Error: Document $index is empty');
                      return ListTile(
                        title: Text('Document $index is empty'),
                      );
                    }

                    final String requestId = documents[index].id;
                    print('Request ID: $requestId');
                    final String startLocationName = data['startLocationName'] ?? '';
                    final double startLocationLat = data['startLocationLat'] ?? 0.0;
                    final double startLocationLng = data['startLocationLng'] ?? 0.0;
                    final String endLocationName = data['endLocationName'] ?? '';
                    final double endLocationLat = data['endLocationLat'] ?? 0.0;
                    final double endLocationLng = data['endLocationLng'] ?? 0.0;
                    final String phoneNumber =data['phoneNumber'] ?? '';
                    final String details = data['detail'] ?? '';

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('ยืนยันจะติดรถไปด้วย'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('ยกเลิก'),
                                  ),
                                  TextButton(
                                    ////////////////////////////////////////async
                                    onPressed: () async{
                                      print('$requestId');
                                      if (requestId.isEmpty) {
                                        // Handle the error here, e.g. show a dialog or return
                                        print('Error: Request ID is empty');
                                        return;
                                      }
                                      final requestReference = FirebaseFirestore.instance.collection('driverrequests').doc(requestId);
/////////////////////////////////////////////////////////////
                                      final requestSnapshot = await requestReference.get();
                                      final requestData = requestSnapshot.data();

                                      if (requestData != null && requestData['status'] == 'accept') {
                                        // The ride request has already been accepted by another driver.
                                        // Handle this case as desired, e.g. show an error message.
                                        Navigator.of(context).pop();
                                        return;
                                      }
                                      /////////////
                                      try {
                                        await requestReference.update({'status': 'accept'});
                                        await requestReference.update({'userId': uid});
                                        await requestReference.update({'userphone': _phone});

                                      } catch (e) {
                                        // Handle errors here, e.g. show a snackbar or dialog
                                        print('Error updating request status: $e');
                                        return;
                                      }
                                      /////////////////////////////////////////////////////
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DriverTravelScreen(
                                            requestId: requestId,
                                            startLocationName: startLocationName,
                                            startLocationLat: startLocationLat,
                                            startLocationLng: startLocationLng,
                                            endLocationName: endLocationName,
                                            endLocationLat: endLocationLat,
                                            endLocationLng: endLocationLng,
                                            phone: phoneNumber,
                                            details: details,
                                            uid: uid,
                                            traveltype:'user',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text('ยืนยัน'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child:ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 20.0,color: Colors.green,),
                                  SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      'จาก: $startLocationName ',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black54
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 20.0,color: Colors.red,),
                                  SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      'ปลายทาง: $endLocationName ',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black54
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),Positioned(
          top: 50,
          left: 14,
          child: GestureDetector(
            onTap: () {
              sKey.currentState!.openDrawer();
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.menu,
                color: Colors.black54,
              ),
            ),
          ),
        ),],
      ),
    );
  }
}
