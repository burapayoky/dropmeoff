import 'package:dropmeoff/pages/homescreen.dart';
import 'package:dropmeoff/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key ,required this.name,required this.email}) : super(key: key);
  final String? name;
  final String? email;
  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    _user = await _auth.currentUser;
    setState(() {});
  }
  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: _user != null ? Text(_user!.displayName ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)) : null,
            accountEmail: _user != null ? Text(_user!.email ?? '',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)) : null,
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),

          Center(
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: _logout,
            ),
          ),
        ],
      ),
    );
  }
}
