
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kelemni/screens/home.dart';
import 'package:kelemni/screens/signin.dart';
import 'package:kelemni/services/auth.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kelemni Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //Si l'utilisateur déja authentifie une fois avec cette appareil il va être directement redirégé vers l'UI Home
      home: FutureBuilder(
        future: AuthMethods().getCurrentUser(),
        builder: (context, AsyncSnapshot<dynamic> snapshot){
          if(snapshot.hasData){
            return Home();
          } else {
            return SignIn();
          }
        },
      ),
    );
  }}
