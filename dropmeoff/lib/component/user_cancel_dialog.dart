import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropmeoff/pages/driver_homescreen.dart';
import 'package:flutter/material.dart';
class UserCancelDialog extends StatefulWidget {
  final DocumentReference requestReference;
  final Function(String) onStatusChange;
  const UserCancelDialog({ required this.requestReference, required this.onStatusChange});

  @override
  State<UserCancelDialog> createState() => _UserCancelDialogState();
}

class _UserCancelDialogState extends State<UserCancelDialog> {
  bool _isVisible = true;
  @override
  void initState() {
    super.initState();

    // Delay the execution of the onStatusChange callback by 30 seconds
    Future.delayed(Duration(minutes: 15)).then((value) async {
      if (_isVisible) {
        setState(() {
          _isVisible = false;
        });

        // Check if the request is still waiting for a driver
        final snapshot = await widget.requestReference.get();
        final data = snapshot.data() as Map<String, dynamic>?; // Cast to the expected type
        final status = data?['status'];
        if (status == 'waiting') {
          await widget.requestReference.update({'status': 'Failed to find User'});
          widget.onStatusChange('Failed to find User');
          Navigator.pop(context); // Pop the FormPickupScreen
          _showDriverNotFoundDialog();
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _isVisible,
      child: AlertDialog(
        title: Text("หาเพื่อนร่วมทาง"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isVisible = false;
                });
                await widget.requestReference.update({'status': 'Cancelled'});
                widget.onStatusChange('Cancelled');
                Navigator.pop(context); // Pop the FormPickupScreen
                Navigator.pushReplacement( // Navigate to the HomeScreen
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverHomeScreen(),
                  ),
                );
              },
              child: Text("ยกเลิก"),
            ),
          ],
        ),
      ),
    );
  }
  void _showDriverNotFoundDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 5)).then((value) {
          Navigator.pop(context); // Pop the DriverNotFoundDialog
          Navigator.pushReplacement( // Navigate to the HomeScreen
            context,
            MaterialPageRoute(
              builder: (context) => DriverHomeScreen(),
            ),
          );
        });

        return AlertDialog(
          title: Text("ไม่มีพบเพื่อนรวมทาง"),
          content: Text("เสียใจด้วย ไม่มีเพื่อนที่กำลังจะไปที่เดียวกับคุณ"),
        );
      },
    );
  }
}
