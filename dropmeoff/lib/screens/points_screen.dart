import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../component/my_drawer.dart';
class MypointsScreen extends StatefulWidget {
  const MypointsScreen({Key? key}) : super(key: key);

  @override
  State<MypointsScreen> createState() => _MypointsScreenState();
}

class _MypointsScreenState extends State<MypointsScreen> {
  final CollectionReference _referenceUser = FirebaseFirestore.instance.collection('users');
  GlobalKey<ScaffoldState> sKey =GlobalKey<ScaffoldState>();
  late String uid;
  late User? user;
  int _points = 0;
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    uid = user != null ? user!.uid : 'N/A';
    print(uid);

    // Step 2: Retrieve user's points from Firestore
    _referenceUser.doc(uid).get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _points = (snapshot.data() as Map<String, dynamic>)['points'] ?? 0;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      appBar: AppBar(
        title: Text('ดูเเต้มสะสม'),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
            ),
            child: Center(
              child: Text(
                'คุณมีเเต้มสะสมทั้งหมด: $_points เเต้ม ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                // Replace with your product widgets
                _buildProductWidget('อาหารร้านป้า 1 เมนู', 'images/food1.jpeg'),
                _buildProductWidget('กะเพราหอม 1 จาน', 'images/food2.jpeg'),
                _buildProductWidget('มอคค่ามิ้น 1 เเก้ว', 'images/water1.jpg'),
                _buildProductWidget('Cocao stawaberry 1 เเก้ว', 'images/water2.jpeg'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductWidget(String name, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
