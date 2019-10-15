import 'package:flutter/material.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

import 'package:suplai/utils/constants.dart';
import 'package:suplai/utils/fetchProductDetails.dart';
import 'package:suplai/utils/request.dart';
import 'package:suplai/screens/reviewReceipt.dart';
import 'package:suplai/models/vendor.dart';
import 'package:suplai/models/location.dart';
import 'package:suplai/models/product.dart';
import 'package:suplai/models/receiptLineItem.dart';

class ProductDetail extends StatefulWidget {
  final Product product;
  final Vendor vendor;
  final Location location;
  final int receiptNumber;
  final List<ReceiptLineItem> receiptLineItems;
  ProductDetail(this.product, this.vendor, this.location,
      {this.receiptNumber, this.receiptLineItems});
  @override
  State<StatefulWidget> createState() {
    return _ProductDetailState();
  }
}

class _ProductDetailState extends State<ProductDetail> {
  String quantity;
  bool scanned = true;
  String barcode = '';
  bool _isLoading = false;
  String email = '';
  String password = '';
  String result = '';
  Map<String, dynamic> prefsInfo = Map();
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  Product scannedProduct = Product();
  int receiptNumber;
  List<ReceiptLineItem> receiptItems = [];

  @override
  void initState() {
    fetchPrefsInfo();
    receiptNumber = widget.receiptNumber;
    receiptItems =
        widget.receiptLineItems == null ? [] : widget.receiptLineItems;
    scannedProduct = widget.product;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          key: _key,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('Product Detail'),
          ),
          body: Stack(children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Container(
                        child: Text(
                      widget.product.name,
                      style: TextStyle(fontSize: 35),
                    )),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Specify Quantity: ',
                          style: TextStyle(fontSize: 20),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          width: 100,
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                quantity = value;
                              });
                            },
                            decoration: InputDecoration(
                                labelText: 'Qty',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5))),
                          ),
                        )
                      ],
                    ),
                  ),
                  iconButton('Discard & Scan another Product', discard),
                  iconButton('Save & Scan another Product', save),
                  iconButton('Scanning complete', complete),
                  SizedBox(height: 20),
                ],
              ),
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
          ])),
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

  discard() {
    scan();
  }

  save() async {
    if (quantity == null) {
      _key.currentState.showSnackBar(SnackBar(
        content: Text('Please enter a quantity to continue!'),
        duration: Duration(seconds: 1),
      ));
      return;
    }
    if (receiptNumber == null) {
      await createReceipt();
    }

    await receiptLineCreate();
    setState(() {
      receiptItems.add(ReceiptLineItem(
          name: scannedProduct.name,
          vendor: widget.vendor.displayName,
          quantity: quantity));
    });
    scan();
  }

  complete() async {
    if (quantity == null) {
      _key.currentState.showSnackBar(SnackBar(
        content: Text('Please enter a quantity to continue!'),
        duration: Duration(seconds: 1),
      ));
      return;
    }
    await receiptLineCreate();
    setState(() {
      receiptItems.add(ReceiptLineItem(
          name: scannedProduct.name,
          vendor: widget.vendor.displayName,
          quantity: quantity));
    });
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => ReviewReceipt(widget.product, widget.vendor,
            quantity, receiptItems, widget.location, receiptNumber));
    Navigator.pushReplacement(context, route);
  }

  scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
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
                receiptNumber: receiptNumber,
                receiptLineItems: receiptItems,
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

  receiptLineCreate() async {
    Map<String, dynamic> body = {
      "params": {
        "args": [
          COMPANY_NAME,
          result,
          password,
          "stock.move",
          "create",
          {
            "name": scannedProduct.name,
            "picking_id": receiptNumber,
            "product_id": scannedProduct.id,
            "product_uom_qty": quantity,
            "product_uom": scannedProduct.uomId,
            "location_id": 1,
            "location_dest_id": widget.location.id
          }
        ],
        "method": "execute",
        "service": "object"
      },
      "jsonrpc": VERSION,
      "method": "call"
    };

    Map<String, dynamic> responseBody =
        await postRequest(email, password, body);
  }

  createReceipt() async {
    Map<String, dynamic> body = {
      "params": {
        "args": [
          COMPANY_NAME,
          result,
          password,
          "stock.picking",
          "create",
          {
            "partner_id": "14",
            "picking_type_id": PICKING_TYPE_ID,
            "location_dest_id": widget.location.id,
            "location_id": 1
          }
        ],
        "method": "execute",
        "service": "object"
      },
      "jsonrpc": VERSION,
      "method": "call"
    };
    Map<String, dynamic> responseBody =
        await postRequest(email, password, body);
    print(responseBody['result']);
    setState(() {
      receiptNumber = responseBody['result'];
    });
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
