import 'package:dropmeoff/screens/travel_history_screen.dart';
import 'package:dropmeoff/screens/user_accept_screen.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:dropmeoff/screens/pickme_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String idScreen = "homeScreen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex =0;
  static final List<Widget> _widgetOptions = <Widget>[
    PickmeScreen(),
    UserAcceptScreen(),
    TravelHistoryScreen()
  ];
  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
      setState(() {
        _selectedIndex = index;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
          child: _widgetOptions[_selectedIndex],),



      bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      elevation: 10,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      selectedItemColor: Colors.blue,
      unselectedItemColor: const Color(0xFF526480),
      type: BottomNavigationBarType.shifting,
      items: [
        BottomNavigationBarItem(icon: Icon(FluentSystemIcons.ic_fluent_home_regular),
            activeIcon: Icon(FluentSystemIcons.ic_fluent_home_filled),label: "หน้าหลัก"),

        BottomNavigationBarItem(icon: Icon(FluentSystemIcons.ic_fluent_person_accounts_filled),
            activeIcon: Icon(FluentSystemIcons.ic_fluent_person_accounts_filled),label: "ติดรถไปด้วย"),
        BottomNavigationBarItem(icon: Icon(FluentSystemIcons.ic_fluent_list_regular),
            activeIcon: Icon(FluentSystemIcons.ic_fluent_list_regular),label: "ประวัติบริการ"),
      ],
    ),
    );
  }
}
