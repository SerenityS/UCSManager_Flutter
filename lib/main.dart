import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:ucs_manager/screens/LoginScreen.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          brightness: Brightness.dark,
          backgroundColor: Color(0xFF398AE5),
          titleTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          brightness: Brightness.dark,
          backgroundColor: Color(0xFF398AE5),
          titleTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      title: 'UCS Manager',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
