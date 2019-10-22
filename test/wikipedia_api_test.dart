import 'package:test/test.dart';
import 'package:http/testing.dart';
import 'package:sl_travel_app/services/networking.dart';
import 'package:http/http.dart';
import 'dart:convert';

void main() {
  test("Testing the network call", () async {
    //setup the test
    String url =
        'https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=Nepal';
    print(url);
    NetworkHelper networkHelper = NetworkHelper(url);
    print('888888');
    networkHelper.client = MockClient((request) async {
      print('Request is: ');
      print(request);
      //final mapJson = {'id': 222}; // actual value
      final mapJson = {
        'query': {
          'pages': {
            '171166': {'title': 'Nepal'}
          }
        }
      };
      return Response(json.encode(mapJson), 200);
    });
  });
}

//query.pages[171166].title
//id
