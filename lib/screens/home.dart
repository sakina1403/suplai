import 'package:flutter/material.dart';

import 'package:suplai/utils/constants.dart';
import 'package:suplai/screens/inventoryIn.dart';
import 'package:suplai/screens/transfer.dart';
import 'package:suplai/widgets/drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('suplAI', style: TextStyle(fontSize: 24),),
      ),
      drawer: HomeDrawer(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          iconButton('Inventory In', Icons.home, () {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => InventoryIn());
            Navigator.push(context, route);
          }),
          iconButton('Transfer', Icons.local_shipping, () {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (context) => Transfer());
            Navigator.push(context, route);
          }),
          iconButton('Consumption', Icons.data_usage, () {})
        ],
      ),
    );
  }

  Widget iconButton(String label, IconData icon, Function onPressed) {
    return Container(
      margin: EdgeInsets.all(20),
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: EdgeInsets.all(20),
        color: colorCustom,
        onPressed: onPressed,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            width: 180,
            child: Text(
              label.toUpperCase(),
              style: TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.left,
            ),
          ),
        ]),
      ),
    );
  }
}
