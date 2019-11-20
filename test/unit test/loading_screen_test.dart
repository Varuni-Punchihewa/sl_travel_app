import 'package:flutter/cupertino.dart';
import 'package:test/test.dart';
import 'package:sl_travel_app/screens/loading_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:geolocator/geolocator.dart';

abstract class MockWithExpandedToString extends Mock {
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug});
}

class MockLoadingScreen extends MockWithExpandedToString
    implements LoadingScreen {}

void main() {
//  LoadingScreen loadingScreen = LoadingScreen();
  test('check GPS permission when enabled', () {
    var loadingScreen = MockLoadingScreen();
    var ls = loadingScreen.createState();
    //ls.initState();

    // ignore: invalid_use_of_protected_member
    ls.setState(() {
      ls.geolocationStatus = true;
    });

//    when(ls.geolocationStatus).thenReturn(true);
//
//    when(ls.checkPermission()).thenReturn(ls.updateLocation());
//    expect(ls.checkPermission(), ls.updateLocation());

//    loadingScreen.createState().geolocator.isLocationServiceEnabled();

    when(ls.geolocationStatus).thenReturn(true);
    expect(ls.geolocationStatus, true);
  });
}
