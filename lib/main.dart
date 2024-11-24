import 'package:flutter/material.dart';
import 'package:prediction/Pages/homepage.dart';
import 'package:prediction/response.dart';
import 'Pages/SignUp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures binding is ready before Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
      MyApp(),

  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ResponseDataModel(),
        child: MaterialApp(
      title: 'Green Sign Up Page',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SignUpPage(), // Starting with SignUpPage
    ),
  );}
}
