import 'package:nada/CustomSlider.dart';
import 'package:nada/Generalinfo.dart';
import 'package:nada/home.dart';
import 'package:nada/myturn.dart';
import 'Demo.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: HomeScreenSplash(),
    );
  }
}

