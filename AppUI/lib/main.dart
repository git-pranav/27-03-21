import 'package:flutter/material.dart';
import 'homeR.dart';

bool debugShowCheckedModeBanner = true;
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '360 VPA APP',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Home());
  }
}   
