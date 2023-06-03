import 'dart:async';

import 'package:dropmeoff/assistants/assistant_methods.dart';
import 'package:dropmeoff/component/my_drawer.dart';
import 'package:dropmeoff/infoHandler/app_info.dart';
import 'package:dropmeoff/pages/search_location_screen.dart';
import 'package:dropmeoff/screens/formpick_up.dart';
import 'package:dropmeoff/screens/search_places_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

//String? dropdownValue;
class PickmeScreen extends StatefulWidget {
  final String? name;
  final String? email;
  const PickmeScreen({Key? key, this.name, this.email}) : super(key: key);

  @override
  State<PickmeScreen> createState() => _PickmeScreenState();
}

class _PickmeScreenState extends State<PickmeScreen> {

  //ค่าส่งไป
  String? _startLocationName;
  double? _startLocationLat;
  double? _startLocationLng;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>(); //googlemaps controller
  GoogleMapController?  newGoogleMapController;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 15.55,
  );
  GlobalKey<ScaffoldState> sKey =GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight =155.0;
  Position? userCurrentPosition;
  var geoLocator = Geolocator();
  //map permission
  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  Future<bool> checkIfLocationPermissionAllowed() async {
    final permissionStatus = await Permission.locationWhenInUse.status;
    if (permissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      final permissionResult = await Permission.locationWhenInUse.request();
      return permissionResult == PermissionStatus.granted;
    }

  }

  locateUserPosition() async{
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition =cPosition;

    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition =CameraPosition(target: latLngPosition,zoom: 16);
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(userCurrentPosition!, context);
    print("this is your address = " + humanReadableAddress);

    //setค่าส่งไปform
    setState(() {
      _startLocationName = humanReadableAddress;
      _startLocationLat = userCurrentPosition!.latitude;
      _startLocationLng = userCurrentPosition!.longitude;
    });
  }
  @override
  void initState(){
    super.initState();
    checkIfLocationPermissionAllowed();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      drawer: MyDrawer(name: 'burapa', email:'burapav2'),
      body: Stack(

        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController=controller;

              setState(() {
                bottomPaddingOfMap =265;
              });
              locateUserPosition();
            },
          ),
          //hamburger Drawer
          Positioned(
            top: 28,left: 14,
            child: GestureDetector(
              onTap: ()
              {
                sKey.currentState!.openDrawer();
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(
                  Icons.menu,
                  color: Colors.black54,),
              ),
            ),
          )
          ,
          Positioned(
            bottom: 0,
            left: 0,
            right:0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: Duration(milliseconds: 120),
              child: Container(
                height: searchLocationContainerHeight,
                decoration:const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  )
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 18),
                  child: Column(
                    children: [
                      //
                      Row(

                        children: [
                          const Icon(Icons.add_location_alt_outlined,color: Colors.grey),
                          const SizedBox(width: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "จาก",
                                style: TextStyle(color: Colors.red,fontSize: 15),
                              ),
                              Text(
                                  Provider.of<AppInfo>(context).userPickUpLocation != null
                                      ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,24) + "..."
                                      : "not getting address",
                                  style: const TextStyle(color: Colors.grey, fontSize: 14)
                              ),

                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 10.0,),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16.0,),
                     /* GestureDetector(
                        onTap: () async{
                          final Map<String, dynamic>? result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SearchLocationScreen()),
                          );
                          if (result != null) {
                            setState(() {
                              double? endLocationLat = result['placeLat'];
                              double? endLocationLng = result['placeLng'];
                              String? endLocationName = result['placeName'];
                              print(endLocationLat);
                              print(endLocationLng);
                              print(endLocationName);
                              // Update the state with the selected place's name, latitude, and longitude
                            });
                          }
                          //หน้าค้นหาสถานที่

                        },
                        child: Row(
                          children: [
                            const Icon(Icons.add_location_alt_outlined,color: Colors.grey),
                            const SizedBox(width: 12.0,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "ไป",
                                  style: TextStyle(color: Colors.red,fontSize: 15),
                                ),
                                Text(
                                    "เลือกสถานที่",
                                    style: const TextStyle(color: Colors.grey, fontSize: 14)
                                ),
                              ],
                            )
                          ],
                        ),

                      ),
                      const SizedBox(height: 10.0,),*/

                      ElevatedButton(
                          child: Text(
                            "เรียกรถจักรยานยนต์"
                          ),
                          onPressed: ()
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FormPickupScreen(
                                  startLocationName: _startLocationName!,
                                  startLocationLat: _startLocationLat!,
                                  startLocationLng: _startLocationLng!,
                                ),
                              ),
                            );
                          },
                        style: ElevatedButton.styleFrom(primary: Colors.green,textStyle: const TextStyle(fontSize: 15)),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          )  //call car
        ],
      ),
    );
  }

}
