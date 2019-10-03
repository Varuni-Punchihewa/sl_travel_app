import 'package:flutter/material.dart';
import 'screens/upload_photo_screen.dart';
import 'screens/loading_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sri Lanka Travel App',
      initialRoute: 'home',
      routes: {
        'home': (context) => LoadingScreen(),
        'photo_uploader': (context) => UploadPhoto(),
      },
    );
  }
}
