import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:suplai/utils/constants.dart';
import 'package:suplai/screens/home.dart';

class AuthenticationScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthenticationScreenState();
  }
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  String email;
  String password;
  bool _isLoading = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          key: _key,
          appBar: AppBar(
            title: Text('SuplAI'),
          ),
          backgroundColor: Colors.white,
          body: Center(
            child: SingleChildScrollView(
              child: SafeArea(
                child: Form(
                  key: _formKey,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        emailField(),
                        SizedBox(
                          height: 30,
                        ),
                        passwordField(),
                        SizedBox(
                          height: 30,
                        ),
                        iconButton('Log in', logIn)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: GestureDetector(
            onTap: () {
              // MaterialPageRoute route =
              //     MaterialPageRoute(builder: (context) => SignUpScreen());
              // Navigator.of(context).push(route);
            },
            child: Container(
              color: const Color(0xFF7AAFDB),
              height: 70,
              child: Center(
                child: Text(
                  'Not yet registered? Sign up',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ),
        ));
  }

  Widget emailField() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: TextFormField(
          decoration: InputDecoration(
            labelStyle: TextStyle(color: Colors.grey),
            labelText: 'Email',
            contentPadding: EdgeInsets.all(0.0),
          ),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Email is required';
            }
            return null;
          },
          keyboardType: TextInputType.emailAddress,
          onSaved: (String value) {
            email = value;
          },
        ));
  }

  Widget passwordField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelStyle: TextStyle(color: Colors.grey),
          labelText: 'Password',
          contentPadding: EdgeInsets.all(0.0),
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Password is required';
          }
          return null;
        },
        obscureText: true,
        onSaved: (String value) {
          password = value;
        },
      ),
    );
  }

  Widget iconButton(String label, Function onPressed) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.80,
      margin: EdgeInsets.all(20),
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.all(10),
        color: colorCustom,
        onPressed: onPressed,
        child: Container(
          child: _isLoading
              ? CupertinoActivityIndicator()
              : Text(
                  label,
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w300),
                  textAlign: TextAlign.left,
                ),
        ),
      ),
    );
  }

  logIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _isLoading = true;
    });
    if (!_formKey.currentState.validate()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    _formKey.currentState.save();

    Map<String, dynamic> body = {
      "params": {
        "args": [COMPANY_NAME, email, password],
        "method": "login",
        "service": "common"
      },
      "jsonrpc": VERSION,
      "method": "object"
    };

    final http.Response response = await http.post(
      SERVER_URL + 'login=$email&password=$password&db=$DB_NAME',
      body: json.encode(body),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
    );

    Map<String, dynamic> responseBody = json.decode(response.body);
    if (responseBody['result'] != false) {
      setState(() {
        _isLoading = false;
      });
      prefs.setBool('loggedIn', true);
      prefs.setString('email', email);
      prefs.setString('password', password);
      prefs.setInt('result', responseBody['result']);

      // ScopedModel.of<MainModel>(context, rebuildOnChange: false)
      //     .setUser(email, password, responseBody['result']);

      MaterialPageRoute route =
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen());
      Navigator.pushReplacement(context, route);
    } else {
      setState(() {
        _isLoading = false;
      });
      prefs.setBool('loggedIn', false);
      _key.currentState.showSnackBar(SnackBar(
        content: Text('Something went wrong! Please try again.'),
        duration: Duration(seconds: 1),
      ));
    }
  }
}
