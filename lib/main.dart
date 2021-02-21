import 'package:flutter/material.dart';

import 'package:ucs_manager/screens/LoginScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.orange
      ),
      title: 'UCS Manager',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}