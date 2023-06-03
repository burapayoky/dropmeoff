import 'package:flutter/cupertino.dart';
import 'package:dropmeoff/models/directions.dart';

class AppInfo extends ChangeNotifier
{
  Directions? userPickUpLocation, userDropOffLocation;


  void updatePickUpLocationAddress(Directions userPickUpAddress)
  {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }
  void updateDropOffLocationAddress(Directions userdropOffAddress)
  {
    userDropOffLocation = userdropOffAddress;
    notifyListeners();
  }

}