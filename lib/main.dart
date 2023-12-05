
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projetodese/Home.dart';

import 'Login.dart';
import 'RouteGenerator.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(home: Login(),
  theme: ThemeData(
    primaryColor: Color(0xff075E54),
    accentColor: Color(0xff25D366)
  ),
  initialRoute: "/",
  onGenerateRoute: RouteGenerator.generateRoute,
  debugShowCheckedModeBanner: false,));


}

