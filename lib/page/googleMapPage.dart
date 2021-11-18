import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/utility/checkLocation.dart';

import 'package:hro/utility/style.dart';
import 'package:places_service/places_service.dart';
import 'package:provider/provider.dart';

class GoogleMapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GoogleMapState();
  }
}

class GoogleMapState extends State<GoogleMapPage> {
  double lat, lng;
  var controller = TextEditingController();

  String streetNumber;
  String street;
  String city;
  String zipCode;

  PlacesService _placesService = PlacesService();
  bool searchWork = false;
  List<PlacesAutoCompleteResult> autoCompleteSuggestions;
  Completer<GoogleMapController> _controller = Completer();

  // static final CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(lat, -122.085749655962),
  //   zoom: 14.4746,
  // );

  // static final CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(lat, lng),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);

  _getLatlng(AppDataModel appDataModel) {
    _placesService.initialize(
      apiKey: appDataModel.googleMapApiKeyPlaces,
    );

    lat = appDataModel.userLat;
    lng = appDataModel.userLng;

    myMarker = [];
    myMarker.add(Marker(
        markerId: MarkerId('Marker'),
        position: LatLng(lat, lng),
        //infoWindow: InfoWindow(title: 'ตำแหน่ง', snippet: "ตำแหน่งของคุณ"),
        draggable: true,
        onDragEnd: (dragEndPosition) {
          print(dragEndPosition);
        }));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getLatlng(context.read<AppDataModel>());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
      builder: (context, appDataModel, child) => Scaffold(
        body: Container(
            child: Stack(
          children: [
            showMap(),
            SafeArea(
                child: Align(
                    alignment: Alignment.topLeft,
                    child: InkWell(
                      onTap: () async {
                        // Navigator.pop(context);
                        searchWork = false;
                        setState(() {});
                      },
                      child: (searchWork == true)
                          ? ListView(
                              children: [
                                Container(
                                  width: appDataModel.screenW,
                                  child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: new Card(
                                          child: new ListTile(
                                        leading: new Icon(
                                          FontAwesomeIcons.mapMarkerAlt,
                                          color: Colors.red,
                                        ),
                                        title: new TextField(
                                          onChanged: (value) async {
                                            if (controller != null &&
                                                controller.text != "") {
                                              autoCompleteSuggestions =
                                                  await _placesService
                                                      .getAutoComplete(
                                                          controller.text);
                                              setState(() {});
                                            } else {
                                              autoCompleteSuggestions.clear();
                                              setState(() {});
                                            }
                                          },
                                          controller: controller,
                                          decoration: new InputDecoration(
                                              hintText: 'ค้นหา',
                                              border: InputBorder.none),
                                          // onChanged: onSearchTextChanged,
                                        ),
                                        trailing: new IconButton(
                                          icon: new Icon(Icons.cancel),
                                          onPressed: () {
                                            controller.clear();
                                            searchWork = false;
                                            setState(() {});
                                          },
                                        ),
                                      ))),
                                ),
                                (autoCompleteSuggestions == null ||
                                        autoCompleteSuggestions.length < 1)
                                    ? Container()
                                    : Column(
                                        children:
                                            autoCompleteSuggestions.map((e) {
                                          return InkWell(
                                            onTap: () async {
                                              final placeDetails =
                                                  await _placesService
                                                      .getPlaceDetails(
                                                          e.placeId);
                                              print(placeDetails.lat);
                                              lat = placeDetails.lat;
                                              lng = placeDetails.lng;
                                              _goToTheLake();
                                            },
                                            child: Container(
                                              color: Colors.white,
                                              padding: EdgeInsets.all(5),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        right: 5),
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey,
                                                        shape: BoxShape.circle),
                                                    child: Icon(
                                                      FontAwesomeIcons
                                                          .mapMarkerAlt,
                                                      size: 15,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Style()
                                                        .textBlackSize(
                                                            e.description, 14),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      )
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: 5),
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: Colors.black87.withOpacity(0.4),
                                        shape: BoxShape.circle),
                                    child: Icon(
                                      Icons.navigate_before,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        searchWork = true;
                                        setState(() {});
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(right: 5),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Style().darkColor,
                                            shape: BoxShape.circle),
                                        child: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                              margin: EdgeInsets.all(10),
                                              child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          primary: Style()
                                                              .darkColor),
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context, [lat, lng]);
                                                  },
                                                  child: Text("ยืนยันตำแหน่ง")))
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                    ))),
          ],
        )),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 40,
                width: 40,
                child: FloatingActionButton(
                  onPressed: () async {
                    var locationPermision = await checkLocationSPermission();
                    if (locationPermision) {
                      var locationNow = await checkLocationPosition();
                      lat = locationNow.latitude;
                      lng = locationNow.longitude;
                      _goToTheLake();
                    }
                  },
                  child: Icon(Icons.location_searching),
                ),
              ),
              Container()
            ],
          ),
        ),
      ),
    );
  }

  String location;
  List<Marker> myMarker = [];
  Container showMap() {
    LatLng firstLocation = LatLng(lat, lng);

    CameraPosition cameraPosition = CameraPosition(
      target: firstLocation,
      zoom: 16.0,
    );

    return Container(
        child: GoogleMap(
      // myLocationEnabled: true,
      initialCameraPosition: cameraPosition,
      myLocationButtonEnabled: true,
      mapType: MapType.normal,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: Set.from(myMarker),
      onTap: _handleTap,
    ));
  }

  _handleTap(LatLng tappedPoint) {
    print("NewLocation = " + tappedPoint.toString());
    lat = tappedPoint.latitude;
    lng = tappedPoint.longitude;
    setState(() {
      myMarker = [];
      myMarker.add(Marker(
          markerId: MarkerId(tappedPoint.toString()),
          // infoWindow: InfoWindow(title: 'ตำแหน่ง', snippet: "ตำแหน่งของคุณ"),
          position: tappedPoint,
          draggable: true,
          onDragEnd: (dragEndPosition) {
            lat = dragEndPosition.latitude;
            lng = dragEndPosition.longitude;
            print(dragEndPosition);
          }));
    });
  }

  //     bearing: 192.8334901395799,
  //     target: LatLng(lat, lng),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414
  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, lng),
      zoom: 16.0,
    )));
    if (autoCompleteSuggestions != null) autoCompleteSuggestions.clear();
    setState(() {
      myMarker = [];
      myMarker.add(Marker(
          markerId: MarkerId(LatLng(lat, lng).toString()),
          // infoWindow: InfoWindow(title: 'ตำแหน่ง', snippet: "ตำแหน่งของคุณ"),
          position: LatLng(lat, lng),
          draggable: true,
          onDragEnd: (dragEndPosition) {
            lat = dragEndPosition.latitude;
            lng = dragEndPosition.longitude;
            print(dragEndPosition);
          }));
    });
  }
}
