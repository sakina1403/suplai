import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:suplai/scoped_models/main.dart';

mixin UserModel on Model {
  bool _isAuthenticated = false;
  MainModel model;
  Map<String, String> _user;

  bool get isAuthenticated {
    return _isAuthenticated;
  }

  Map<String, String> get user {
    return _user;
  }

  loggedInUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String _isAuthenticated = prefs.getString('loggedIn');
  }

  void setUser(String email, String password, String result) {
    _user = {'email': email, 'password': password, 'result': result};
    notifyListeners();
  }
}
