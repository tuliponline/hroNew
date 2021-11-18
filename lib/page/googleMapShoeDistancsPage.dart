import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:provider/provider.dart';

class GoogleMapShowDistancsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GoogleMapShowDistancsState();
  }
}

class GoogleMapShowDistancsState extends State<GoogleMapShowDistancsPage> {
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;
  Position _currentPosition;
  final Geolocator _geolocator = Geolocator();

  double userLat = 0.0, userLng = 0.0, shopLat = 0, shopLng = 0;
  final startAddressController = TextEditingController();

  _setStartLocation(AppDataModel appDataModel) {
    userLat = appDataModel.userLat;
    userLng = appDataModel.userLng;
    shopLat = appDataModel.latShop;
    shopLng = appDataModel.lngShop;
    // _initialLocation = CameraPosition(
    //     target: LatLng(appDataModel.userLat, appDataModel.userLng));
  }

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _setStartLocation(context.read<AppDataModel>());
    _getCurrentLocation();
    _createPolylines();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              body: Container(
                height: height,
                width: width,
                child: Scaffold(
                  body: Stack(
                    children: <Widget>[
                      GoogleMap(
                        polylines: Set<Polyline>.of(polylines.values),
                        initialCameraPosition: _initialLocation,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        mapType: MapType.normal,
                        zoomGesturesEnabled: true,
                        zoomControlsEnabled: false,
                        onMapCreated: (GoogleMapController controller) {
                          mapController = controller;
                        },
                      ),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 10.0, bottom: 10.0),
                            child: ClipOval(
                              child: Material(
                                color: Colors.green[100], // button color
                                child: InkWell(
                                  splashColor: Colors.orange, // inkwell color
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Icon(Icons.my_location),
                                  ),
                                  onTap: () {
                                    _createPolylines();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 10.0, bottom: 10.0),
                            child: ClipOval(
                              child: Material(
                                color: Colors.orange[100], // button color
                                child: InkWell(
                                  splashColor: Colors.orange, // inkwell color
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Icon(Icons.my_location),
                                  ),
                                  onTap: () {
                                    mapController.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: LatLng(
                                            appDataModel.userLat,
                                            appDataModel.userLng,
                                          ),
                                          zoom: 18.0,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ClipOval(
                                child: Material(
                                  color: Colors.blue[100], // button color
                                  child: InkWell(
                                    splashColor: Colors.blue, // inkwell color
                                    child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Icon(Icons.add),
                                    ),
                                    onTap: () {
                                      mapController.animateCamera(
                                        CameraUpdate.zoomIn(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              ClipOval(
                                child: Material(
                                  color: Colors.blue[100], // button color
                                  child: InkWell(
                                    splashColor: Colors.blue, // inkwell color
                                    child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Icon(Icons.remove),
                                    ),
                                    onTap: () {
                                      mapController.animateCamera(
                                        CameraUpdate.zoomOut(),
                                      );
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        // Store the position in the variable
        _currentPosition = position;

        print('CURRENT POS: $_currentPosition');

        // For moving the camera to current location
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(userLat, userLng),
              zoom: 18.0,
            ),
          ),
        );
      });
    }).catchError((e) {
      print(e);
    });
  }

  PolylinePoints polylinePoints;

// List of coordinates to join
  List<LatLng> polylineCoordinates = [];

// Map storing polylines created by connecting
// two points
  Map<PolylineId, Polyline> polylines = {};

// Create the polylines for showing the route between two places

  _createPolylines() async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyBlChWOyjFEwBGP-qKjtgkny-VqAZ2t6a4", // Google Maps API Key
      PointLatLng(userLat, userLng),
      PointLatLng(shopLat, shopLng),
      travelMode: TravelMode.driving,
    );
    print(PointLatLng(userLat, userLng));
    print(PointLatLng(shopLat, shopLng));
    // Adding the coordinates to the list
    print(result.points);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

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

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
