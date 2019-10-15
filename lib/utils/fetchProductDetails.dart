import 'package:suplai/utils/constants.dart';
import 'package:suplai/utils/request.dart';
import 'package:suplai/models/product.dart';

Future<Product> barcodeSearch(
    {String barcode, String result, String password, String email}) async {
  Map<String, dynamic> body = {
    "params": {
      "args": [
        COMPANY_NAME,
        result,
        password,
        "product.product",
        "search",
        [
          ["barcode", "=", barcode]
        ]
      ],
      "method": "execute",
      "service": "object"
    },
    "jsonrpc": VERSION,
    "method": "call"
  };
  Map<String, dynamic> responseBody = await postRequest(email, password, body);
  int productId = responseBody['result'].first;
  Product product = await productSearch(
      productId: productId, result: result, password: password, email: email);
  return product;
}

Future<Product> productSearch(
    {int productId, String result, String password, String email}) async {
  Map<String, dynamic> body = {
    "params": {
      "args": [
        COMPANY_NAME,
        result,
        password,
        "product.product",
        "read",
        [productId]
      ],
      "method": "execute",
      "service": "object"
    },
    "jsonrpc": VERSION,
    "method": "call"
  };
  Map<String, dynamic> responseBody = await postRequest(email, password, body);
  return Product(
      name: responseBody['result'].first['display_name'],
      id: responseBody['result'].first['id'],
      uomId: responseBody['result'].first['uom_id'].first.toString());
}
