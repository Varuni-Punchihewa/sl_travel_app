import 'package:flutter/material.dart';

// https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=CnRvAAAAwMpdHeWlXl-lH0vp7lez4znKPIWSWvgvZFISdKx45AwJVP1Qp37YOrH7sqHMJ8C-vBDC546decipPHchJhHZL94RcTUfPa1jWzo-rSHaTlbNtjh-N68RkcToUCuY9v2HNpo5mziqkir37WU8FJEqVBIQ4k938TI3e7bf8xq-uwDZcxoUbO_ZJzPxremiQurAYzCTwRhE_V0&sensor=false&key=AddYourOwnKeyHere
//https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=Nepal

//https://maps.googleapis.com/maps/api/place/details/json?place_id=ChIJV-_dCaK8-zoR3yIZhmhLni4&key=AIzaSyA3wZ-g1QceGBgjzz90laxGX2Bo0rWqKAU

const URL = 'https://maps.googleapis.com/maps/api/place/photo';
const apiKey = 'AIzaSyA3wZ-g1QceGBgjzz90laxGX2Bo0rWqKAU';

const URL_wiki =
    'https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=';

class PlaceScreen extends StatefulWidget {
  final placeInfo;
  final photoReference;
  PlaceScreen({this.placeInfo, this.photoReference});
  @override
  _PlaceScreenState createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.network(
                '$URL?maxheight=600&maxwidth=600&photoreference=${widget.photoReference}&sensor=false&key=$apiKey'),
            SizedBox(
              height: 20,
            ),
            Text(
              widget.placeInfo,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text('$URL_wiki+${widget.placeInfo}'),
          ],
        ),
      ),
    );
    ;
  }
}
