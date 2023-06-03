import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropmeoff/pages/homescreen.dart';
import 'package:flutter/material.dart';
class RatingScreen extends StatefulWidget {
  final String requestId;
  const RatingScreen({Key? key, required this.requestId}) : super(key: key);

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
  int _oldrating= 0;
  int _newrating = 0;
  String _feedback = "";
  String _driverId = "";
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('requests').doc(widget.requestId).get().then((snapshot) {
      setState(() {
        _driverId = snapshot.get('driverId');
        if (_driverId != null && _driverId.isNotEmpty) {
          FirebaseFirestore.instance.collection('users').doc(_driverId).get().then((snapshot) {
            setState(() {
              _oldrating = snapshot.get('points');
            });
          });
        }
      });
    });
    // Retrieve the driver's ID from the Firestore database
    /*FirebaseFirestore.instance.collection('requests').doc(widget.requestId).get().then((snapshot) {
      setState(() {
        _driverId = snapshot.get('uid');
      });
    });*/
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "ให้คะเเนนการเดินทาง",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "ให้คะเเนนการเดินทางครั้งนี้",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 1; i <= 5; i++)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _rating = i;
                          });
                        },
                        child: Icon(
                          i <= _rating ? Icons.star : Icons.star_border,
                          size: 40,
                          color: Colors.yellow[700],
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              Text(
                "ข้อเสนอเเนะ",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _feedback = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "เขียนข้อเสนอเเนะที่นี่ ...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async{
                  final requestReference = FirebaseFirestore.instance.collection('requests').doc(widget.requestId);
                  final userReference = FirebaseFirestore.instance.collection('users').doc(_driverId); // Replace userId with the ID of the user who is rating the driver

                  // Update the ride document with the rating and feedback data
                  await requestReference.update({
                    'rating': _rating,
                    'feedback': _feedback,
                  });

                  // Get the driver's ID from the ride document
                  final driverId = (await requestReference.get()).get('driverId');
                  final _newrating = _oldrating + _rating;
                  // Update the user's points in the users collection
                  await userReference.update({
                    'points':_newrating,
                  });
                  Navigator.pop(context); // Pop the DriverNotFoundDialog
                  Navigator.pushReplacement( // Navigate to the HomeScreen
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                  );
                  // Handle submit button press
                },
                child: Text(
                  "ยืนยัน",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*final Map<String, dynamic> data = {}; // replace this with your data from Firestore
                  final String driverId = data['driverId'] ?? '';
                  final driverReference = FirebaseFirestore.instance.collection('users').doc(driverId);*/
/*try {
                    await requestReference.update({
                      'rating': _rating,
                      'feedback': _feedback,
                    });
                  } catch (e) {
                    // Handle errors here, e.g. show a snackbar or dialog
                    print('Error updating request status: $e');
                    return;
                  }*/