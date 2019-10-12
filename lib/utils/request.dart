import 'package:suplai/utils/constants.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> postRequest(email, password, body) async {
  final http.Response response = await http.post(
    SERVER_URL + 'login=$email&password=$password&db=$DB_NAME',
    body: json.encode(body),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );
  Map<String, dynamic> responseBody = json.decode(response.body);
  return responseBody;
}
