import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hro/model/AppDataModel.dart';

import 'package:flutter_geocoder/model.dart';

Future<String> getAddressName(double lat, double lng) async {
  final coordinates = new Coordinates(lat, lng);
  var addresses =
      await Geocoder.google("AIzaSyD3BbCLmgvRyWWLxqnoLEbI4t8yNOefnVg")
          .findAddressesFromCoordinates(coordinates);
  var first = addresses.first;
  print("${first.featureName} : ${first.addressLine}");
  return (first.addressLine);
}

double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
  double distance = 0;
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
  distance = 12742 * asin(sqrt(a));
  return distance;
}

Future<bool> checkLocationLimit(
    double lat1, double lng1, double lat2, double lng2, distanceLimit) async {
  double distance = 0;
  bool inService;
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
  distance = 12742 * asin(sqrt(a));

  if (distance > distanceLimit) {
    inService = false;
  } else {
    inService = true;
  }
  return inService;
}

Future<List<String>> calDistanceAndCostDelivery(double lat1, double lng1,
    double lat2, double lng2, int distanceMin, costStart, costPerKm) async {
  double distance = 0;
  int costDelivery = costStart;
  print("distanceMin = $distanceMin");
  print("costStart = $costStart");
  print("costPerKm = $costPerKm");
  distance = await _createPolylines(lat1, lng1, lat2, lng2);
  int distanceFinal = distance.ceil();
  int distanceLeft;
  if (distance > distanceMin) {
    distanceLeft = distanceFinal - distanceMin;
    costDelivery += (costPerKm * distanceLeft);
  }
  print("distance true = $distance");
  print("distanceFinal = $distanceFinal");
  print("distanceLeft = $distanceLeft");
  print("costDelivery = $costDelivery");
  // if (distance > distanceLimit) {
  // //outService
  // }
  return [distance.toString(), costDelivery.toString()];
}

_createPolylines(double lat1, lng1, lat2, lng2) async {
  PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  // Initializing PolylinePoints
  polylinePoints = PolylinePoints();
  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    AppDataModel().googleMapApiKey, // Google Maps API Key
    PointLatLng(lat1, lng1),
    PointLatLng(lat2, lng2),
    travelMode: TravelMode.walking,
  );
  print("$lat1,$lng1/$lat2,$lng2");

  // Adding the coordinates to the list
  if (result.points.isNotEmpty) {
    result.points.forEach((PointLatLng point) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    });
  }

  print(result.status);
  double totalDistance = 0.0;

// Calculating the total distance by adding the distance
// between small segments
  for (int i = 0; i < polylineCoordinates.length - 1; i++) {
    totalDistance += _coordinateDistance(
      polylineCoordinates[i].latitude,
      polylineCoordinates[i].longitude,
      polylineCoordinates[i + 1].latitude,
      polylineCoordinates[i + 1].longitude,
    );
  }
  print("totalDistance $totalDistance");
  return totalDistance;
}

double _coordinateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}
