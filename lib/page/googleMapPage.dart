import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class GoogleMapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GoogleMapState();
  }
}

class GoogleMapState extends State<GoogleMapPage> {
  double lat, lng;

  _getLatlng(AppDataModel appDataModel) {
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
                      Navigator.pop(context);
                    },
                    child: Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.black87.withOpacity(0.4),
                                shape: BoxShape.circle),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.all(10),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Style().darkColor),
                                  onPressed: () {
                                    Navigator.pop(context, [lat, lng]);
                                  },
                                  child: Text("ยืนยันตำแหน่ง")))
                        ],
                      ),
                    ),
                  ))),
        ],
      ))),
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
      mapType: MapType.normal,
      onMapCreated: (controller) {},
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
}
