import 'package:geolocator/geolocator.dart';

class BuildAddress {
  String buildAddressString(Placemark placemark) {
    final String name = placemark.name ?? '';
    final String city = placemark.locality ?? '';
    final String subLocality = placemark.subLocality ?? '';
    final String state = placemark.administrativeArea ?? '';
    final String subAdministrativeArea = placemark.subAdministrativeArea ?? '';
    final String country = placemark.country ?? '';

    return '$name, $subLocality $city, $subAdministrativeArea, $state, $country';
  }
}
