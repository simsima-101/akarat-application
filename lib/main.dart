import 'package:Akarat/screen/settingstile.dart';
import 'package:Akarat/screen/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
      // home: FilterScreen()
      home: Home()
    );
  }
}