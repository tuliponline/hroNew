import 'dart:async';
import 'dart:math';

import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:places_service/places_service.dart';

const kGoogleApiKey = "AIzaSyCw82CcJWduFF5MXEOPOND8mgnxvGDUF-M";

void main() => runApp(MyApp());

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: RoutesWidget(),
      ),
    );
  }
}

class RoutesWidget extends StatefulWidget {
  @override
  demoState createState() => new demoState();
}

class demoState extends State<RoutesWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            child: RaisedButton(
              onPressed: () async {
                print("object");
                PlacesService _placesService = PlacesService();
                _placesService.initialize(
                  apiKey: kGoogleApiKey,
                );
                print("object2");

                final autoCompleteSuggestions =
                    await _placesService.getAutoComplete('อากาศอำ');
                print(autoCompleteSuggestions.length);
                autoCompleteSuggestions.forEach((element) async {
                  print(element.description);
                  final placeDetails =
                      await _placesService.getPlaceDetails(element.placeId);
                  print(placeDetails.lat);
                });

                // Prediction p = await PlacesAutocomplete.show(
                //     context: context,
                //     apiKey: kGoogleApiKey,
                //     mode: Mode.overlay, // Mode.fullscreen
                //     language: "en",
                //     components: [new Component(Component.country, "en")]);
                // print(p);
              },
              child: Text('Find address'),
            )));
  }
}
