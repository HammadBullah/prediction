import 'package:flutter/material.dart';
import 'package:prediction/Pages/homepage.dart';
import 'Pages/SignUp.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Sign Up Page',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SignUpPage(), // Starting with SignUpPage
    );
  }
}
