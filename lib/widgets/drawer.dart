import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:suplai/screens/auth.dart';

class HomeDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeDrawer();
  }
}

class _HomeDrawer extends State<HomeDrawer> {
  int favCount = 0;
  @override
  void initState() {
    super.initState();
  }

  String userName = '';
  Widget logOutButton() {
    return ListTile(
      leading: Icon(
        Icons.call_made,
        color: Colors.grey,
      ),
      title: Text(
        'Sign Out',
        style: TextStyle(color: Colors.grey),
      ),
      onTap: () {
        // logoutUser(model);
        _showDialog(context);
      },
    );
  }

  void _showDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Sign Out"),
            content: new Text("Are you sure you want to sign out?"),
            actions: <Widget>[
              new FlatButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  logoutUser();
                },
              )
            ],
          );
        });
  }

  logoutUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    MaterialPageRoute route = MaterialPageRoute(
        builder: (BuildContext context) => AuthenticationScreen());
    Navigator.pushReplacement(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0.0),
        children: <Widget>[
          DrawerHeader(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '1.0.0',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
              ),
              ListTile(
                onTap: () {
                  Navigator.popUntil(
                      context, ModalRoute.withName(Navigator.defaultRouteName));
                },
                leading: Icon(
                  Icons.settings,
                  // color: colorCustom,
                ),
                title: Text(
                  'Settings',
                ),
              )
            ]),
          ),
          logOutButton()
        ],
      ),
    );
  }
}
