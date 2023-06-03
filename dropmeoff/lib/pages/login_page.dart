import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropmeoff/pages/driver_homescreen.dart';
import 'package:dropmeoff/pages/homescreen.dart';
import 'package:dropmeoff/screens/driver_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'registeration_page.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static const String idScreen = 'login';


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    //logo
                    Image.asset(
                      'images/Logos.png',
                      height: 200,
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    Text(
                      'ติดรถเพื่อน',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 50,
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),
                    TextField(
                      controller: emailTextEditingController,
                      obscureText: false,
                      key: ValueKey(1),
                      decoration: InputDecoration(
                        labelText: 'email',
                        labelStyle: TextStyle(fontSize: 14.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400)
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      key: ValueKey(222),
                      decoration: InputDecoration(
                        labelText: 'รหัสผ่าน',
                        labelStyle: TextStyle(fontSize: 14.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400)
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                      ),

                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(fontSize: 20,),
                          ),
                        ),
                      ],
                    ),*/
                    //Sign-in-button
                    const SizedBox(
                      height: 5,
                    ),

                    SizedBox(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(

                        style: TextButton.styleFrom(

                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(24.0)
                            )
                        ),
                        //sign IN
                        onPressed: signUser,
                        child: Container(
                          height: 50,
                          child: Center(
                            child: Text(
                              'เข้าสู่ระบบ',
                              style: TextStyle(fontSize: 18,

                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context, MaterialPageRoute(builder: (context) {
                            return RegisterationPage();
                          })); //change Screen
                        },
                        child: Text(
                          'สมัครสมาชิก',
                          style: TextStyle(color: Colors.black),
                        )
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void signUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: emailTextEditingController.text,
          password: passwordTextEditingController.text);

      String uid = userCredential.user!.uid;
      print('UID: $uid');
      // Get user data from Firestore and navigate to appropriate screen based on type
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userData.exists) {
        String userType = userData['type'];
        if (userType == 'User') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else if (userType == 'Driver') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => DriverHomeScreen()));
        } else {
          showToast("User data is invalid or missing type field.");
        }
      } else {
        showToast("ไม่พบข้อมูลผู้ใช้ในระบบ");
      }
    } on FirebaseAuthException catch (e) {
      showToast(e.message ?? "An error occurred, please try again later.");
    }
  }

  void showToast(String message) {
    String customMessage;
    if (message.contains('The email address is badly formatted')) {
      customMessage = 'รูปเเบบ email ไม่ถูกต้อง';
    }else if (message.contains('The password is invalid or the user does not have a password')) {
      customMessage = 'รหัสผ่านไม่ถูกต้อง หรือ ยังไม่ได้กรอกรหัสผ่าน';
    }
    else {
      customMessage = message;
    }
    Fluttertoast.showToast(
        msg: customMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }


}
