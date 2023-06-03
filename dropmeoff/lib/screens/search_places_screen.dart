import 'package:dropmeoff/global/map_key.dart';
import 'package:dropmeoff/models/predicted_places.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../assistants/request_assistant.dart';
import '../component/place_prediction_tile.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  /*TextEditingController _controller = TextEditingController();
  var uuid =Uuid();
  String _sessionToken='122344';
  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      onChange();
    });
  }

  void onChange(){
   if(_sessionToken = uuid.v4){
     setState(() {
       _sessionToken=uuid.v4();
     });
   }
  }*/
  List<PredictedPlaces> placesPredictedList = [];


  Future<void> findPlaceAutoCompleteSearch(String inputText) async{
    if(inputText.length >1)
    {
      //place Api ค้นหาตำเเหน่ง
      String urlAutoCompleteSearch = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapkey&components=country:TH';
      //String urlAutoCompleteSearch = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapkey&location=18.7953,98.9524&radius=1000&components=country:TH';
      var responseAutoCompleteSearch =await RequestAssistant.receiveRequest(urlAutoCompleteSearch);
      //
      var reponsePlace= await http.get(Uri.parse(urlAutoCompleteSearch));
      //
      if(responseAutoCompleteSearch == "Error Occurred,Failed.No Response"){
        return;
      }
      //predictตำเเหน่ง
      if(responseAutoCompleteSearch["status"] == "OK")
      {
        var placePredictions = responseAutoCompleteSearch["predictions"];

        var placePredictionsList = (placePredictions as List).cast<Map<String, dynamic>>().map((json) => PredictedPlaces.fromJson(json)).toList();


        setState(() {
          placesPredictedList = placePredictionsList;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    /*return Scaffold(
      body: Column(
        children: [
          TextField(
            //controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search places with name'
            ),
          )
        ],
      ),
    );*/
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          //search place ui
          Container(
            height: 160,
            decoration: const BoxDecoration(
              color: Colors.black54,
              boxShadow:
              [
                BoxShadow(
                  color: Colors.white54,
                  blurRadius: 8,
                  spreadRadius: 0.5,
                  offset: Offset(
                    0.7,
                    0.7,
                  ),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [

                  const SizedBox(height: 25.0),

                  Stack(
                    children: [

                      GestureDetector(
                        onTap: ()
                        {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.grey,
                        ),
                      ),

                      const Center(
                        child: Text(
                          "Search & Set DropOff Location",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0),

                  Row(
                    children: [

                      const Icon(
                        Icons.adjust_sharp,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 18.0,),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: (valueTyped)
                            {
                              findPlaceAutoCompleteSearch(valueTyped);
                            },
                            decoration: const InputDecoration(
                              hintText: "search here...",
                              fillColor: Colors.white54,
                              filled: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                left: 11.0,
                                top: 8.0,
                                bottom: 8.0,
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),

          //display place predictions result
          (placesPredictedList.length > 0)
              ? Expanded(
            child: ListView.separated(
              itemCount: placesPredictedList.length,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index)
              {
                return PlacePredictionTileDesign(
                  predictedPlaces: placesPredictedList[index],
                );
              },
              separatorBuilder: (BuildContext context, int index)
              {
                return const Divider(
                  height: 1,
                  color: Colors.white,
                  thickness: 1,
                );
              },
            ),
          )
              : Container(),
        ],
      ),
    );
  }
}
