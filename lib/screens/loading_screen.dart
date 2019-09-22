import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:sl_travel_app/services/location.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  static double latitude;
  static double longitude;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  void getLocation() async {
    Location location = new Location();
    await location.getCurrentLocation();
    latitude = location.latitude;
    longitude = location.longitude;
    print(latitude);
    print(longitude);
  }

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SL Tour Assistant',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.camera_alt,
              color: Colors.white,
            ),
            iconSize: 40.0,
            tooltip: 'Upload Photo',
            onPressed: () {
              Navigator.pushNamed(context, 'photo_uploader');
            },
          ),
        ],
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 14.4746,
          ),
          onMapCreated: (GoogleMapController controller) {
            try {
              _controller.complete(controller);
            } catch (error) {
              _controller.completeError(error);
            }
          },
        ),
      ),
    );
  }
}
