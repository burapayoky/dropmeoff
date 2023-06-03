import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../component/my_drawer.dart';
class TravelHistoryScreen extends StatefulWidget {
  const TravelHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TravelHistoryScreen> createState() => _TravelHistoryScreenState();
}

class _TravelHistoryScreenState extends State<TravelHistoryScreen> {
  final CollectionReference _referenceRequests = FirebaseFirestore.instance.collection('requests');
  late User? user;
  late String uid;
  GlobalKey<ScaffoldState> sKey =GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    uid = user != null ? user!.uid : 'N/A';
    print(uid);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      appBar:AppBar(
        title: Text('ประวัติการเดินทาง'),
        centerTitle: true,
        leading: Positioned(
          top: 50,
          left: 14,
          child: GestureDetector(
            onTap: () {
              sKey.currentState!.openDrawer();
            },

              child: Icon(
                Icons.menu,
                color: Colors.black54,
              ),

          ),
        ),

      ),
      drawer: MyDrawer(name: 'burapa', email:'m'),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh the data from the database
          setState(() {});
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: _referenceRequests
              .where('status', isEqualTo: 'done')
              .where('uid', isEqualTo: uid)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            final List<QueryDocumentSnapshot<Object?>> documents = snapshot.data!.docs;
            if (documents.isEmpty) {
              return Center(child: Text('No data available'));
            }

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                final Map<String, dynamic>? data = documents[index].data() as Map<String, dynamic>?;
                if (data == null) {
                  return ListTile(
                    title: Text('Document $index is empty'),
                  );
                }

                final String requestId = data['id'] ?? '';
                final String startLocationName = data['startLocationName'] ?? '';
                final String endLocationName = data['endLocationName'] ?? '';
                final String feedback = data['feedback'] != null ? data['feedback'] : 'ไม่มีข้อเสนอเเนะ';
                final double rating = (data['rating'] ?? 0).toDouble();
                final String drivername = data['drivername'] ?? '';
                final String Datetime = data['Time'] ?? '';

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {

                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '$Datetime',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 20.0,color: Colors.blue,),
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
                              Icon(Icons.account_circle, size: 20.0,color: Colors.black,),
                              SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  'คนขับ: $drivername ',
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
                          SizedBox(height: 10.0),
                          Row(
                            children: [
                              Icon(Icons.comment, size: 20.0,color: Colors.white54,),
                              SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  'ข้อเสนอเเนะ: $feedback ',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black54
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, size: 20.0, color: Colors.yellow,),
                              SizedBox(width: 8.0),
                              Container(
                                padding: EdgeInsets.only(left: 4.0), // Add left padding to "Rating" Text widget
                                child: Text(
                                  'Rating:',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black54
                                  ),
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  rating.round(),
                                      (index) => Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 20.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );

  }
}