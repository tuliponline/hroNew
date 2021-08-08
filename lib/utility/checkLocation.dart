import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';

Future<bool> checkLocationService() async {
  bool locationServiceEnabled = false;
  locationServiceEnabled = await Geolocator.isLocationServiceEnabled();

  print("locationServiceEnabled = " + locationServiceEnabled.toString());
  if (locationServiceEnabled) {
    locationServiceEnabled = true;
  } else {
    locationServiceEnabled = false;
  }
  return locationServiceEnabled;
}

Future<bool> checkLocationSPermission() async {
  String os;
  if (Platform.isAndroid) {
    os = "android";
    print("OS = " + os);
  } else if (Platform.isIOS) {
    os = "ios";
    print("OS = " + os);
  }

  bool locationPermission = false;

  if (os == "android") {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    print('permission' + permission.toString());
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        locationPermission = false;
      } else {
        locationPermission = true;
      }
    } else {
      locationPermission = true;
    }
  } else {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    print('permission' + permission.toString());
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await LocationPermissions().requestPermissions();
      LocationPermission permissioniOs = await Geolocator.checkPermission();
      print("permissioniOs" + permissioniOs.toString());
      if (permissioniOs == LocationPermission.denied ||
          permissioniOs == LocationPermission.deniedForever) {
        locationPermission = false;
      } else {
        locationPermission = true;
      }
    } else {
      locationPermission = true;
    }
  }

  return locationPermission;
}

Future<bool> doRequestPermission() async {
  print("doRequestPermission");
  bool locationPermission = false;
  LocationPermission permission;
  permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    locationPermission = false;
  } else {
    locationPermission = true;
  }
  return locationPermission;
}

Future<Position> checkLocationPosition() async {
  Position position;
  print('getLocation');
  await Geolocator.getCurrentPosition().then((value) {
    position = value;
  }).catchError((error) {
    print('location Error = ' + error);
    position = null;
  });
  return position;
}
