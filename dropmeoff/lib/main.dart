import 'package:dropmeoff/infoHandler/app_info.dart';
import 'package:dropmeoff/pages/homescreen.dart';
import 'package:dropmeoff/pages/login_page.dart';
import 'package:dropmeoff/pages/registeration_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(

          primarySwatch: Colors.blue,
        ),
        initialRoute: LoginPage.idScreen,
        routes: {
          RegisterationPage.idScreen: (context) => RegisterationPage(),
          LoginPage.idScreen: (context) => LoginPage(),
          HomeScreen.idScreen:(context) => HomeScreen(),
        },
      ),
    );
  }
}


