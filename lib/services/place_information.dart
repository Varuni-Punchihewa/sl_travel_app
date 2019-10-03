import 'networking.dart';

const URL = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=';
const apiKey = 'AIzaSyDPx_Z6Ap3AvLALGCjr8lWkp1en84qYxPY';

class PlaceInfo {
  Future<dynamic> getNearbyPlaces(String address) async {
    NetworkHelper networkHelper =
        NetworkHelper('$URL$address+point+of+interest&language=en&key=$apiKey');

    var decodedData = await networkHelper.getData();
    return decodedData;
  }
}
