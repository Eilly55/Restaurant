import 'package:uber_eats_restaurant_dashboard/constants.dart';

class OrderProductModel {
  dynamic? extras;
  String? extras_price;
  String id;
  String name;
  String photo;
  String price;
  int quantity;
  String? size;
  String vendorID;

  OrderProductModel(
      {this.id = '',
      this.photo = '',
      this.price = '',
      this.name = '',
      this.quantity = 0,
      this.vendorID = '',
      this.size = "",
      this.extras = const [],
      this.extras_price = ""});

  factory OrderProductModel.fromJson(Map<String, dynamic> parsedJson) {
    dynamic extrasVal;
    if (parsedJson['extras'] == null) {
      extrasVal = List<String>.empty();
    } else {
      if (parsedJson['extras'] is String) {
        if (parsedJson['extras'] == '[]') {
          extrasVal = List<String>.empty();
        } else {
          String extraDecode = parsedJson['extras'].toString().replaceAll("[", "").replaceAll("]", "").replaceAll("\"", "");
          if (extraDecode.contains(",")) {
            extrasVal = extraDecode.split(",");
          } else {
            extrasVal = [extraDecode];
          }
        }
      }
      if (parsedJson['extras'] is List) {
        extrasVal = parsedJson['extras'].cast<String>();
      }
    }

    int quanVal = 0;
    if (parsedJson['quantity'] == null || parsedJson['quantity'] == double.nan || parsedJson['quantity'] == double.infinity) {
      quanVal = 0;
    } else {
      if (parsedJson['quantity'] is String) {
        quanVal = int.parse(parsedJson['quantity']);
      } else {
        quanVal = (parsedJson['quantity'] is double)
            ? (parsedJson["quantity"].isNaN ? 0 : (parsedJson['quantity'] as double).toInt())
            : parsedJson['quantity'];
      }
    }
    return new OrderProductModel(
      id: parsedJson['id'] ?? '',
      photo: parsedJson['photo'] == '' ? placeholderImage : parsedJson['photo'],
      price: parsedJson['price'] ?? '',
      quantity: quanVal,
      name: parsedJson['name'] ?? '',
      vendorID: parsedJson['vendorID'] ?? '',
      size: parsedJson['size'] != null ? parsedJson['size'].toString() : "",
      extras: extrasVal,
      extras_price: parsedJson["extras_price"] != null ? parsedJson["extras_price"] : "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'photo': this.photo,
      'price': this.price,
      'name': this.name,
      'quantity': this.quantity,
      'vendorID': this.vendorID,
      'size': this.size,
      "extras": this.extras,
      "extras_price": this.extras_price
    };
  }
}
