import 'package:flutter/material.dart';
import 'package:project_app/screen/loginscreen.dart';

import 'package:shared_preferences/shared_preferences.dart';




import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


bool show = true;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs=await SharedPreferences.getInstance();
  show = prefs.getBool('ON_BOARDING')??true; 

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProjectApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home : const LoginScreen(),
    );
  }
}
