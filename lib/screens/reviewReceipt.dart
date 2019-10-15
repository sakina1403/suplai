import 'package:flutter/material.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

import 'package:suplai/models/product.dart';
import 'package:suplai/models/vendor.dart';
import 'package:suplai/models/location.dart';
import 'package:suplai/models/receiptLineItem.dart';
import 'package:suplai/screens/productDetail.dart';
import 'package:suplai/screens/home.dart';
import 'package:suplai/utils/request.dart';
import 'package:suplai/utils/constants.dart';
import 'package:suplai/utils/fetchProductDetails.dart';

class ReviewReceipt extends StatefulWidget {
  final Product product;
  final Vendor vendor;
  final String quantity;
  final Location location;
  final int receiptNumber;

  final List<ReceiptLineItem> lineItems;
  ReviewReceipt(this.product, this.vendor, this.quantity, this.lineItems,
      this.location, this.receiptNumber);
  @override
  State<StatefulWidget> createState() {
    return _ReviewReceiptState();
  }
}

class _ReviewReceiptState extends State<ReviewReceipt> {
  bool scanned = true;
  String barcode = '';
  bool _isLoading = false;
  Map<String, dynamic> prefsInfo = Map();
  String email = '';
  String password = '';
  String result = '';
  Product scannedProduct = Product();
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  // Map<int, TableColumnWidth> columnWidths = {0:Table};
  List<TableRow> tablerows = [
    TableRow(children: [
      TableCell(
        child: Container(margin: EdgeInsets.all(10), child: Text('Name')),
      ),
      TableCell(
        child: Container(margin: EdgeInsets.all(10), child: Text('Qty')),
      ),
      TableCell(
        child: Container(margin: EdgeInsets.all(10), child: Text('Vendor')),
      )
    ])
  ];

  @override
  void initState() {
    fetchPrefsInfo();
    widget.lineItems.forEach((lineItem) {
      tablerows.add(TableRow(children: [
        TableCell(
          child:
              Container(margin: EdgeInsets.all(10), child: Text(lineItem.name)),
        ),
        TableCell(
          child: Container(
              margin: EdgeInsets.all(10), child: Text(lineItem.quantity)),
        ),
        TableCell(
          child: Container(
              margin: EdgeInsets.all(10), child: Text(lineItem.vendor)),
        )
      ]));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: Text('Review Receipt'),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            table(),
            iconButton('Scan more Products', scan),
            iconButton('Confirm and add to Warehouse', confirm),
          ],
        ),
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

  scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
      setState(() {
        barcode = barcode;
        scanned = true;
        _isLoading = true;
      });
      Product product = await barcodeSearch(
          barcode: barcode, email: email, password: password, result: result);

      setState(() {
        scannedProduct = product;
        _isLoading = false;
      });
      MaterialPageRoute route = MaterialPageRoute(
          builder: (BuildContext context) => ProductDetail(
                scannedProduct,
                widget.vendor,
                widget.location,
                receiptNumber: widget.receiptNumber,
                receiptLineItems: widget.lineItems,
              ));
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

  confirm() async {
    Map<String, dynamic> body = {
      "params": {
        "args": [
          COMPANY_NAME,
          result,
          password,
          "stock.picking",
          "write",
          [widget.receiptNumber],
          {"state": "done"}
        ],
        "method": "execute",
        "service": "object"
      },
      "jsonrpc": VERSION,
      "method": "call"
    };
    Map<String, dynamic> responseBody =
        await postRequest(email, password, body);
    if (responseBody['result']) {
      MaterialPageRoute route =
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen());
      Navigator.of(_key.currentContext).pushReplacement(route);
    } else {
      _key.currentState.showSnackBar(SnackBar(
        content: Text('Something went wrong! Please try again.'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  Widget table() {
    return Expanded(
        child: SingleChildScrollView(
      child: Table(
        border: TableBorder.all(width: 1.0, color: Colors.black),
        children: tablerows,
      ),
    ));
  }

  Widget iconButton(String label, Function onPressed) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(vertical: 15),
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: EdgeInsets.all(10),
        color: colorCustom,
        onPressed: onPressed,
        child: Container(
          child: Text(
            label,
            style: TextStyle(fontSize: 24, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
