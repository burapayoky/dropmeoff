import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropmeoff/models/user.data.dart';
import 'package:dropmeoff/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:fluttertoast/fluttertoast.dart';

class RegisterationPage extends StatefulWidget {

  static const String idScreen = 'Register';
  @override
  State<RegisterationPage> createState() => _RegisterationPageState();
}

class _RegisterationPageState extends State<RegisterationPage> {
  //controller
  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final typeTextEditingController = TextEditingController(text: 'User');
  final _formkey =GlobalKey<FormState>();


  final Future<FirebaseApp>firebase=Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase
    ,builder: (context, snapshot) {
        if(snapshot.hasError){
          return Scaffold(appBar: AppBar(title: Text('Error'),),
          body: Center(child: Text('${snapshot.error}')));
        }
        if(snapshot.connectionState ==ConnectionState.done){
          return Scaffold(
              resizeToAvoidBottomInset: false,
              body:  Center(
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      //logo
                      Text(
                        'สมัครสมาชิก',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 24,
                        ),
                      ),
                      //name
                    SizedBox(
                      height: 25,
                    )
                      ,
                      TextField(
                        controller: nameTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'ชื่อ',
                          labelStyle: TextStyle(fontSize: 14.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade400)
                          ),
                          fillColor: Colors.grey.shade200,
                          filled:true,
                        ),

                      ),

                      //email
                      TextField(
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(fontSize: 14.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade400)
                          ),
                          fillColor: Colors.grey.shade200,
                          filled:true,
                        ),

                      ),

                      TextField(
                        controller: phoneTextEditingController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'เบอร์โทรศััพท์',
                          labelStyle: TextStyle(fontSize: 14.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade400)
                          ),
                          fillColor: Colors.grey.shade200,
                          filled:true,
                        ),

                      ),
                      TextField(
                        controller: passwordTextEditingController,
                        obscureText: true,
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
                          filled:true,
                        ),

                      ),DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: 'ประเภทผู้ใช้'
                          ,
                        ),
                        value: typeTextEditingController.text,
                        onChanged: (value) {
                          setState(() {
                            typeTextEditingController.text = value.toString();
                          });
                        },
                        items: <String>['Driver', 'User']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        height: 50,
                        width: 300,
                        child: ElevatedButton(

                          style: TextButton.styleFrom(

                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(24.0)
                              )
                          ),

                          onPressed: registerNewUser,
                          child: Container(
                            height: 50,
                            child: Center(
                              child: Text(
                                'สร้างบัญชี',
                                style: TextStyle(fontSize: 18,

                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      TextButton(
                          onPressed: (){
                            Navigator.pushNamed(context,LoginPage.idScreen,);
                          },
                          child: Text(
                            'มีบัญชีเเล้ว?. เข้าสู่ระบบ',
                            style: TextStyle(color: Colors.black),
                          )
                      )
                      //Sign-in-button

                    ],
                  ),
                ),
              )
          );
        }
        return Scaffold(appBar: AppBar(title: Text('Error'),),
            body: Center(child: CircularProgressIndicator()));
    });
   /* */
  }

  void registerNewUser() async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextEditingController.text,
          password: passwordTextEditingController.text).then((value) {

        if (typeTextEditingController.text.trim() == 'Driver') {
          addDriverDetails(
            nameTextEditingController.text.trim(),
            emailTextEditingController.text.trim(),
            phoneTextEditingController.text.trim(),
            typeTextEditingController.text.trim(),
          );
        } else {
          addUserDetails(
            nameTextEditingController.text.trim(),
            emailTextEditingController.text.trim(),
            phoneTextEditingController.text.trim(),
            typeTextEditingController.text.trim(),
          );
        }
        Fluttertoast.showToast(
          msg: "สร้างบัญชีผู้ใช้สำเร็จ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.grey[400],
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) {
          return LoginPage();
        }));
      });
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: "ไม่สามารถสร้างบัญชีผู้ใช้ได้: ${e.message}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.grey[400],
        textColor: Colors.black54,
        fontSize: 16.0,
      );
    }
  }
  Future<void> addUserDetails(String name, String email, String phone, String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docUser = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await docUser.set({
        'email': email,
        'name': name,
        'phone': phone,
        'type': type,
      });
    }
  }
  Future<void> addDriverDetails(String name, String email, String phone, String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docUser = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await docUser.set({
        'email': email,
        'name': name,
        'phone': phone,
        'type': type,
        'points':0,
      });
    }
  }

}


