import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../pages/homescreen.dart';

class CancelDialog extends StatefulWidget {
  final DocumentReference requestReference;
  final Function(String) onStatusChange;
  const CancelDialog({required this.requestReference, required this.onStatusChange});


  @override
  State<CancelDialog> createState() => _CancelDialogState();
}
class _CancelDialogState extends State<CancelDialog> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    // Delay the execution of the onStatusChange callback by 30 seconds
    Future.delayed(Duration(seconds: 30)).then((value) async {
      if (_isVisible) {
        setState(() {
          _isVisible = false;
        });

        // Check if the request is still waiting for a driver
        final snapshot = await widget.requestReference.get();
        final data = snapshot.data() as Map<String, dynamic>?; // Cast to the expected type
        final status = data?['status'];
        if (status == 'waiting') {
          await widget.requestReference.update({'status': 'Failed to find driver'});
          widget.onStatusChange('Failed to find driver');
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
        title: Text("กำลังค้นหาคนขับรถ"),
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
                    builder: (context) => HomeScreen(),
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
              builder: (context) => HomeScreen(),
            ),
          );
        });

        return AlertDialog(
          title: Text("ไม่พบคนขับ"),
          content: Text("เสียใจด้วย ไม่มีเพื่อนที่กำลังจะไปที่เดียวกับคุณ"),
        );
      },
    );
  }

}