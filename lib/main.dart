import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:suplai/screens/home.dart';
import 'package:suplai/utils/constants.dart';
import 'package:suplai/screens/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  bool loggedIn = false;
  bool checked;
  @override
  void initState() {
    super.initState();
    checkLoggedIn();
  }

    checkLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedIn =
          prefs.getBool('loggedIn') != null ? prefs.getBool('loggedIn') : false;
      checked =
          prefs.getBool('checked') != null ? prefs.getBool('checked') : false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: colorCustom,
      ),
      home: loggedIn? HomeScreen() : AuthenticationScreen(),
    );
  }
}
