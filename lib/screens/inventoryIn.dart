import 'package:flutter/material.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

import 'package:suplai/utils/constants.dart';
import 'package:suplai/utils/request.dart';

class InventoryIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return InventoryInState();
  }
}

class InventoryInState extends State<InventoryIn> {
  Map<String, dynamic> prefsInfo = Map();
  bool scanned = false;
  String barcode = '';
  String email = '';
  String password = '';
  String result = '';
  List<DropdownMenuItem<String>> locationListDropDown = List();
  List<DropdownMenuItem<String>> vendorListDropDown = List();
  String currentLocation;
  String currentVendor;
  bool _isLoading = true;

  @override
  initState() {
    fetchLocationList();
    fetchVendorList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory In'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          locationDropDown('Select Location', locationListDropDown),
          vendorDropDown('Select Vendor', vendorListDropDown),
          iconButton('START SCANNING', Icons.space_bar, scan)
        ],
      ),
    );
  }

  fetchPrefsInfo() async {
    prefsInfo = await fetchInfo();
    setState(() {
      email = prefsInfo['email'];
      password = prefsInfo['password'];
      result = prefsInfo['result'];
    });
  }

  fetchLocationList() async {
    await fetchPrefsInfo();
    List<String> locationList = [];
    Map<String, dynamic> body = {
      "params": {
        "args": [
          COMPANY_NAME,
          result,
          password,
          "stock.location",
          "search_read",
          [],
          ["name"]
        ],
        "method": "execute",
        "service": "object"
      },
      "jsonrpc": VERSION,
      "method": "call"
    };
    Map<String, dynamic> responseBody =
        await postRequest(email, password, body);
    responseBody['result'].forEach((resultObj) {
      locationList.add(resultObj['name']);
    });
    setLocationItems(locationList);
  }

  fetchVendorList() async {
    await fetchPrefsInfo();
    List<String> vendorList = [];
    Map<String, dynamic> body = {
      "params": {
        "args": [
          COMPANY_NAME,
          result,
          password,
          "res.partner",
          "search_read",
          [
            ["supplier", "=", "true"]
          ],
          ["display_name"]
        ],
        "method": "execute",
        "service": "object"
      },
      "jsonrpc": VERSION,
      "method": "call"
    };
    Map<String, dynamic> responseBody =
        await postRequest(email, password, body);
    responseBody['result'].forEach((resultObj) {
      vendorList.add(resultObj['display_name']);
    });
    setVendorList(vendorList);
  }

  setLocationItems(List<String> locationList) {
    for (String location in locationList) {
      setState(() {
        locationListDropDown.add(new DropdownMenuItem(
            value: location,
            child: Text(
              location,
              style: TextStyle(color: colorCustom, fontSize: 20),
            )));
      });
    }
  }

  setVendorList(List<String> vendorList) {
    for (String vendor in vendorList) {
      setState(() {
        vendorListDropDown.add(new DropdownMenuItem(
            value: vendor,
            child: Text(
              vendor,
              style: TextStyle(color: colorCustom, fontSize: 20),
            )));
      });
    }
  }

  Widget locationDropDown(String label, List<DropdownMenuItem<String>> list) {
    return Container(
      margin: EdgeInsets.all(25),
      child: DropdownButton(
        elevation: 20,
        isExpanded: true,
        items: list,
        value: currentLocation,
        icon: Icon(
          Icons.arrow_drop_down,
          color: colorCustom,
        ),
        hint: Text(
          label,
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
        onChanged: (item) {
          setState(() {
            currentLocation = item;
          });
        },
      ),
    );
  }

  Widget vendorDropDown(String label, List<DropdownMenuItem<String>> list) {
    return Container(
      margin: EdgeInsets.all(25),
      child: DropdownButton(
        elevation: 20,
        isExpanded: true,
        items: list,
        value: currentVendor,
        icon: Icon(
          Icons.arrow_drop_down,
          color: colorCustom,
        ),
        hint: Text(
          label,
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
        onChanged: (item) {
          setState(() {
            currentVendor = item;
          });
        },
      ),
    );
  }

  Widget iconButton(String label, IconData icon, Function onPressed) {
    return Container(
      margin: EdgeInsets.all(20),
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.all(20),
        color: colorCustom,
        onPressed: onPressed,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(
            icon,
            color: Colors.white,
            size: 40,
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            child: Text(
              label,
              style: TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.left,
            ),
          ),
        ]),
      ),
    );
  }

  Future scan() async {
    try {
      // String barcode = await BarcodeScanner.scan();
      // print("BARCODE RECEIVED $barcode");
      // setState(() => this.barcode = barcode);
      setState(() {
        barcode = '1446897064';
        scanned = true;
      });
      barcodeSearch(barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          scanned = false;
        });
      } else {
        setState(() {
          scanned = false;
        });
      }
    } on FormatException {
      setState(() {
        scanned = false;
      });
    } catch (e) {
      setState(() {
        scanned = false;
      });
    }
  }

  barcodeSearch(String barcode) async {
    Map<String, dynamic> body = {
      "params": {
        "args": [
          COMPANY_NAME,
          result,
          password,
          "product.product",
          "search",
          [
            ["barcode", "=", "1446897064"]
          ]
        ],
        "method": "execute",
        "service": "object"
      },
      "jsonrpc": VERSION,
      "method": "call"
    };
    Map<String, dynamic> responseBody =
        await postRequest(email, password, body);

    print("BARCODE SEARCH RESPONSE $responseBody");
  }
}
