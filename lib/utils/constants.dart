import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<int, Color> color = {
  50: Color.fromRGBO(73, 133, 195, .1),
  100: Color.fromRGBO(73, 133, 195, .2),
  200: Color.fromRGBO(73, 133, 195, .3),
  300: Color.fromRGBO(73, 133, 195, .4),
  400: Color.fromRGBO(73, 133, 195, .5),
  500: Color.fromRGBO(73, 133, 195, .6),
  600: Color.fromRGBO(73, 133, 195, .7),
  700: Color.fromRGBO(73, 133, 195, .8),
  800: Color.fromRGBO(73, 133, 195, .9),
  900: Color.fromRGBO(73, 133, 195, 1),
};
MaterialColor colorCustom = MaterialColor(0xFF4985C3, color);

const String SERVER_URL = 'http://3.84.219.18:8069/jsonrpc?';
const String COMPANY_NAME = 'aviabird';
const String VERSION = "2.0";
const String DB_NAME = "LVN001_v3";
const int PICKING_TYPE_ID_RECEIPT = 17;
const int PICKING_TYPE_ID_TRANSFER = 11;


Future<Map<String, dynamic>> fetchInfo() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String email = prefs.getString('email');
  String password = prefs.getString('password');
  String result = prefs.getInt('result').toString();
  return {'email': email, 'password': password, 'result': result};
}
