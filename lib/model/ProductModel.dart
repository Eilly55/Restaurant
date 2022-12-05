import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uber_eats_restaurant_dashboard/constants.dart';

import 'VendorModel.dart';

class ProductModel {
  String categoryID;

  String description;

  String id;

  String photo;

  List<dynamic> photos;

  String price;

  String name;

  String vendorID;

  int quantity;

  bool publish;

  int calories;

  int grams;

  int proteins;

  int fats;

  bool veg;

  bool nonveg;
  String? disPrice = "0";
  bool takeaway;

  List<dynamic> size;

  List<dynamic> sizePrice;

  List<dynamic> addOnsTitle = [];

  List<dynamic> addOnsPrice = [];

  // GeoFireData geoFireData;

  String? addon_name;
  String? addon_price;

  //List<AddSizeDemo> lstSizeCustom=[];

  //List<AddAddonsDemo> lstAddOnsCustom=[];

  ProductModel({
    this.categoryID = '',
    this.description = '',
    this.id = '',
    this.photo = '',
    this.photos = const [],
    this.price = '',
    this.name = '',
    this.quantity = 0,
    this.vendorID = '',
    this.calories = 0,
    this.grams = 0,
    this.proteins = 0,
    this.fats = 0,
    this.publish = true,
    this.veg = false,
    this.nonveg = false,
    this.addon_name,
    this.addon_price,
    this.disPrice,
    this.takeaway = false,
    geoFireData,
    this.addOnsPrice = const [],
    this.addOnsTitle = const [],
    this.size = const [],
    this.sizePrice = const [],
    /*this.lstSizeCustom = const [],
        this.lstAddOnsCustom = const []*/
  });

  /*: this.geoFireData = geoFireData ??
            GeoFireData(
              geohash: "",
              geoPoint: GeoPoint(0.0, 0.0),
            );*/

  factory ProductModel.fromJson(Map<String, dynamic> parsedJson) {
    /*  List<AddSizeDemo> lstSizeCustom = parsedJson.containsKey('lstSizeCustom')
        ? List<AddSizeDemo>.from((parsedJson['lstSizeCustom'] as List<dynamic>)
        .map((e) => AddSizeDemo.fromJson(e))).toList()
        : [].cast<AddSizeDemo>();

    List<AddAddonsDemo> lstAddOnsCustom = parsedJson.containsKey('lstAddOnsCustom')
        ? List<AddAddonsDemo>.from((parsedJson['lstAddOnsCustom'] as List<dynamic>)
        .map((e) => AddAddonsDemo.fromJson(e))).toList()
        : [].cast<AddAddonsDemo>();*/
    return new ProductModel(
        categoryID: parsedJson['categoryID'] ?? '',
        description: parsedJson['description'] ?? '',
        id: parsedJson['id'] ?? '',
        photo: parsedJson['photo'] == '' ? placeholderImage : parsedJson['photo'],
        photos: parsedJson['photos'] ?? [],
        price: parsedJson['price'] ?? '',
        quantity: parsedJson['quantity'] ?? 0,
        name: parsedJson['name'] ?? '',
        vendorID: parsedJson['vendorID'] ?? '',
        publish: parsedJson['publish'] ?? true,
        calories: parsedJson['calories'] ?? 0,
        grams: parsedJson['grams'] ?? 0,
        proteins: parsedJson['proteins'] ?? 0,
        fats: parsedJson['fats'] ?? 0,
        nonveg: parsedJson['nonveg'] ?? false,
        disPrice: parsedJson['disPrice'] ?? '0',
        takeaway: parsedJson['takeawayOption'] == null ? false : parsedJson['takeawayOption'],
        size: parsedJson['size'] ?? [],
        sizePrice: parsedJson['sizePrice'] ?? [],
        addOnsPrice: parsedJson['addOnsPrice'] ?? [],
        addOnsTitle: parsedJson['addOnsTitle'] ?? [],
        geoFireData: parsedJson.containsKey('g')
            ? GeoFireData.fromJson(parsedJson['g'])
            : GeoFireData(
                geohash: "",
                geoPoint: GeoPoint(0.0, 0.0),
              ),
        addon_name: parsedJson["addon_name"] != null ? parsedJson["addon_name"] : "",
        addon_price: parsedJson["addon_price"] != null ? parsedJson["addon_price"] : "",
        //lstSizeCustom: lstSizeCustom,//parse dJson['lstSizeCustom'] != null?parsedJson['lstSizeCustom']:<AddSizeDemo>[] ,
        //lstAddOnsCustom: lstAddOnsCustom,//parsedJson['lstAddOnsCustom']!=null?parsedJson['lstAddOnsCustom']:<AddAddonsDemo>[],
        veg: parsedJson['veg'] ?? false);
  }

  Map<String, dynamic> toJson() {
    photos.toList().removeWhere((element) => element == null);
    return {
      'categoryID': this.categoryID,
      'description': this.description,
      'id': this.id,
      'photo': this.photo,
      'photos': this.photos,
      'price': this.price,
      'name': this.name,
      'quantity': this.quantity,
      'vendorID': this.vendorID,
      'publish': this.publish,
      'calories': this.calories,
      'grams': this.grams,
      'proteins': this.proteins,
      'fats': this.fats,
      'veg': this.veg,
      'nonveg': this.nonveg,
      'takeawayOption': this.takeaway,
      'disPrice': this.disPrice,
      'size': this.size,
      'sizePrice': this.sizePrice,
      "addOnsTitle": this.addOnsTitle,
      "addOnsPrice": this.addOnsPrice,
      //"g": this.geoFireData.toJson(),
      "addon_name": this.addon_name,
      "addon_price": this.addon_price
      //"lstAddOnsCustom":this.lstAddOnsCustom.map((e) => e.toJson()).toList(),
      //"lstSizeCustom":this.lstSizeCustom.map((e) => e.toJson()).toList()
    };
  }
}
/*
class AddAddonsDemo {
  String? name;
  int? index;
  String? price;
  bool isCheck;

  AddAddonsDemo({this.name, this.index, this.price, this.isCheck = false});

  factory AddAddonsDemo.fromJson(Map<String, dynamic> parsedJson) {
    return AddAddonsDemo(
        name: parsedJson["addName"],
        index: parsedJson["addIndex"],
        price: parsedJson["addPrice"],
        isCheck: parsedJson["addIsCheck"],
        );
  }

  Map<String, dynamic> toJson() {
    return {
      "addName": this.name,
      "addIndex": this.index,
      "addPrice": this.price,
      "addIsCheck": this.isCheck,
    };
  }
}

class AddSizeDemo {
  String? name;
  int? index;
  String? price;

  AddSizeDemo({this.name, this.index, this.price});

  factory AddSizeDemo.fromJson(Map<String, dynamic> parsedJson) {
    return AddSizeDemo(
      name: parsedJson["addSizeName"],
      index: parsedJson["addSizeIndex"],
      price: parsedJson["addSizePrice"],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      "addSizeName": this.name,
      "addSizeIndex": this.index,
      "addSizePrice": this.price,

    };
  }
}*/
