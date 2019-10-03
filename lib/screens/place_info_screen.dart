import 'package:flutter/material.dart';
import 'package:sl_travel_app/services/networking.dart';
import 'package:text_to_speech_api/text_to_speech_api.dart';
import 'package:audioplayer/audioplayer.dart';
import 'dart:io';

// https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=CnRvAAAAwMpdHeWlXl-lH0vp7lez4znKPIWSWvgvZFISdKx45AwJVP1Qp37YOrH7sqHMJ8C-vBDC546decipPHchJhHZL94RcTUfPa1jWzo-rSHaTlbNtjh-N68RkcToUCuY9v2HNpo5mziqkir37WU8FJEqVBIQ4k938TI3e7bf8xq-uwDZcxoUbO_ZJzPxremiQurAYzCTwRhE_V0&sensor=false&key=AddYourOwnKeyHere
//https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=Nepal

//https://maps.googleapis.com/maps/api/place/details/json?place_id=ChIJV-_dCaK8-zoR3yIZhmhLni4&key=AIzaSyA3wZ-g1QceGBgjzz90laxGX2Bo0rWqKAU

const URL = 'https://maps.googleapis.com/maps/api/place/photo';
const apiKey = 'AIzaSyDPx_Z6Ap3AvLALGCjr8lWkp1en84qYxPY';
const URL_wiki =
    'https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=';

const URL_gMap =
    'https://maps.googleapis.com/maps/api/place/details/json?place_id=';

class PlaceScreen extends StatefulWidget {
  final placeTitle;
  final photoReference;
  final placeID;

  PlaceScreen({this.placeTitle, this.photoReference, this.placeID});
  @override
  _PlaceScreenState createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  var wikiDecodedData;
  var gMapDecodedData;
  String extract;
  String textOnButton = 'Enable Text to Speech';
  bool isEnabled = false;
  TextToSpeechService _service = TextToSpeechService(apiKey);
  AudioPlayer _audioPlayer = AudioPlayer();

  @override
  initState() {
    super.initState();

    print('place title');
    print(widget.placeTitle);
    getWikiData();
    getGMapData();
  }

  @override
  void dispose() {
    super.dispose();
    wikiDecodedData = null;
    gMapDecodedData = null;
    _audioPlayer.stop();
  }

  Widget getTextDisplay() {
    //getWikiData();
    //getGMapData();
    print('Wiki Decoded Data');
    print(wikiDecodedData);
    if (wikiDecodedData == null) {
      return displayBlankPage();
    } else {
      var result = wikiDecodedData['query']['pages']; //query.pages['-1']

      if (result.containsKey('-1')) {
        return getGooglePlaceInfo();
      } else {
        return getWikiPlaceInfo(wikiDecodedData); //query.pages[5772075].extract
      }
    }
  }

  Widget displayBlankPage() {
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

  getWikiData() async {
    String placeTitle = widget.placeTitle;
    placeTitle = placeTitle.replaceAll(new RegExp(r"\s+\b|\b\s"), "+");
    print('wikipedia URL');
    print('$URL_wiki$placeTitle');
    NetworkHelper networkHelper = NetworkHelper('$URL_wiki$placeTitle');
    var wikiDecodedData = await networkHelper.getData();
    setState(() {
      this.wikiDecodedData = wikiDecodedData;
    });
    print('Wiki decoded data 2');
    print(wikiDecodedData);
  }

  getGMapData() async {
    NetworkHelper networkHelper =
        NetworkHelper('$URL_gMap${widget.placeID}&key=$apiKey');
    var gMapDecodedData = await networkHelper.getData();
    setState(() {
      this.gMapDecodedData = gMapDecodedData;
    });
  }

  Widget getGooglePlaceInfo() {
    var result = extractGMapData();
    setState(() {
      extract = result;
    });

    return Text('$result');
  }

  Widget getWikiPlaceInfo(decodedData) {
    String key = decodedData['query']['pages'].keys.first;
    String extract = decodedData['query']['pages'][key]['extract'];
    setState(() {
      this.extract = extract;
    });
    return Text('$extract');
  }

  String extractGMapData() {
    print('google map URL');
    print('$URL_gMap${widget.placeID}&key=$apiKey');

    String phone =
        gMapDecodedData['result'].containsKey('formatted_phone_number')
            ? gMapDecodedData['result']['formatted_phone_number']
            : null;
    String open_now = gMapDecodedData['result'].containsKey('opening_hours')
        ? gMapDecodedData['result']['opening_hours']['open_now'].toString()
        : null;
    double rating = gMapDecodedData['result'].containsKey('rating')
        ? gMapDecodedData['result']['rating']
        : null;
    String website = gMapDecodedData['result'].containsKey('website')
        ? gMapDecodedData['result']['website']
        : null;
    String review = '';
    if (gMapDecodedData['result'].containsKey('reviews')) {
      for (int i = 0; i < gMapDecodedData['result']['reviews'].length; i++) {
        review += '${gMapDecodedData['result']['reviews'][i]['text']}\n';
      }
    } else {
      review = null;
    }
    String result = '';

    if (phone != null) {
      result += 'Phone number: $phone\n';
    }
    if (open_now != null) {
      result += 'Open now: $open_now\n';
    }
    if (rating != null) {
      result += 'Rating: ${rating.toString()}\n';
    }
    //TODO: Add a link to the website URL
    if (website != null) {
      result += 'Website: $website\n';
    }
    if (review != null) {
      result += '$review\n';
    }
    print('Result');
    print(result);
    return result;
  }

  void _playAudio(bool isEnabled) async {
    if (isEnabled == false) {
      setState(() {
        isEnabled = true;
        this.isEnabled = isEnabled;
        textOnButton = 'Disable Text to Speech';
      });
    } else {
      setState(() {
        isEnabled = false;
        this.isEnabled = isEnabled;
        textOnButton = 'Enable Text to Speech';
      });
    }

    if (isEnabled == true) {
      String extract = '${widget.placeTitle}. ${this.extract}';
      File file = await _service.textToSpeech(text: extract);
      _audioPlayer.play(file.path, isLocal: true);
    } else {
      _audioPlayer.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SL Tour Assistant',
        ),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(left: 5.0, right: 5.0),
          shrinkWrap: true,
          children: <Widget>[
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: EdgeInsets.all(0.0),
              splashColor: Colors.blue[100],
              onPressed: () {
                _playAudio(isEnabled);
              },
              child: Text(
                textOnButton,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Image.network(
              '$URL?maxheight=600&maxwidth=600&photoreference=${widget.photoReference}&sensor=false&key=$apiKey',
              fit: BoxFit.fitHeight,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              widget.placeTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            getTextDisplay(),
          ],
        ),
      ),
    );
  }
}
