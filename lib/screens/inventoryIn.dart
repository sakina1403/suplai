import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:suplai/utils/constants.dart';
import 'package:suplai/utils/request.dart';
import 'package:suplai/utils/fetchProductDetails.dart';
import 'package:suplai/screens/productDetail.dart';
import 'package:suplai/models/product.dart';
import 'package:suplai/models/vendor.dart';
import 'package:suplai/models/location.dart';
import 'package:suplai/scoped_models/main.dart';

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
  Location currentlocation;
  Vendor currentVendor;
  bool _isLoading = false;
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  Product scannedProduct = Product();
  List<Location> locationList = [];
  List<Vendor> vendorList = [];

  @override
  initState() {
    fetchlocationList();
    fetchVendorList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text('Inventory In'),
        ),
        body: Stack(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              locationDropDown('Select location', locationListDropDown),
              vendorDropDown('Select Vendor', vendorListDropDown),
              iconButton('START SCANNING', Icons.space_bar, scan)
            ],
          ),
          _isLoading
              ? Stack(
                  children: [
                    Opacity(
                      opacity: 0.3,
                      child: const ModalBarrier(
                          dismissible: false, color: Colors.grey),
                    ),
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                )
              : Container()
        ]));
  }

  fetchPrefsInfo() async {
    prefsInfo = await fetchInfo();
    setState(() {
      email = prefsInfo['email'];
      password = prefsInfo['password'];
      result = prefsInfo['result'];
    });
  }

  fetchlocationList() async {
    await fetchPrefsInfo();
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
      setState(() {
        locationList
            .add(Location(displayName: resultObj['name'], id: resultObj['id']));
      });
    });
    setlocationItems(locationList);
  }

  fetchVendorList() async {
    await fetchPrefsInfo();
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
      setState(() {
        vendorList.add(Vendor(
            displayName: resultObj['display_name'], id: resultObj['id']));
      });
    });
    setVendorList(vendorList);
  }

  setlocationItems(List<Location> locationList) {
    for (Location location in locationList) {
      setState(() {
        locationListDropDown.add(new DropdownMenuItem(
            value: location.displayName,
            child: Text(
              location.displayName,
              style: TextStyle(color: colorCustom, fontSize: 20),
            )));
      });
    }
  }

  setVendorList(List<Vendor> vendorList) {
    for (Vendor vendor in vendorList) {
      setState(() {
        vendorListDropDown.add(new DropdownMenuItem(
            value: vendor.displayName,
            child: Text(
              vendor.displayName,
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
        value: currentlocation == null ? null : currentlocation.displayName,
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
            currentlocation = locationList.firstWhere(
                (loc) => loc.displayName == item,
                orElse: () => locationList.first);
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
        value: currentVendor == null ? null : currentVendor.displayName,
        icon: Icon(
          Icons.arrow_drop_down,
          color: colorCustom,
        ),
        hint: Text(
          label,
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
        onChanged: (item) {
          vendorList.forEach((vendor) {
            setState(() {
              currentVendor = vendorList.firstWhere(
                  (loc) => loc.displayName == item,
                  orElse: () => vendorList.first);
            });
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

  scan() async {
    if (currentlocation == null || currentVendor == null) {
      _key.currentState.showSnackBar(SnackBar(
        content: Text('Please select a value for location and Vendor'),
        duration: Duration(seconds: 1),
      ));
      return;
    }
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        barcode = barcode;
        scanned = true;
        _isLoading = true;
      });

      // barcodeSearch(barcode);

      Product product = await barcodeSearch(
          barcode: barcode, email: email, password: password, result: result);

      setState(() {
        scannedProduct = product;
        _isLoading = false;
      });
      MaterialPageRoute route = MaterialPageRoute(
          builder: (BuildContext context) =>
              ProductDetail(scannedProduct, currentVendor, currentlocation));
      Navigator.of(_key.currentContext).pushReplacement(route);
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
}
