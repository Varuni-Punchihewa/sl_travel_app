import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:sl_travel_app/services/place_information.dart';
import 'package:sl_travel_app/services/build_address.dart';
import 'place_info_screen.dart';

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
  Completer<GoogleMapController> _controller = Completer();

  double lat;
  double lon;
  String name;
  double rating;
  List photos = [];
  String placeID;
  bool geolocationStatus;
  String photoRef;
  String _address;

  ///check whether the GPS is enabled or not. If enabled, get the current location,
  ///else returns a blank page with a Dialog asking the user to enable GPS
  checkPermission() async {
    geolocationStatus = await _geolocator.isLocationServiceEnabled();
    print('STATUS: $geolocationStatus');

    if (geolocationStatus == true) {
      updateLocation();
    } else {
      _showDialog();
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("GPS is not enabled"),
          content: Text(
              "For a better experience, turn on device location, which uses Google's location service"),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  initState() {
    super.initState();
    _geolocator = Geolocator();
    LocationOptions locationOptions = LocationOptions(
        accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 10);
    checkPermission();

    // ignore: unused_local_variable, cancel_subscriptions
    StreamSubscription positionStream = _geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) async {
      //_position = position;
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });

      /// Once the user enables GPS return the Map view
      if (latitude != null && longitude != null) {
        setState(() {
          geolocationStatus = true;
        });
      }

      print('Changed latitude: ${position.latitude}');
      print('Changed longitude: ${position.longitude}');

      /// Clear the previous markers when current position changes
      markers.clear();
      final CameraPosition _newPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 11.0);
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(_newPosition));
//      _add();
      _onPlaceChanged();
    });
  }

  /// Retrieve Points of Interest as the user is on the move
  Future<void> _onPlaceChanged() async {
    String address = 'unknown';
    PlaceInfo placeInfo = PlaceInfo();

    ///Translate the latitude and longitude of the user's location at that time into a readable address
    final List<Placemark> placemarks =
        await _geolocator.placemarkFromCoordinates(latitude, longitude);

    if (placemarks != null && placemarks.isNotEmpty) {
      BuildAddress buildAddress = BuildAddress();

      /// Retrieve the name, city, sub locality, state, sub admin area, country related to the user's current location
      address = buildAddress.buildAddressString(placemarks.first);
      print(address);

      /// Retrieve the Point of Interests of nearby places relative to the user's current location
      var placeData = await placeInfo.getNearbyPlaces(address);
      extractNearbyPlaces(placeData);
    }
    setState(() {
      _address = '$address';
    });
  }

  /// Retrieve the location info related to the nearby places to the user
  void extractNearbyPlaces(decodedData) {
    setState(() {
      if (decodedData == null) {
        setState(() {
          lat = null;
          lon = null;
          name = '';
          rating = null;
          photos = null;
          placeID = '';
          photoRef = '';
        });

        return;
      }
      getInfo(decodedData);
    });
  }

  getInfo(decodedData) {
    List dataList = decodedData['results'];
    for (int i = 0; i < dataList.length; i++) {
      print(dataList.length);

      setState(() {
        var data = dataList[i];
        lat = data['geometry']['location']
            ['lat']; //results[0].geometry.location.lat
        lon = data['geometry']['location']['lng'];
        name = data['name']; //results[0].name
        photos = data['photos']; //results[0].photos
        placeID = data['place_id']; //results[0].place_id
        photoRef = data['photos'][0]
            ['photo_reference']; //results[0].photos[0].photo_reference
        _add(
            latitude: lat,
            longitude: lon,
            title: name,
            photoRef: photoRef,
            placeID: placeID);
      });
      print('$lat, $lon, $name, $rating, $photos, $placeID');
    }
  }

  Future<void> updateLocation() async {
    try {
      Position newPosition = await _geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        latitude = newPosition.latitude;
        longitude = newPosition.longitude;
        print('Current latitude: ${newPosition.latitude}');
        print('Current longitude: ${newPosition.longitude}');
        final CameraPosition _changedPosition =
            CameraPosition(target: LatLng(latitude, longitude), zoom: 11.0);
        _animateCameraForChangedLocation(_changedPosition);
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  Future<void> _animateCameraForChangedLocation(var _changedPosition) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_changedPosition));
  }

  /// Determines which view to display based on whether the user has enabled GPS or not
  Widget getStartupScreen() {
    if (geolocationStatus == true) {
      return createMap();
    } else {
      return createBlank();
    }
  }

  /// Displays as the home view when the user has disabled GPS
  Widget createBlank() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SL Tour Assistant',
        ),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Container(
          width: 100,
          height: 100,
        ),
      ),
    );
  }

  /// Displays as the home view when the user has enabled GPS
  Widget createMap() {
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
            zoom: 11.0,
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

  /// Add markers to represent the nearby places
  void _add(
      {double latitude,
      double longitude,
      String title,
      String photoRef,
      String placeID}) {
    //final int markerCount = markers.length;
    //(info == 'true') ? info = 'Yes' : info = 'No';
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    setState(() {
      _markerIdCounter++;
    });

    final MarkerId markerId = MarkerId(markerIdVal);
    //LatLng center = LatLng(latitude, longitude);

    Marker marker = Marker(
      markerId: markerId,
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: title,
        //snippet: 'Rating: $info',
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PlaceScreen(
                        placeTitle: title,
                        photoReference: photoRef,
                        placeID: placeID,
                      )));
        },
      ),
      onTap: () {
        _onMarkerTapped(markerId);
      },
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  /// Display basic location info when the marker is tapped
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
    return getStartupScreen();
  }
}
