import 'networking.dart';

const URL = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=';
const apiKey = 'AIzaSyA3wZ-g1QceGBgjzz90laxGX2Bo0rWqKAU';

class PlaceInfo {
  Future<dynamic> getNearbyPlaces(String address) async {
    NetworkHelper networkHelper =
        NetworkHelper('$URL$address+point+of+interest&language=en&key=$apiKey');

    var decodedData = await networkHelper.getData();
    return decodedData;
  }
}
