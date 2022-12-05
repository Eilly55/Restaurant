import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:uber_eats_restaurant_dashboard/constants.dart';
import 'package:uber_eats_restaurant_dashboard/main.dart';
import 'package:uber_eats_restaurant_dashboard/model/ProductModel.dart';
import 'package:uber_eats_restaurant_dashboard/model/categoryModel.dart';
import 'package:uber_eats_restaurant_dashboard/services/FirebaseHelper.dart';
import 'package:uber_eats_restaurant_dashboard/services/helper.dart';
import 'package:uber_eats_restaurant_dashboard/ui/fullScreenImageViewer/FullScreenImageViewer.dart';

class AddOrUpdateProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddOrUpdateProductScreen({Key? key, this.product}) : super(key: key);

  @override
  _AddOrUpdateProductScreenState createState() => _AddOrUpdateProductScreenState();
}

class _AddOrUpdateProductScreenState extends State<AddOrUpdateProductScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  GlobalKey<FormState> _key = GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  FireStoreUtils fireStoreUtils = FireStoreUtils();
  String? title, desc, price = "";
  List<dynamic> _mediaFiles = [];
  late bool publish;
  late ProductModel data;
  var _dropdownval;
  var catid;
  var _cal = 0;
  var _grm = 0;
  var _fats = 0;
  var _pro = 0;
  bool a = false;
  bool b = false;
  bool takeaway = false;
  List<VendorCategoryModel>? categorys;
  late Future<List<VendorCategoryModel>> category;
  var categoryId;
  var categoryName;
  var img;
  List<VendorCategoryModel> categoryLst = [];
  VendorCategoryModel? selectedCategory = null;
  TextEditingController rprice = new TextEditingController();
  TextEditingController disprice = TextEditingController();
  var lstAddSize = [], lstAddOnsTitle = [], lstAddSizePrice = [], lstAddOnPrice = [], aaraylist1 = [], listAddPrice = [];

  Set<String> aaraylist = {},
      //aaraylist1 = {},
      listAddTitle = {};

  //listAddPrice = {};

  bool isDiscountedPriceOk = false;

  Position? position;
  late Map<String, dynamic>? adminCommission;
  String? adminCommissionValue = "";

  @override
  void initState() {
    fireStoreUtils.getAdminCommission().then((value) {
      print(value.toString() + "===____1");
      if (value != null) {
        setState(() {
          adminCommission = value;
          adminCommissionValue = adminCommission!["adminCommission"].toString();
          print(adminCommission!["adminCommission"].toString() + "===____");
          print(adminCommission!["isAdminCommission"].toString() + "===____");
        });
      }
    });
    if (widget.product != null) {
      _mediaFiles.add(widget.product!.photo);
      _mediaFiles.addAll(widget.product!.photos);

      data = widget.product!;
      publish = data.publish;
      catid = widget.product!.categoryID;
      rprice.text = widget.product!.price.toString();
      disprice.text = widget.product!.disPrice.toString();
      aaraylist.clear();
      aaraylist1.clear();
      listAddPrice.clear();
      listAddTitle.clear();
      lstAddSize.clear();
      lstAddSizePrice.clear();
      lstAddSize.addAll(widget.product!.size);
      lstAddSizePrice.addAll(widget.product!.sizePrice);
      lstAddOnsTitle.addAll(widget.product!.addOnsTitle);
      lstAddOnPrice.addAll(widget.product!.addOnsPrice);
      takeaway = widget.product!.takeaway;
      isDiscountedPriceOk = false;
      getCat();
    }
    getLocation();

    _mediaFiles.add(null);
    super.initState();
    category = FireStoreUtils.getVendorCategoryById();
    category.then((value) {
      setState(() {
        categoryLst.addAll(value);
        if (widget.product != null) {
          for (int a = 0; a < categoryLst.length; a++) {
            if (widget.product!.categoryID == categoryLst[a].id) {
              selectedCategory = categoryLst[a];
            }
          }
        }
      });
      print(" == ++ == " + categoryLst.length.toString());
    });
  }

  getCat() {
    switch (catid) {
      case '11pMPqVV53qUsacuF6N1YD':
        _dropdownval = 'Burgers';
        break;

      case 'Sushi' '88pNxhccktxkSgIndZ8e':
        _dropdownval = 'Sushi';
        break;

      case '89sM0nIDtlLZxlvs2pPIAt':
        _dropdownval = 'Ramen';
        break;

      case 'OvjEAidyRSeuoH81pK4O':
        _dropdownval = 'Bar Food';
        break;

      case 'OyGmw2QiLYgY4y1v9B2V':
        _dropdownval = 'Breakfast';
        break;

      case 'WN3HSQMAjnZKd6vpKFUl':
        _dropdownval = 'Italian';
        break;

      case 'lNZkE309uNZB4v9jkChM':
        _dropdownval = 'Japanese';
        break;

      case 'wxHH0kJnCExOI6sHaXvX':
        _dropdownval = 'New Mexican';
        break;

      case 'zGhiepckNthq5FILtM4Eb':
        _dropdownval = 'Sandwiches';
        break;

      case 'zzq4LngLd8PWzYJfsvnjfV':
        _dropdownval = 'Mediterranean';
        break;

      default:
        _dropdownval = '';
    }
  }

  catselect() {
    switch (_dropdownval) {
      case 'Burgers':
        catid = '11pMPqVV53qUsacuF6N1YD';
        break;

      case 'Sushi':
        catid = '88pNxhccktxkSgIndZ8e';
        break;

      case 'Ramen':
        catid = '89sM0nIDtlLZxlvs2pPIAt';
        break;

      case 'Bar Food':
        catid = 'OvjEAidyRSeuoH81pK4O';
        break;

      case 'Breakfast':
        catid = 'OyGmw2QiLYgY4y1v9B2V';
        break;

      case 'Italian':
        catid = 'WN3HSQMAjnZKd6vpKFUl';
        break;

      case 'Japanese':
        catid = 'lNZkE309uNZB4v9jkChM';
        break;

      case 'New Mexican':
        catid = 'wxHH0kJnCExOI6sHaXvX';
        break;

      case 'Sandwiches':
        catid = 'zGhiepckNthq5FILtM4Eb';
        break;

      case 'Mediterranean':
        catid = 'zzq4LngLd8PWzYJfsvnjfV';
        break;

      default:
        catid = categoryId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
          title: Text(
        widget.product == null ? 'Add Product'.tr() : 'Edit Product'.tr(),
        style: TextStyle(
          color: isDarkMode(context) ? Color(0xFFFFFFFF) : Color(0Xff333333),
        ),
      )),
      body: Form(
        key: _key,
        autovalidateMode: _validate,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Admin Commission:'.tr(),
                            style: TextStyle(
                                color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            symbol + adminCommissionValue!,
                            style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Title'.tr(),
                        style:
                            TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                    TextFormField(
                      initialValue: widget.product?.name ?? '',
                      textAlign: TextAlign.start,
                      textInputAction: TextInputAction.next,
                      onSaved: (val) => title = val,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(fontSize: 18.0),
                      cursorColor: Color(COLOR_PRIMARY),
                      validator: validateEmptyField,
                      decoration: InputDecoration(
                        contentPadding: new EdgeInsets.only(left: 8, right: 8),
                        hintText: 'Name of the product'.tr(),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                    SizedBox(height: 16),
                    Divider(
                      thickness: 8,
                      height: 16,
                      color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Description'.tr(),
                        style:
                            TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                    TextFormField(
                      initialValue: widget.product?.description ?? '',
                      textAlign: TextAlign.start,
                      textInputAction: TextInputAction.next,
                      onSaved: (val) => desc = val,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(fontSize: 18.0),
                      cursorColor: Color(COLOR_PRIMARY),
                      validator: validateEmptyField,
                      decoration: InputDecoration(
                        contentPadding: new EdgeInsets.only(left: 8, right: 8),
                        hintText: 'Short description of the product'.tr(),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                    SizedBox(height: 16),
                    Divider(
                      thickness: 8,
                      height: 16,
                      color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Price'.tr(),
                          style: TextStyle(
                              color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              'Regular Price'.tr(),
                              style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 17),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2.3,
                              child: TextFormField(
                                maxLength: 5,
                                textInputAction: TextInputAction.done,
                                controller: rprice,
                                onChanged: (val) {
                                  setState(() {
                                    price = rprice.text.toString().trim();
                                  });
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                style: TextStyle(fontSize: 18.0),
                                cursorColor: Color(COLOR_PRIMARY),
                                validator: validateEmptyField,
                                decoration: InputDecoration(
                                  hintText: "0",
                                  contentPadding: new EdgeInsets.only(left: 8, right: 8),
                                  counterText: '',
                                  errorStyle: TextStyle(),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).errorColor),
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).errorColor),
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              'Discounted Price'.tr(),
                              style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 17),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 5),
                              width: MediaQuery.of(context).size.width / 2.25,
                              child: TextFormField(
                                maxLength: 5,
                                textInputAction: TextInputAction.done,
                                controller: disprice,
                                onChanged: (val) {
                                  setState(() {
                                    var regularPrice = double.parse(rprice.text.toString());
                                    var discountedPrice = double.parse(disprice.text.toString());

                                    if (discountedPrice > regularPrice) {
                                      isDiscountedPriceOk = true;
                                      final snackBar = SnackBar(
                                        content: Text(
                                          'Please enter valid discount price'.tr(),
                                          style: TextStyle(color: !isDarkMode(context) ? Colors.white : Colors.black),
                                        ),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    } else {
                                      isDiscountedPriceOk = false;
                                    }
                                  });
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                style: TextStyle(fontSize: 18.0),
                                cursorColor: Color(COLOR_PRIMARY),
                                //validator: validateEmptyField,
                                decoration: InputDecoration(
                                  hintText: "0",
                                  contentPadding: new EdgeInsets.only(left: 8, right: 8),
                                  counterText: '',
                                  errorStyle: TextStyle(),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                      borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).errorColor),
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).errorColor),
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                ),
                              ),
                            ),
                          ])
                        ],
                      ),
                    ),

                    Visibility(
                      visible: rprice.text.toString().isNotEmpty,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                disprice.text.toString().trim().isEmpty ? symbol + "0" : symbol + disprice.text,
                                style: TextStyle(color: Color(COLOR_PRIMARY), fontSize: 18),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                symbol + rprice.text,
                                style: TextStyle(
                                    color: isDarkMode(context) ? Colors.white : Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 18),
                              ),
                            ],
                          )),
                    ),

                    Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 8),
                        child: Text(
                          'Your item Price will be display like this.'.tr(),
                          style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.grey, fontSize: 15),
                        )),
                    Divider(
                      thickness: 8,
                      height: 16,
                      color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Product Details'.tr(),
                          style: TextStyle(
                              color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'Calories'.tr(),
                              style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 18),
                            )),
                        Container(
                            height: 150,
                            child: NumberPicker(
                                minValue: 0,
                                maxValue: 1000,
                                value: widget.product != null ? widget.product!.calories : _cal,
                                onChanged: (value) =>
                                    setState(() => widget.product != null ? widget.product!.calories = value : _cal = value))),
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'Grams'.tr(),
                              style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 18),
                            )),
                        Container(
                            height: 150,
                            child: NumberPicker(
                                minValue: 0,
                                maxValue: 1000,
                                value: widget.product != null ? widget.product!.grams : _grm,
                                onChanged: (value) =>
                                    setState(() => widget.product != null ? widget.product!.grams = value : _grm = value)))
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'Proteins'.tr(),
                              style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 18),
                            )),
                        Container(
                            height: 150,
                            child: NumberPicker(
                                minValue: 0,
                                maxValue: 1000,
                                value: widget.product != null ? widget.product!.proteins : _pro,
                                onChanged: (value) =>
                                    setState(() => widget.product != null ? widget.product!.proteins = value : _pro = value))),
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'Fats'.tr(),
                              style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 18),
                            )),
                        Container(
                            height: 150,
                            child: NumberPicker(
                                minValue: 0,
                                maxValue: 1000,
                                value: widget.product != null ? widget.product!.fats : _fats,
                                onChanged: (value) =>
                                    setState(() => widget.product != null ? widget.product!.fats = value : _fats = value)))
                      ],
                    ),
                    Divider(
                      thickness: 8,
                      height: 16,
                      color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Product Type'.tr(),
                        style:
                            TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Flexible(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SwitchListTile.adaptive(
                                activeColor: Color(COLOR_ACCENT),
                                title: Text('Veg'.tr(),
                                    style: TextStyle(
                                        fontSize: 16, color: isDarkMode(context) ? Colors.white : Colors.black, fontFamily: "Poppinsl")),
                                value: widget.product == null ? a : widget.product!.veg,
                                onChanged: (bool newValue) async {
                                  widget.product == null ? a = newValue : widget.product!.veg = newValue;
                                  a == true ? b = false : null;

                                  widget.product != null && widget.product!.veg == true ? widget.product!.nonveg = false : null;
                                  widget.product != null ? await fireStoreUtils.addOrUpdateProduct(widget.product!) : Center();
                                  setState(() {});
                                })
                          ],
                        )),
                        Image(
                          image: AssetImage("assets/images/verti_divider.png"),
                          height: 25,
                        ),
                        Flexible(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SwitchListTile.adaptive(
                                activeColor: Color(COLOR_ACCENT),
                                title: Text('Non-veg'.tr(),
                                    style: TextStyle(
                                        fontSize: 16, color: isDarkMode(context) ? Colors.white : Colors.black, fontFamily: "Poppins")),
                                value: widget.product == null ? b : widget.product!.nonveg,
                                onChanged: (bool newValue) async {
                                  widget.product == null ? b = newValue : widget.product!.nonveg = newValue;
                                  b == true ? a = false : null;
                                  widget.product != null && widget.product!.nonveg == true ? widget.product!.veg = false : null;
                                  widget.product != null ? await fireStoreUtils.addOrUpdateProduct(widget.product!) : Center();
                                  setState(() {});
                                })
                          ],
                        ))
                      ],
                    ),
                    Divider(
                      thickness: 8,
                      height: 16,
                      color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Enable Takeaway Option'.tr(),
                        style:
                            TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                    SwitchListTile.adaptive(
                        activeColor: Color(COLOR_ACCENT),
                        title: Text('Takeaway Option'.tr(),
                            style:
                                TextStyle(fontSize: 16, color: isDarkMode(context) ? Colors.white : Colors.black, fontFamily: "Poppinsl")),
                        value: takeaway,
                        onChanged: (bool newValue) async {
                          setState(() {
                            takeaway = newValue;
                          });
                        }),
                    Divider(
                      thickness: 8,
                      height: 16,
                      color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Add Photos'.tr(),
                        style:
                            TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                    SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          itemCount: _mediaFiles.length,
                          itemBuilder: (context, index) => _imageBuilder(_mediaFiles[index]),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 8,
                      height: 16,
                      color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Restaurant Category'.tr(),
                        style:
                            TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),

                    SizedBox(height: 5),
                    Container(
                      height: 60,
                      child: DropdownButtonFormField<VendorCategoryModel>(
                          validator: (date) => (date == null || selectedCategory!.title == 'Select Product Category')
                              ? 'Please select a category.'.tr()
                              : null,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(5),
                            ),

                            // filled: true,
                            //fillColor: Colors.blueAccent,
                          ),
                          //dropdownColor: Colors.blueAccent,
                          value: selectedCategory,
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                              categoryId = value!.id;
                              _dropdownval = value.title;
                            });
                          },
                          hint: Text('Select Product Category'.tr()),
                          items: categoryLst.map((VendorCategoryModel item) {
                            return DropdownMenuItem<VendorCategoryModel>(
                              child: Text(item.title),
                              value: item,
                            );
                          }).toList()),
                    ),

                    Divider(
                      thickness: 8,
                      height: 16,
                      color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Size'.tr(),
                            style: TextStyle(
                                color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey,
                                    width: 0.8,
                                  ),

                                  // color: Color(0xff000000),
                                  shape: BoxShape.circle),

                              // radius: 20,
                              child: IconButton(
                                icon: Icon(Icons.add),
                                color: Color(COLOR_PRIMARY),
                                iconSize: 25,
                                padding: EdgeInsets.only(bottom: 0),
                                onPressed: () {
                                  setState(() {
                                    lstAddSize.length++;
                                    lstAddSizePrice.length++;
                                  });
                                },
                              ),
                            ))
                      ],
                    ),
                    lstAddSize.length == 0
                        ? Container()
                        : Container(
                            width: MediaQuery.of(context).size.width * 1,
                            height: lstAddSize.length == 1 ? 70 : MediaQuery.of(context).size.height * (lstAddSize.length / 15),
                            child: ListView.builder(
                                itemCount: lstAddSize.length,
                                padding: EdgeInsets.only(bottom: 10),
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: EdgeInsets.only(left: 10),
                                          width: MediaQuery.of(context).size.width / 2.3,
                                          child: TextFormField(
                                            //maxLength: 5,
                                            initialValue: lstAddSize[index],
                                            textAlign: TextAlign.start,
                                            textInputAction: TextInputAction.done,
                                            onSaved: (val) {
                                              if (lstAddSize[index] == null || lstAddSize[index].toString().isEmpty) {
                                                lstAddSize[index] = val;
                                              } else {
                                                lstAddSize[index] = val;
                                              }
                                            },
                                            keyboardType: TextInputType.text,

                                            style: TextStyle(fontSize: 18.0),
                                            cursorColor: Color(COLOR_PRIMARY),
                                            //validator: validateEmptyField,
                                            decoration: InputDecoration(
                                                // contentPadding:
                                                //     new EdgeInsets.only(left: 8, right: 8),
                                                counterText: '',
                                                hintText: 'Add size'.tr(),
                                                errorStyle: TextStyle(),
                                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(COLOR_PRIMARY))),
                                                errorBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                                                ),
                                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400))),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: EdgeInsets.only(right: 0),
                                          width: MediaQuery.of(context).size.width / 2.3,
                                          child: TextFormField(
                                            maxLength: 5,
                                            initialValue: lstAddSizePrice[index],
                                            textAlign: TextAlign.start,
                                            textInputAction: TextInputAction.done,
                                            onSaved: (val) {
                                              if (lstAddSizePrice[index] == null || lstAddSizePrice[index].toString().isEmpty) {
                                                lstAddSizePrice[index] = val;
                                              } else {
                                                lstAddSizePrice[index] = val;
                                              }
                                            },
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                            ],
                                            style: TextStyle(fontSize: 18.0),
                                            cursorColor: Color(COLOR_PRIMARY),
                                            //validator: validateEmptyField,
                                            decoration: InputDecoration(
                                                // contentPadding:
                                                //     new EdgeInsets.only(left: 8, right: 8),
                                                counterText: '',
                                                hintText: '0',
                                                errorStyle: TextStyle(),
                                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(COLOR_PRIMARY))),
                                                errorBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                                                ),
                                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400))),
                                          ),
                                        ),
                                      ),
                                      /*Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 35,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                color: isDarkMode(context)
                                                    ? Colors.grey.shade700
                                                    : Colors.grey,
                                                width: 0.8,
                                              ),

                                              // color: Color(0xff000000),
                                              shape: BoxShape.circle),

                                          // radius: 20,
                                          child: IconButton(
                                            icon: Text("-",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Color(COLOR_PRIMARY)),),
                                            color: Color(COLOR_PRIMARY),
                                            iconSize: 20,
                                            padding: EdgeInsets.only(bottom: 0),
                                            onPressed: () {
                                              setState(() {
                                                print(index.toString()+"||||||||");
                                                */ /*for(int a=0;a<lstAddSize.length;a++){
                                                  if(a==index){
                                                    print(a.toString()+"{}{}{}{}}{}==========="+ lstAddSize[index].toString());
                                                    //lstAddSize.removeAt(a);
                                                    //lstAddSizePrice.removeAt(a);
                                                    */ /**/ /*lstAddSize.remove( lstAddSize[index]);
                                                    lstAddSize.removeAt(index);*/ /**/ /*


                                                  }else{

                                                  }
                                                }*/ /*
                                                //lstAddSize.removeWhere((item) => item == lstAddSize[index]);
                                                removeItem(index);
                                              });
                                            },
                                          ),
                                        ),
                                      )*/
                                    ],
                                  );
                                })),
                    Divider(
                      thickness: 8,
                      height: 16,
                      color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Addons'.tr(),
                            style: TextStyle(
                                color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey,
                                    width: 0.8,
                                  ),

                                  // color: Color(0xff000000),
                                  shape: BoxShape.circle),

                              // radius: 20,
                              child: IconButton(
                                icon: Icon(Icons.add),
                                color: Color(COLOR_PRIMARY),
                                iconSize: 25,
                                padding: EdgeInsets.only(bottom: 0),
                                onPressed: () {
                                  setState(() {
                                    lstAddOnsTitle.length++;
                                    lstAddOnPrice.length++;
                                    print(lstAddOnPrice.length.toString() + " {} " + lstAddOnsTitle.length.toString());
                                  });
                                },
                              ),
                            ))
                      ],
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width * 1,
                        height: lstAddOnsTitle.length == 1 ? 120 : MediaQuery.of(context).size.height * (lstAddOnsTitle.length / 7.2),
                        child: ListView.builder(
                            itemCount: lstAddOnsTitle.length,
                            padding: EdgeInsets.only(bottom: 10),
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              print("add on lenght ${lstAddOnsTitle.length}");
                              return Column(children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: EdgeInsets.only(left: 10),
                                        width: MediaQuery.of(context).size.width / 2.3,
                                        child: TextFormField(
                                          textAlign: TextAlign.start,
                                          textInputAction: TextInputAction.done,
                                          onSaved: (val) {
                                            setState(() {
                                              if (lstAddOnsTitle[index] == null || lstAddOnsTitle[index].toString().isEmpty) {
                                                lstAddOnsTitle[index] = val;
                                              } else {
                                                lstAddOnsTitle[index] = val;
                                              }
                                              print("add22 on lenght ${lstAddOnsTitle.length}");
                                            });
                                          },
                                          keyboardType: TextInputType.text,
                                          initialValue: lstAddOnsTitle[index],
                                          style: TextStyle(fontSize: 18.0),
                                          cursorColor: Color(COLOR_PRIMARY),
                                          //validator: validateEmptyField,
                                          decoration: InputDecoration(
                                              // contentPadding:
                                              //     new EdgeInsets.only(left: 8, right: 8),
                                              counterText: '',
                                              hintText: 'Add title'.tr(),
                                              errorStyle: TextStyle(),
                                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(COLOR_PRIMARY))),
                                              errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Theme.of(context).errorColor),
                                              ),
                                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400))),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: EdgeInsets.only(right: 0),
                                        width: MediaQuery.of(context).size.width / 2.3,
                                        child: TextFormField(
                                          maxLength: 5,
                                          initialValue: lstAddOnPrice[index],
                                          textAlign: TextAlign.start,
                                          textInputAction: TextInputAction.done,
                                          onSaved: (val) {
                                            print(lstAddOnsTitle[index].toString() + "***");

                                            if (lstAddOnPrice[index] == null || lstAddOnPrice[index].toString().isEmpty) {
                                              lstAddOnPrice[index] = val;
                                            } else {
                                              lstAddOnPrice[index] = val;
                                            }
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                          ],
                                          style: TextStyle(fontSize: 18.0),
                                          cursorColor: Color(COLOR_PRIMARY),
                                          //validator: validateEmptyField,
                                          decoration: InputDecoration(
                                              // contentPadding:
                                              //     new EdgeInsets.only(left: 8, right: 8),
                                              counterText: '',
                                              hintText: '0',
                                              errorStyle: TextStyle(),
                                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(COLOR_PRIMARY))),
                                              errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Theme.of(context).errorColor),
                                              ),
                                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400))),
                                        ),
                                      ),
                                    ),
                                    /* Expanded(
                                      flex: 1,
                                      child: Container(
                                        height: 35,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: isDarkMode(context)
                                                  ? Colors.grey.shade700
                                                  : Colors.grey,
                                              width: 0.8,
                                            ),

                                            // color: Color(0xff000000),
                                            shape: BoxShape.circle),

                                        // radius: 20,
                                        child: IconButton(
                                          icon: Text("-",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Color(COLOR_PRIMARY)),),
                                          color: Color(COLOR_PRIMARY),
                                          iconSize: 20,
                                          padding: EdgeInsets.only(bottom: 0),
                                          onPressed: () {
                                            setState(() {
                                              print(index.toString()+"||||||||");
                                              //lstAddSize.removeAt(index);
                                              //lstAddSizePrice.removeAt(index);
                                              //lstAddSize.remove(lstAddSize[index]);
                                              //lstAddSize.remove(lstAddSize[index]);
                                            });
                                          },
                                        ),
                                      ),
                                    )*/
                                  ],
                                ),
                                SizedBox(height: 10),
                              ]);
                            })),
                    widget.product != null
                        ? Divider(
                            thickness: 8,
                            height: 16,
                            color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
                          )
                        : Center(),
                    widget.product != null
                        ? Divider(
                            thickness: 8,
                            height: 16,
                            color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade300,
                          )
                        : Center(),
                    // : Container(),
                    widget.product != null
                        ? ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: double.infinity),
                            child: SwitchListTile.adaptive(
                                activeColor: Color(COLOR_ACCENT),
                                title: Text(
                                  'Publish'.tr(),
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: isDarkMode(context) ? Colors.white : Colors.black,
                                  ),
                                ).tr(),
                                value: publish,
                                onChanged: (bool newValue) {
                                  publish = newValue;
                                  setState(() {});
                                }))
                        : Container(),
                    widget.product != null
                        ? Padding(
                            padding: EdgeInsets.only(left: 20, top: 20, right: 20),
                            child: InkWell(
                                onTap: () => showProductOptionsSheet(data),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Delete Product".tr(),
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: isDarkMode(context) ? Colors.white : Colors.black,
                                      ),
                                    ).tr(),
                                    Image(
                                      image: AssetImage("assets/images/delete.png"),
                                      width: 30,
                                    )
                                  ],
                                )))
                        : Center(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    side: BorderSide(
                      color: Color(COLOR_PRIMARY),
                    ),
                  ),
                  primary: Color(COLOR_PRIMARY),
                ),
                onPressed: () => submit(),
                child: Text(
                  widget.product == null ? 'Add Product'.tr() : 'Edit Product'.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode(context) ? Colors.black : Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _imageBuilder(dynamic image) {
    bool isLastItem = image == null;
    return GestureDetector(
      onTap: () {
        isLastItem ? _pickImage() : _viewOrDeleteImage(image);
      },
      child: Container(
        width: 100,
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          color: isLastItem
              ? Color(COLOR_PRIMARY)
              : isDarkMode(context)
                  ? Colors.black
                  : Colors.white,
          child: isLastItem
              ? Icon(
                  CupertinoIcons.camera,
                  size: 40,
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: image is File
                      ? Image.file(
                          image,
                          fit: BoxFit.cover,
                        )
                      : displayImage(image),
                ),
        ),
      ),
    );
  }

  _viewOrDeleteImage(dynamic image) {
    final action = CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(context);
            _mediaFiles.removeLast();
            if (image is File) {
              _mediaFiles.removeWhere((value) => value is File && value.path == image.path);
            } else {
              _mediaFiles.removeWhere((value) => value is String && value == image);
            }
            _mediaFiles.add(null);
            setState(() {});
          },
          child: Text('Remove picture').tr(),
          isDestructiveAction: true,
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            push(context, image is File ? FullScreenImageViewer(imageFile: image) : FullScreenImageViewer(imageUrl: image));
          },
          isDefaultAction: true,
          child: Text('View picture').tr(),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _pickImage() {
    final action = CupertinoActionSheet(
      message: Text(
        'Add Picture',
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Choose image from gallery').tr(),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              _mediaFiles.removeLast();
              _mediaFiles.add(File(image.path));
              _mediaFiles.add(null);
              setState(() {});
            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture').tr(),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              _mediaFiles.removeLast();
              _mediaFiles.add(File(image.path));
              _mediaFiles.add(null);
              setState(() {});
            }
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  submit() async {
    if (a == false && b == false && widget.product == null) {
      showimgAlertDialog(context, 'Product type is Required!'.tr(), 'Please Select Veg or Non-Veg'.tr(), true);
    } else if (selectedCategory == null) {
      showimgAlertDialog(context, 'Category selection is Required!'.tr(), 'Please Select category'.tr(), true);
    } else if (isDiscountedPriceOk == true) {
      showimgAlertDialog(context, 'Valid amount is Required!'.tr(), 'Please enter valid discount price'.tr(), true);
    } else {
      catselect();
      if (_key.currentState?.validate() ?? false) {
        if (widget.product == null) {
          // lstAddOnsTitle.clear();
          // lstAddSize.clear();
        }
        _key.currentState!.save();
        ProductModel productModel = widget.product ?? ProductModel();
        await showProgress(context, widget.product == null ? 'Adding product...'.tr() : 'Applying edits...'.tr(), false);
        List<String> mediaFilesURLs = _mediaFiles.where((element) => element is String).toList().cast<String>();
        List<File> imagesToUpload = _mediaFiles.where((element) => element is File).toList().cast<File>();
        if (imagesToUpload.isNotEmpty) {
          updateProgress(
            'Uploading Product Images {} of {}'.tr(args: ['1', '${imagesToUpload.length}']),
          );
          for (int i = 0; i < imagesToUpload.length; i++) {
            if (i != 0)
              updateProgress(
                'Uploading Product Images {} of {}'.tr(
                  args: ['${i + 1}', '${imagesToUpload.length}'],
                ),
              );
            String url = await fireStoreUtils.uploadProductImage(
              imagesToUpload[i],
              'Uploading Product Images {} of {}'.tr(
                args: ['${i + 1}', '${imagesToUpload.length}'],
              ),
            );
            mediaFilesURLs.add(url);
          }
        }
        productModel.photo = mediaFilesURLs.isNotEmpty ? mediaFilesURLs.first : '';
        if (mediaFilesURLs.isNotEmpty) mediaFilesURLs.removeAt(0);
        productModel.photos = mediaFilesURLs;
        productModel.price = rprice.text.toString();
        productModel.disPrice = disprice.text.toString().isEmpty ? "0" : disprice.text.toString();
        productModel.description = desc!;
        productModel.calories = widget.product != null ? widget.product!.calories : _cal;
        productModel.grams = widget.product != null ? widget.product!.grams : _grm;
        productModel.proteins = widget.product != null ? widget.product!.proteins : _pro;
        productModel.fats = widget.product != null ? widget.product!.fats : _fats;
        productModel.name = title!;
        widget.product == null ? productModel.veg = a : productModel.veg = productModel.veg;
        widget.product == null ? productModel.nonveg = b : productModel.nonveg = productModel.nonveg;
        if (widget.product != null) {
          productModel.publish = publish;
        }
        productModel.vendorID = MyAppState.currentUser!.vendorID;
        productModel.categoryID = catid;

        for (int a = 0; a < lstAddSize.length; a++) {
          if (lstAddSize[a] == null || lstAddSize[a].toString().isEmpty) {
          } else {
            if (lstAddSize[a] != null && lstAddSizePrice[a] == null) {
              aaraylist1.add("0");
            } else {
              aaraylist.add(lstAddSize[a]);
              aaraylist1.add(lstAddSizePrice[a].toString().isEmpty ? "0" : lstAddSizePrice[a]);
            }
          }
        }

        /*for (int a = 0; a < lstAddSizePrice.length; a++) {
          if (lstAddSizePrice[a] == null || lstAddSizePrice[a].toString().isEmpty) {
          } else {

            aaraylist1.add(lstAddSizePrice[a]);
          }
        }*/

        for (int a = 0; a < lstAddOnsTitle.length; a++) {
          if (lstAddOnsTitle[a] == null || lstAddOnsTitle[a].toString().isEmpty) {
          } else {
            if (lstAddOnsTitle[a] != null && lstAddOnPrice[a] == null) {
              listAddPrice.add("0");
            } else {
              listAddTitle.add(lstAddOnsTitle[a]);
              listAddPrice.add(lstAddOnPrice[a].toString().isEmpty ? "0" : lstAddOnPrice[a]);
            }
          }
        }
        /* for (int a = 0; a < lstAddOnPrice.length; a++) {
          if (lstAddOnPrice[a] == null || lstAddOnPrice[a].toString().isEmpty) {

          } else {
            listAddPrice.add(lstAddOnPrice[a]);
          }
        }*/
        productModel.size = aaraylist.toList();
        productModel.sizePrice = aaraylist1.toList();
        productModel.addOnsTitle = listAddTitle.toList();
        productModel.addOnsPrice = listAddPrice.toList();
        productModel.takeaway = takeaway;
        //productModel.geoFireData = GeoFireData(geohash: randomAlphaNumeric(10),geoPoint: GeoPoint(position!.latitude, position!.longitude));

        //productModel.lstSizeCustom = aaa.toList();
        //productModel.lstAddOnsCustom = bbb.toList();

        await fireStoreUtils.addOrUpdateProduct(productModel);
        await hideProgress();
        Navigator.pop(context);
      } else {
        setState(() {
          _validate = AutovalidateMode.onUserInteraction;
        });
      }
    }
  }

  showProductOptionsSheet(ProductModel productModel) {
    final action = CupertinoActionSheet(
      message: Text(
        'Are you sure you want to delete this product?'.tr(),
        style: TextStyle(fontSize: 15.0),
      ).tr(),
      title: Text(
        '${productModel.name}',
        style: TextStyle(fontSize: 17.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('YesSureToDelete').tr(),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            Navigator.pop(context);
            fireStoreUtils.deleteProduct(productModel.id);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  showimgAlertDialog(BuildContext context, String title, String content, bool addOkButton) {
    Widget? okButton;
    if (addOkButton) {
      okButton = TextButton(
        child: Text('OK'.tr()),
        onPressed: () {
          Navigator.pop(context);
        },
      );
    }

    if (Platform.isIOS) {
      CupertinoAlertDialog alert = CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [if (okButton != null) okButton],
      );
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return alert;
          });
    } else {
      AlertDialog alert = AlertDialog(title: Text(title), content: Text(content), actions: [if (okButton != null) okButton]);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }

  void removeItem(int index) {
    setState(() {
      print(index.toString() + "{}{}{}{}}{}====");
      /* lstAddSize = List.from(lstAddSize)
        ..removeAt(index);
      lstAddSizePrice = List.from(lstAddSizePrice)
        ..removeAt(index);
      lstAddSize = List.from(lstAddSize)
        ..remove(lstAddSize[index]);
      lstAddSizePrice = List.from(lstAddSizePrice)
        ..remove(lstAddSizePrice[index]);*/
      lstAddSize = List.from(lstAddSize)..remove(lstAddSize[index]);
      /*lstAddSizePrice = List.from(lstAddSizePrice)
        ..remove(lstAddSizePrice[index]);*/
      /*lstAddSize.removeWhere((item){
        print(item.toString()+"{}{}{}{}}{}====123"+item == lstAddSize[index]);
        return item == lstAddSize[index];
      });*/
      //lstAddSize.clear();
      // lstAddSizePrice.clear();
      // lstAddSize.addAll(widget.product!.size);
      //lstAddSizePrice.addAll(widget.product!.sizePrice);
      print(lstAddSize.toList().toString() + "{}{}{}{}}{}====" + lstAddSizePrice.toList().toString() + "{}{}{}{}}{}====");
    });
  }

  Future<void> getLocation() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    print(position!.latitude.toString() + " -- == -- " + position!.longitude.toString());
  }
}
