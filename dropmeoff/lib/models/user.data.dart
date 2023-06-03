import 'package:cloud_firestore/cloud_firestore.dart';

class OurUser{
  String uid;
  String email;
  String name;
  String phone;
  Timestamp accoutCreated;

  OurUser({
    required this.uid,required this.email,required this.name,required this.phone,required this.accoutCreated,});
}