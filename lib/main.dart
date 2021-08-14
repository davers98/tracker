import 'package:flutter/material.dart';
import 'package:mapbox/src/pages/fullscreenmap.dart';
import 'package:firebase_core/firebase_core.dart';



void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: MyLocation(),
      ),
    );
  }
}
