import 'dart:async';
import 'package:geolocator/geolocator.dart';

class Location {
  double latitude;
  double longitude;
  var geolocator = Geolocator();

  Future<void> getCurrentLocation() async {
    try {
      Position position = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      print(e);
    }
  }

  void positionChanged() {
    var locationOptions = LocationOptions(
        accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 1);

    // ignore: cancel_subscriptions
    StreamSubscription<Position> positionStream = geolocator
        // ignore: cancel_subscriptions
        .getPositionStream(locationOptions)
        .listen((Position position) {
      if (position == null) {
        print('Unkonown');
      } else {
        latitude = position.latitude;
        longitude = position.longitude;
        print('--------------------------');
        print('Latitude changed: $latitude');
        print('Longitude changed: ${position.longitude.toString()}');
      }
    });
  }
}
