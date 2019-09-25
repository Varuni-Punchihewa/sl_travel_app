import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:sl_travel_app/services/place_information.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  static double latitude;
  static double longitude;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  int _markerIdCounter = 1;
  MarkerId selectedMarker;
  Geolocator _geolocator;
  String _address = '';
  Completer<GoogleMapController> _controller = Completer();

  double lat;
  double lon;
  String name;
  bool openNow;
  List photos = [];
  String placeID;

  void checkPermission() {
    _geolocator.checkGeolocationPermissionStatus().then((status) {
      print('status: $status');
    });
    _geolocator
        .checkGeolocationPermissionStatus(
            locationPermission: GeolocationPermission.locationAlways)
        .then((status) {
      print('always status: $status');
    });
    _geolocator.checkGeolocationPermissionStatus(
        locationPermission: GeolocationPermission.locationWhenInUse)
      ..then((status) {
        print('whenInUse status: $status');
      });
  }

  @override
  initState() {
    super.initState();
    _geolocator = Geolocator();
    LocationOptions locationOptions = LocationOptions(
        accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 10);

    checkPermission();
    updateLocation();

    // ignore: unused_local_variable, cancel_subscriptions
    StreamSubscription positionStream = _geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) async {
      //_position = position;
      latitude = position.latitude;
      longitude = position.longitude;
      print('Changed latitude: ${position.latitude}');
      print('Changed longitude: ${position.longitude}');
      final CameraPosition _newPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 15.0);
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(_newPosition));
      _add();
      _onPlaceChanged();
    });
  }

  Future<void> _onPlaceChanged() async {
    String address = 'unknown';
    PlaceInfo placeInfo = PlaceInfo();
    final List<Placemark> placemarks =
        await Geolocator().placemarkFromCoordinates(latitude, longitude);

    if (placemarks != null && placemarks.isNotEmpty) {
      address = _buildAddressString(placemarks.first);
      print(address);
      var placeData = await placeInfo.getNearbyPlaces(address);
      extractNearbyPlaces(placeData);
    }

    setState(() {
      _address = '$address';
    });
  }

  void extractNearbyPlaces(decodedData) {
    setState(() {
      if (decodedData == null) {
        lat = null;
        lon = null;
        name = '';
        openNow = false;
        photos = null;
        placeID = '';
        return;
      }

      getInfo(decodedData);
    });
  }

  getInfo(decodedData) {}

  static String _buildAddressString(Placemark placemark) {
    final String name = placemark.name ?? '';
    final String city = placemark.locality ?? '';
    final String subLocality = placemark.subLocality ?? '';
    final String state = placemark.administrativeArea ?? '';
    final String subAdministrativeArea = placemark.subAdministrativeArea ?? '';
    final String country = placemark.country ?? '';

    return '$name, $subLocality $city, $subAdministrativeArea, $state, $country';
  }

  Future<void> updateLocation() async {
    try {
      Position newPosition = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      setState(() {
        latitude = newPosition.latitude;
        longitude = newPosition.longitude;
        print('Current latitude: ${newPosition.latitude}');
        print('Current longitude: ${newPosition.longitude}');
        final CameraPosition _changedPosition =
            CameraPosition(target: LatLng(latitude, longitude), zoom: 15.0);
        _animateCameraForChangedLocation(_changedPosition);

        _add();
//        List<Placemark> placemark =
//            await Geolocator().placemarkFromCoordinates(latitude, longitude);
//        print('*****************************************');
//        print(placemark);
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  Future<void> _animateCameraForChangedLocation(var _changedPosition) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_changedPosition));
  }

  void _add() {
    //final int markerCount = markers.length;

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);
    //LatLng center = LatLng(latitude, longitude);

    Marker marker = Marker(
      markerId: markerId,
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {
        _onMarkerTapped(markerId);
      },
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  void _onMarkerTapped(MarkerId markerId) {
    final Marker tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        if (markers.containsKey(selectedMarker)) {
          final Marker resetOld = markers[selectedMarker]
              .copyWith(iconParam: BitmapDescriptor.defaultMarker);
          markers[selectedMarker] = resetOld;
        }
        selectedMarker = markerId;
        final Marker newMarker = tappedMarker.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
        markers[markerId] = newMarker;
      });
    }
  }

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
            zoom: 15.0,
          ),
          onMapCreated: (GoogleMapController controller) {
            try {
              _controller.complete(controller);
            } catch (error) {
              _controller.completeError(error);
            }
          },
          markers: Set<Marker>.of(markers.values),
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
        ),
      ),
    );
  }
}
