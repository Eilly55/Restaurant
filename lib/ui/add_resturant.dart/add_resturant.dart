import 'dart:io';

import 'package:barcode_image/barcode_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as ImageVar;
import 'package:image_picker/image_picker.dart';
import 'package:multiselect/multiselect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uber_eats_restaurant_dashboard/main.dart';
import 'package:uber_eats_restaurant_dashboard/model/DeliveryChargeModel.dart';
import 'package:uber_eats_restaurant_dashboard/model/VendorModel.dart';
import 'package:uber_eats_restaurant_dashboard/model/categoryModel.dart';
import 'package:uber_eats_restaurant_dashboard/services/FirebaseHelper.dart';
import 'package:uber_eats_restaurant_dashboard/services/helper.dart';
import 'package:uber_eats_restaurant_dashboard/ui/QrCodeGenerator/QrCodeGenerator.dart';
import 'package:uber_eats_restaurant_dashboard/ui/fullScreenImageViewer/FullScreenImageViewer.dart';
import 'package:uber_eats_restaurant_dashboard/ui/restaurant_location/restaurant_location.dart';
import 'package:uuid/uuid.dart';

import '../../constants.dart';

class AddRestaurantScreen extends StatefulWidget {
  AddRestaurantScreen({Key? key}) : super(key: key);

  @override
  _AddRestaurantScreenState createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final restaurantName = TextEditingController();
  final description = TextEditingController();
  final phonenumber = TextEditingController();
  final deliverChargeKm = TextEditingController();
  final minDeliveryCharge = TextEditingController();
  final minDeliveryChargewkm = TextEditingController();
  TextEditingController time1 = TextEditingController();
  TextEditingController time2 = TextEditingController();
  List<String>? mediaFilesURLs;
  final _formKey = GlobalKey<FormState>();
  VendorModel? vendors;
  Future<VendorModel?>? vendor;
  List<VendorCategoryModel>? categorys;
  late Future<List<VendorCategoryModel>> category;
  var categoryId;
  var categoryName;
  var img;
  List<VendorCategoryModel> categoryLst = [];
  VendorCategoryModel? selectedCategory;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  bool isTimeValid = false;
  DeliveryChargeModel? deliveryChargeModel;
  var lat;
  var long;

  @override
  void dispose() {
    restaurantName.dispose();
    description.dispose();
    phonenumber.dispose();
    time1.dispose();
    time2.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getVendorData();
    FireStoreUtils.getDelivery().then((value) {
      setState(() {
        deliveryChargeModel = value;
        if (deliveryChargeModel != null && !deliveryChargeModel!.vendor_can_modify) {
          deliverChargeKm.text = deliveryChargeModel!.delivery_charges_per_km.toString();
          minDeliveryCharge.text = deliveryChargeModel!.minimum_delivery_charges.toString();
          minDeliveryChargewkm.text = deliveryChargeModel!.minimum_delivery_charges_within_km.toString();
        }
      });
    });
    // MyAppState.currentUser!.vendorID != '' ? vendor = FireStoreUtils.getVendor(MyAppState.currentUser!.vendorID) : Center();
    category = FireStoreUtils.getVendorCategoryById();
    category.then((value) {
      setState(() {
        categoryLst.addAll(value);
      });
      print(vendor.toString() + " == ++ == " + categoryLst.length.toString());
    });
  }

  final ImagePicker _imagePicker = ImagePicker();
  List<dynamic> _mediaFiles = [];
  List<String> selected = [];

  Map<dynamic, dynamic> selecte = {};
  Map<String, dynamic> filters = {};
  var yes = "Yes";
  var _dropdownval;

  var catid, catpic;
  var t1, t2;
  TimeOfDay? pickedTime;
  TimeOfDay initialTime = TimeOfDay.now();
  String selectCategoryName = "";
  var downloadUrl;

//  ['Good for Breakfast' , 'Good for Lunch' , 'Good for Dinner' ,
//            'Takes Reservations','Vegetarian Friendly','Live Music',
//'Outdoor Seating','Free Wi-Fi'],
  filter() {
    if (selected.contains('Good for Breakfast')) {
      filters['Good for Breakfast'] = 'Yes';
    } else {
      filters['Good for Breakfast'] = 'No';
    }
    if (selected.contains('Good for Lunch')) {
      filters['Good for Lunch'] = 'Yes';
    } else {
      filters['Good for Lunch'] = 'No';
    }

    if (selected.contains('Good for Dinner')) {
      filters['Good for Dinner'] = 'Yes';
    } else {
      filters['Good for Dinner'] = 'No';
    }

    if (selected.contains('Takes Reservations')) {
      filters['Takes Reservations'] = 'Yes';
    } else {
      filters['Takes Reservations'] = 'No';
    }

    if (selected.contains('Vegetarian Friendly')) {
      filters['Vegetarian Friendly'] = 'Yes';
    } else {
      filters['Vegetarian Friendly'] = 'No';
    }

    if (selected.contains('Live Music')) {
      filters['Live Music'] = 'Yes';
    } else {
      filters['Live Music'] = 'No';
    }

    if (selected.contains('Outdoor Seating')) {
      filters['Outdoor Seating'] = 'Yes';
    } else {
      filters['Outdoor Seating'] = 'No';
    }

    if (selected.contains('Free Wi-Fi')) {
      filters['Free Wi-Fi'] = 'Yes';
    } else {
      filters['Free Wi-Fi'] = 'No';
    }
  }

  catselect() {
    selectCategoryName = _dropdownval;
    print(selectCategoryName);
    switch (_dropdownval) {
      case 'Burgers':
        catid = '11pMPqVV53qUsacuF6N1YD';
        catpic = 'https://assets.bonappetit.com/photos/5d03bea59ffc67bff3c6f86e/master/pass/HLY_Lentil_Burger_Horizontal.jpg';
        break;

      case 'Sushi':
        catid = '88pNxhccktxkSgIndZ8e';
        catpic = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT9b7mENwtkOXhX0iGxIWrMrHx5XkCFsTf-Sn2m5UcAU3DVfWfzTg&s';
        break;

      case 'Ramen':
        catid = '89sM0nIDtlLZxlvs2pPIAt';
        catpic = 'https://cooknourishbliss.com/wp-content/uploads/2019/08/Healthy_breakfast_tacos.jpg';
        break;

      case 'Bar Food':
        catid = 'OvjEAidyRSeuoH81pK4O';
        catpic = 'https://assets3.thrillist.com/v1/image/1645737/size/tmg-article_default_mobile.jpg';
        break;

      case 'Breakfast':
        catid = 'OyGmw2QiLYgY4y1v9B2V';
        catpic = 'https://cdn.loveandlemons.com/wp-content/uploads/2019/09/breakfast.jpg';
        break;

      case 'Italian':
        catid = 'WN3HSQMAjnZKd6vpKFUl';
        catpic = 'https://covid19.lacounty.gov/wp-content/uploads/GettyImages-1128687123-1024x683.jpg';
        break;

      case 'Japanese':
        catid = 'lNZkE309uNZB4v9jkChM';
        catpic = 'https://images.japancentre.com/page_elements/image1s/1513/original/sushi-bars-best-japanese-food.jpg?1470240553';
        break;

      case 'New Mexican':
        catid = 'wxHH0kJnCExOI6sHaXvX';
        catpic =
            'https://cdn.vox-cdn.com/thumbor/tGMomWZZtevHTxvsFesNqKdyXoc=/0x0:4000x2666/1200x800/filters:focal(1680x1013:2320x1653)/cdn.vox-cdn.com/uploads/chorus_image/image/65871289/10_15_19_Team624_Condesa__158_Edit.0.jpg';
        break;

      case 'Sandwiches':
        catid = 'zGhiepckNthq5FILtM4Eb';
        catpic = 'https://www.eggs.ca/assets/RecipePhotos/_resampled/FillWyIxMjgwIiwiNjIwIl0/triple-sandwich-032.jpg';
        break;

      case 'Mediterranean':
        catid = 'zzq4LngLd8PWzYJfsvnjfV';
        catpic =
            'https://food.fnr.sndimg.com/content/dam/images/food/fullset/2009/8/13/0/FNM100109WE059_s4x3.jpg.rend.hgtvcom.966.725.suffix/1382539115451.jpeg';
        break;

      default:
        catid = '';
    }
  }

  VendorModel? vendorData;
  bool isLoading = true;

  getVendorData() async {
    if (MyAppState.currentUser!.vendorID != '') {
      await FireStoreUtils.getVendor(MyAppState.currentUser!.vendorID).then((value) {
        setState(() {
          vendorData = value;
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Color(COLOR_DARK) : null,
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Form(
                key: _formKey,
                autovalidateMode: _autoValidateMode,
                child: MyAppState.currentUser!.vendorID == ''
                    ? Column(
                        children: [
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Restaurant Name".tr(),
                                style: TextStyle(
                                    fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),

                          Container(
                            padding: const EdgeInsetsDirectional.only(start: 2, end: 20, bottom: 10),
                            child: TextFormField(
                                controller: restaurantName,
                                textAlignVertical: TextAlignVertical.center,
                                textInputAction: TextInputAction.next,
                                validator: validateEmptyField,
                                // onSaved: (text) => line1 = text,
                                style: TextStyle(fontSize: 18.0),
                                keyboardType: TextInputType.streetAddress,
                                cursorColor: Color(COLOR_PRIMARY),
                                // initialValue: MyAppState.currentUser!.shippingAddress.line1,
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                  hintText: 'Restaurant Name'.tr(),
                                  hintStyle: TextStyle(
                                      color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                                  ),

                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0XFFCCD6E2)),
                                    // borderRadius: BorderRadius.circular(8.0),
                                  ),
                                )),
                          ),
                          Container(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Categories".tr(),
                                style: TextStyle(
                                    fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),
                          Container(
                            height: 60,
                            child: DropdownButtonFormField<VendorCategoryModel>(
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
                                    selectCategoryName = value.title;
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

                          Container(
                              padding: EdgeInsets.only(top: 10),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Services".tr(),
                                style: TextStyle(
                                    fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),

                          DropDownMultiSelect(
                            onChanged: (List<String> x) {
                              setState(() {
                                selected = x;
                              });
                            },
                            options: [
                              'Good for Breakfast',
                              'Good for Lunch',
                              'Good for Dinner',
                              'Takes Reservations',
                              'Vegetarian Friendly',
                              'Live Music',
                              'Outdoor Seating',
                              'Free Wi-Fi'
                            ],
                            selectedValues: selected,
                            // childBuilder: selected.first,
                            whenEmpty: 'Select Something'.tr(),
                          ),
//       MultiSelectDialogField(
//   items: _animals.map((e) => MultiSelectItem(e, e.name)).toList(),
//   listType: MultiSelectListType.CHIP,
//   onConfirm: (values) {
//     _selectedAnimals = values;
//   },
// ),

                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Timing".tr(),
                                style: TextStyle(
                                    fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),

                          Row(children: [
                            Flexible(
                                child: Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: TextFormField(
                                        onTap: () async {
                                          TimeOfDay? pickedTime = await showTimePicker(
                                            initialTime: TimeOfDay.now(),
                                            context: context,
                                          );

                                          if (pickedTime != null) {
                                            print(pickedTime.format(context)); //output 10:51 PM

                                            setState(() {
                                              time1.text = pickedTime.format(context); //set the value of text field.
                                            });
                                          } else {
                                            print("Time is not selected".tr());
                                          }
                                        },
                                        readOnly: true,
                                        textAlignVertical: TextAlignVertical.center,
                                        textInputAction: TextInputAction.next,
                                        controller: time1,
                                        // initialValue: time1.text,
                                        validator: validateEmptyField,
                                        // onSaved: (text) => line1 = text,
                                        style: TextStyle(fontSize: 18.0),
                                        // scrollPadding: EdgeInsets.only(right: 10),
                                        keyboardType: TextInputType.streetAddress,
                                        cursorColor: Color(COLOR_PRIMARY),
                                        // initialValue: MyAppState.currentUser!.shippingAddress.line1,
                                        decoration: InputDecoration(
                                          // suffix: ,
                                          suffixIcon: Icon(Icons.keyboard_arrow_down),
                                          // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                          hintText: '10:00 AM',

                                          hintStyle: TextStyle(
                                              color: isDarkMode(context) ? Colors.white : Color(0Xff333333),
                                              fontSize: 17,
                                              fontFamily: "Poppinsm"),
                                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0XFFB1BCCA))),
                                        )))),
                            SizedBox(
                              width: 40,
                            ),
                            Flexible(
                                child: TextFormField(
                                    onTap: () async {
                                      TimeOfDay? pickedTime = await showTimePicker(
                                        initialTime: TimeOfDay.now(),
                                        context: context,
                                      );
                                      if (pickedTime != null) {
                                        //output 10:51 PM
                                        print("ADD===========1");

                                        time2.text = pickedTime.format(context);

                                        print(time2.text.toString());

                                        DateTime startDate = DateFormat("hh:mm a").parse(time1.text.toString());
                                        DateTime endDate = DateFormat("hh:mm a").parse(time2.text.toString());

                                        if (endDate.isAfter(startDate)) {
                                          print("{}{}{++++");

                                          setState(() {
                                            isTimeValid = true;
                                          });
                                        } else {
                                          print("{}{}{++++123");
                                          setState(() {
                                            isTimeValid = false;
                                          });
                                          /* final snackBar = SnackBar(
                                            content: Text(
                                                'Please select valid close restaurant time'),
                                            backgroundColor:
                                                !isDarkMode(context)
                                                    ? Colors.black
                                                    : Colors.white,
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);*/
                                          /* showimgAlertDialog(context, 'Please select valid time',
                                              'Please select valid close restaurant time', true);*/
                                          //showAlertDialog1(context);
                                        }
                                      } else {
                                        print("Time is not selected".tr());
                                      }
                                    },
                                    readOnly: true,
                                    textAlignVertical: TextAlignVertical.center,
                                    textInputAction: TextInputAction.next,
                                    controller: time2,
                                    validator: validateEmptyField,
                                    // onSaved: (text) => line1 = text,
                                    style: TextStyle(fontSize: 18.0),
                                    keyboardType: TextInputType.streetAddress,
                                    cursorColor: Color(COLOR_PRIMARY),
                                    // initialValue: MyAppState.currentUser!.shippingAddress.line1,
                                    decoration: InputDecoration(
                                      suffixIcon: Icon(Icons.keyboard_arrow_down),
                                      // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                      hintText: '10:00 PM',
                                      hintStyle: TextStyle(
                                          color: isDarkMode(context) ? Colors.white : Color(0Xff333333),
                                          fontSize: 17,
                                          fontFamily: "Poppinsm"),

                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                                        // borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ))),
//               DropdownButton(

//                 onTap: ()async{
//                  pickedTime = await showTimePicker(
//     context: context,
//     initialTime: initialTime,
// );
//                 },items: [],
//               ),
                          ]),
                          Container(
                              padding: EdgeInsets.only(top: 10),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Description".tr(),
                                style: TextStyle(
                                    fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),

                          Container(
                            padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
                            child: TextFormField(
                                controller: description,
                                textAlignVertical: TextAlignVertical.center,
                                textInputAction: TextInputAction.next,
                                validator: validateEmptyField,
                                // onSaved: (text) => line1 = text,
                                style: TextStyle(fontSize: 18.0),
                                keyboardType: TextInputType.streetAddress,
                                cursorColor: Color(COLOR_PRIMARY),
                                // initialValue: MyAppState.currentUser!.shippingAddress.line1,
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                  hintText: 'Description'.tr(),
                                  hintStyle: TextStyle(
                                      color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                                  ),

                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                                    // borderRadius: BorderRadius.circular(8.0),
                                  ),
                                )),
                          ),

                          Container(
                              padding: EdgeInsets.only(top: 5),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Phone Number".tr(),
                                style: TextStyle(
                                    fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),

                          Container(
                            padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
                            child: TextFormField(
                                controller: phonenumber,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                ],
                                textAlignVertical: TextAlignVertical.center,
                                textInputAction: TextInputAction.next,
                                validator: validateEmptyField,
                                // onSaved: (text) => line1 = text,
                                style: TextStyle(fontSize: 18.0),
                                keyboardType: TextInputType.number,
                                cursorColor: Color(COLOR_PRIMARY),
                                // initialValue: MyAppState.currentUser!.shippingAddress.line1,
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                  hintText: 'Phone Number'.tr(),
                                  hintStyle: TextStyle(
                                      color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                                  ),

                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                                    // borderRadius: BorderRadius.circular(8.0),
                                  ),
                                )),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SwitchListTile.adaptive(
                            activeColor: Color(COLOR_ACCENT),
                            title: Text(
                              'Delivery Settings'.tr(),
                              style:
                                  TextStyle(fontSize: 17, color: isDarkMode(context) ? Colors.white : Colors.black, fontFamily: "Poppinsm"),
                            ),
                            value: deliveryChargeModel!.vendor_can_modify,
                            onChanged: (value) {},
                          ),
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Delivery Charge Per km".tr(),
                                style: TextStyle(
                                    fontSize: 15, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),
                          Container(
                            padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
                            child: TextFormField(
                                controller: deliverChargeKm,
                                textAlignVertical: TextAlignVertical.center,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  print("value os $value");
                                  if (value == null || value.isEmpty) {
                                    return "Invalid value".tr();
                                  }
                                  return null;
                                },
                                enabled: deliveryChargeModel!.vendor_can_modify,
                                onSaved: (text) => deliverChargeKm.text = text!,
                                style: TextStyle(fontSize: 18.0),
                                keyboardType: TextInputType.number,
                                cursorColor: Color(COLOR_PRIMARY),
                                // initialValue: vendor.phonenumber,
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                  hintText: 'Delivery Charge Per km'.tr(),
                                  hintStyle: TextStyle(
                                      color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                                  ),

                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                                    // borderRadius: BorderRadius.circular(8.0),
                                  ),
                                )),
                          ),
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Min Delivery Charge".tr(),
                                style: TextStyle(
                                    fontSize: 15, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),
                          Container(
                            padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
                            child: TextFormField(
                                enabled: deliveryChargeModel!.vendor_can_modify,
                                controller: minDeliveryCharge,
                                textAlignVertical: TextAlignVertical.center,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Invalid value".tr();
                                  }
                                  return null;
                                },
                                onSaved: (text) => minDeliveryCharge.text = text!,
                                style: TextStyle(fontSize: 18.0),
                                keyboardType: TextInputType.number,
                                cursorColor: Color(COLOR_PRIMARY),
                                // initialValue: vendor.phonenumber,
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                  hintText: 'Min Delivery Charge'.tr(),
                                  hintStyle: TextStyle(
                                      color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                                  ),

                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                                    // borderRadius: BorderRadius.circular(8.0),
                                  ),
                                )),
                          ),
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Min Delivery Charge within km".tr(),
                                style: TextStyle(
                                    fontSize: 15, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
                              )),
                          Container(
                            padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
                            child: TextFormField(
                                controller: minDeliveryChargewkm,
                                enabled: deliveryChargeModel!.vendor_can_modify,
                                textAlignVertical: TextAlignVertical.center,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Invalid value".tr();
                                  }
                                  return null;
                                },
                                onSaved: (text) => minDeliveryChargewkm.text = text!,
                                style: TextStyle(fontSize: 18.0),
                                keyboardType: TextInputType.number,
                                cursorColor: Color(COLOR_PRIMARY),
                                // initialValue: vendor.phonenumber,
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                  hintText: 'Min Delivery Charge within km'.tr(),
                                  hintStyle: TextStyle(
                                      color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                                  ),

                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                                    // borderRadius: BorderRadius.circular(8.0),
                                  ),
                                )),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          _mediaFiles.isEmpty == true
                              ? InkWell(
                                  onTap: () {
                                    _pickImage();
                                  },
                                  child: Image(
                                    image: AssetImage("assets/images/add_img.png"),
                                    width: MediaQuery.of(context).size.width * 1,
                                    height: MediaQuery.of(context).size.height * 0.2,
                                  ))
                              : _imageBuilder(_mediaFiles.first)
                        ],
                      )
                    : isLoading == true
                        ? Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator.adaptive(
                              valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                            ),
                          )
                        : buildrow(vendorData!))),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                    color: Color(COLOR_PRIMARY),
                  ),
                ),
                primary: Color(COLOR_PRIMARY),
              ),
              onPressed: () {
                validate();
              },
              child: Text(
                'CONTINUE'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                ),
              ),
            ),
            Visibility(
              visible: MyAppState.currentUser!.vendorID != '',
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: Color(COLOR_PRIMARY),
                      ),
                    ),
                    primary: Color(COLOR_PRIMARY),
                  ),
                  onPressed: () async {
                    final image = ImageVar.Image(600, 600);
                    ImageVar.fill(image, ImageVar.getColor(255, 255, 255));
                    drawBarcode(
                        image, Barcode.qrCode(), '{"vendorid":"${MyAppState.currentUser!.vendorID}","vendorname":"${vendors!.title}"}',
                        font: ImageVar.arial_24);
                    // Save the image
                    Directory appDocDir = await getApplicationDocumentsDirectory();
                    String appDocPath = appDocDir.path;
                    print("path $appDocPath");
                    File file = File('$appDocPath/barcode${MyAppState.currentUser!.vendorID}.png');
                    if (!await file.exists()) {
                      await file.create();
                    } else {
                      await file.delete();
                      await file.create();
                    }
                    file.writeAsBytesSync(ImageVar.encodePng(image));
                    push(context, QrCodeGenerator(vendorModel: vendors!));
                  },
                  child: Text(
                    'Generate QR Code'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode(context) ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildrow(VendorModel vendor) {
    // _mediaFiles.add(vendor.photo);
    // print(vendor.title);

    print(vendor.categoryTitle.toString() + "{}{}{}{}{}{}{}{{{}{}{}{}{}{}{{");
    VendorCategoryModel vendorCategoryModel = VendorCategoryModel(id: vendor.categoryID, title: vendor.categoryTitle);
    print(vendorCategoryModel.title.toString() + "||||");

    for (int a = 0; a < categoryLst.length; a++) {
      if (categoryLst[a].id == vendorCategoryModel.id) {
        selectedCategory = categoryLst[a];
      }
    }
    vendors = vendor;
    img = vendor.photo;
    time2.text = vendor.closetime;
    time1.text = vendor.opentime;
    if (deliveryChargeModel != null && deliveryChargeModel!.vendor_can_modify && vendor.DeliveryCharge != null) {
      deliverChargeKm.text = vendor.DeliveryCharge!.delivery_charges_per_km.toString();
      minDeliveryCharge.text = vendor.DeliveryCharge!.minimum_delivery_charges.toString();
      minDeliveryChargewkm.text = vendor.DeliveryCharge!.minimum_delivery_charges_within_km.toString();
    }

    isTimeValid = true;

    ////////service
    selected.isEmpty
        ? vendor.filters.forEach((key, value) {
            if (value.contains("Yes")) {
              selected.add(key);
            }
          })
        : null;
    restaurantName.text = vendor.title;
    description.text = vendor.description;
    phonenumber.text = vendor.phonenumber;
    // catselect();
    return Column(children: [
      Container(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Restaurant Name".tr(),
            style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),

      Container(
        padding: const EdgeInsetsDirectional.only(start: 2, end: 20, bottom: 10),
        child: TextFormField(
            controller: restaurantName,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.next,
            validator: validateEmptyField,
            // initialValue: vendor.title,
            onSaved: (text) => restaurantName.text = text!,
            style: TextStyle(fontSize: 18.0),
            keyboardType: TextInputType.streetAddress,
            cursorColor: Color(COLOR_PRIMARY),
            // initialValue: MyAppState.currentUser!.shippingAddress.line1,
            decoration: InputDecoration(
              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
              hintText: 'Restaurant Name'.tr(),
              hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff696A75), fontSize: 17, fontFamily: "Poppinsm"),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
              ),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0XFFCCD6E2)),
                // borderRadius: BorderRadius.circular(8.0),
              ),
            )),
      ),
      Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Categories".tr(),
            style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),

      Container(
        height: 60,
        child: DropdownButtonFormField<VendorCategoryModel>(
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
                selectCategoryName = value.title;
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

      // DropdownButtonHideUnderline(
      //     child: DropdownButtonFormField(
      //   //  validator: (value) => value == null ? 'field required' : null,
      //   icon: Icon(Icons.keyboard_arrow_down),

      //   hint: _dropdownval == null
      //       ? Text('Select Product Category',
      //           style: TextStyle(
      //               color: Color(0Xff333333),
      //               fontSize: 17,
      //               fontFamily: "Poppinsm"))
      //       : Text(_dropdownval.toString(),
      //           style: TextStyle(
      //               color:
      //                   isDarkMode(context) ? Colors.white : Color(0Xff333333),
      //               fontSize: 17,
      //               fontFamily: "Poppinsm")),
      //   items: <String>[
      //     'Burgers',
      //     'Sushi',
      //     'Ramen',
      //     'Bar Food',
      //     'Breakfast',
      //     'Italian',
      //     'Japanese',
      //     'New Mexican',
      //     'Sandwiches',
      //     'Mediterranean'
      //   ].map((String value) {
      //     return DropdownMenuItem<String>(
      //       value: value,
      //       child: Text(value),
      //     );
      //   }).toList(),
      //   isExpanded: true,

      //   iconSize: 30.0,
      //   onChanged: (value) {
      //     // vendor.categoryTitle?

      //     // setState(() {
      //     value != null ? _dropdownval = value : null;

      //     catselect();
      //     // });
      //   },
      // )),

      Container(
          padding: EdgeInsets.only(top: 10),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Services".tr(),
            style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),

      DropDownMultiSelect(
        onChanged: (List<String> x) {
          x = selected;

          //  vendor.filters.keys.toList()= x;
        },
        options: [
          'Good for Breakfast',
          'Good for Lunch',
          'Good for Dinner',
          'Takes Reservations',
          'Vegetarian Friendly',
          'Live Music',
          'Outdoor Seating',
          'Free Wi-Fi'
        ],
        selectedValues: selected,

        // childBuilder: selected.first,
        whenEmpty: 'Select Something'.tr(),
      ),

      Container(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Timing".tr(),
            style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),

      Row(children: [
        Flexible(
            child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: TextFormField(
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        initialTime: TimeOfDay.now(),
                        context: context,
                      );

                      if (pickedTime != null) {
                        print(pickedTime.format(context)); //output 10:51 PM

                        time1.text = pickedTime.format(context); //set the value of text field.

                      } else {
                        print("Time is not selected".tr());
                      }
                    },
                    readOnly: true,
                    textAlignVertical: TextAlignVertical.center,
                    textInputAction: TextInputAction.next,
                    controller: time1,
                    // initialValue: time1.text,
                    validator: validateEmptyField,
                    // onSaved: (text) => line1 = text,
                    style: TextStyle(fontSize: 18.0),
                    // scrollPadding: EdgeInsets.only(right: 10),
                    keyboardType: TextInputType.streetAddress,
                    cursorColor: Color(COLOR_PRIMARY),
                    // initialValue: MyAppState.currentUser!.shippingAddress.line1,
                    decoration: InputDecoration(
                      // suffix: ,
                      suffixIcon: Icon(Icons.keyboard_arrow_down),
                      // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                      hintText: '10:00 AM',

                      hintStyle:
                          TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0XFFB1BCCA))),
                    )))),
        SizedBox(
          width: 40,
        ),
        Flexible(
            child: TextFormField(
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    initialTime: TimeOfDay.now(),
                    context: context,
                  );

                  if (pickedTime != null) {
                    print(pickedTime.format(context));
                    print("EDIT===========");
                    time2.text = pickedTime.format(context);

                    DateTime startDate = DateFormat("hh:mm a").parse(time1.text.toString());
                    DateTime endDate = DateFormat("hh:mm a").parse(time2.text.toString());

                    if (endDate.isAfter(startDate)) {
                      print("{}{}{++++");
                      setState(() {
                        isTimeValid = true;
                      });
                    } else {
                      setState(() {
                        isTimeValid = false;
                      });
                      print("{}{}{++++123");
                      /*    final snackBar = SnackBar(
                        content: Text(
                          'Please select valid close restaurant time',
                          style: TextStyle(
                              color: !isDarkMode(context)
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);*/
                      /* showimgAlertDialog(context, 'Please select valid time',
                          'Please select valid close restaurant time', true);*/
                      //showAlertDialog1(context);
                    } //set the value of text field.

                  } else {
                    print("Time is not selected".tr());
                  }
                },
                readOnly: true,
                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.next,
                controller: time2,
                validator: validateEmptyField,
                // onSaved: (text) => line1 = text,
                style: TextStyle(fontSize: 18.0),
                keyboardType: TextInputType.streetAddress,
                cursorColor: Color(COLOR_PRIMARY),
                // initialValue: MyAppState.currentUser!.shippingAddress.line1,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.keyboard_arrow_down),
                  // contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  hintText: '10:00 PM',
                  hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),

                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                    // borderRadius: BorderRadius.circular(8.0),
                  ),
                ))),
//               DropdownButton(

//                 onTap: ()async{
//                  pickedTime = await showTimePicker(
//     context: context,
//     initialTime: initialTime,
// );
//                 },items: [],
//               ),
      ]),
      Container(
          padding: EdgeInsets.only(top: 10),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Description".tr(),
            style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),

      Container(
        padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
        child: TextFormField(
            controller: description,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.next,
            validator: validateEmptyField,
            onSaved: (text) => description.text = text!,
            style: TextStyle(fontSize: 18.0),
            keyboardType: TextInputType.streetAddress,
            cursorColor: Color(COLOR_PRIMARY),
            // initialValue: vendor.description,
            decoration: InputDecoration(
              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
              hintText: 'Description'.tr(),
              hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
              ),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                // borderRadius: BorderRadius.circular(8.0),
              ),
            )),
      ),
      Container(
          padding: EdgeInsets.only(top: 10),
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Phone Number".tr(),
            style: TextStyle(fontSize: 17, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),

      Container(
        padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
        child: TextFormField(
            controller: phonenumber,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.next,
            validator: validateMobile,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            onSaved: (text) => phonenumber.text = text!,
            style: TextStyle(fontSize: 18.0),
            keyboardType: TextInputType.streetAddress,
            cursorColor: Color(COLOR_PRIMARY),
            // initialValue: vendor.phonenumber,
            decoration: InputDecoration(
              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
              hintText: 'Phone Number'.tr(),
              hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
              ),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                // borderRadius: BorderRadius.circular(8.0),
              ),
            )),
      ),
      SizedBox(
        height: 10,
      ),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.all(0),
        activeColor: Color(COLOR_ACCENT),
        title: Text(
          'Delivery Settings'.tr(),
          style: TextStyle(fontSize: 17, color: isDarkMode(context) ? Colors.white : Color(0Xff696A75), fontFamily: "Poppinsl"),
        ),
        value: deliveryChargeModel!.vendor_can_modify,
        onChanged: null,
      ),
      Container(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Delivery Charge Per km".tr(),
            style: TextStyle(fontSize: 15, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),
      Container(
        padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
        child: TextFormField(
            controller: deliverChargeKm,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Invalid value".tr();
              }
              return null;
            },
            enabled: deliveryChargeModel!.vendor_can_modify,
            onSaved: (text) => deliverChargeKm.text = text!,
            style: TextStyle(fontSize: 18.0),
            keyboardType: TextInputType.number,
            cursorColor: Color(COLOR_PRIMARY),
            // initialValue: vendor.phonenumber,
            decoration: InputDecoration(
              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
              hintText: 'Delivery Charge Per km'.tr(),
              hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
              ),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                // borderRadius: BorderRadius.circular(8.0),
              ),
            )),
      ),
      Container(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Min Delivery Charge".tr(),
            style: TextStyle(fontSize: 15, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),
      Container(
        padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
        child: TextFormField(
            enabled: deliveryChargeModel!.vendor_can_modify,
            controller: minDeliveryCharge,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Invalid value".tr();
              }
              return null;
            },
            onSaved: (text) => minDeliveryCharge.text = text!,
            style: TextStyle(fontSize: 18.0),
            keyboardType: TextInputType.number,
            cursorColor: Color(COLOR_PRIMARY),
            // initialValue: vendor.phonenumber,
            decoration: InputDecoration(
              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
              hintText: 'Min Delivery Charge'.tr(),
              hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
              ),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                // borderRadius: BorderRadius.circular(8.0),
              ),
            )),
      ),
      Container(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            "Min Delivery Charge within km".tr(),
            style: TextStyle(fontSize: 15, fontFamily: "Poppinsl", color: isDarkMode(context) ? Colors.white : Color(0Xff696A75)),
          )),
      Container(
        padding: const EdgeInsetsDirectional.only(end: 20, bottom: 10),
        child: TextFormField(
            controller: minDeliveryChargewkm,
            enabled: deliveryChargeModel!.vendor_can_modify,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Invalid value".tr();
              }
              return null;
            },
            onSaved: (text) => minDeliveryChargewkm.text = text!,
            style: TextStyle(fontSize: 18.0),
            keyboardType: TextInputType.number,
            cursorColor: Color(COLOR_PRIMARY),
            // initialValue: vendor.phonenumber,
            decoration: InputDecoration(
              // contentPadding: EdgeInsets.symmetric(horizontal: 24),
              hintText: 'Min Delivery Charge within km'.tr(),
              hintStyle: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0Xff333333), fontSize: 17, fontFamily: "Poppinsm"),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
              ),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                // borderRadius: BorderRadius.circular(8.0),
              ),
            )),
      ),
      SizedBox(
        height: 10,
      ),
      // _mediaFiles.isEmpty == true ?
      // InkWell(onTap: (){
      //   _pickImage();
      // },
      //   child:
      //   Image(image: AssetImage("assets/images/add_img.png"),
      //   width:MediaQuery.of(context).size.width*1,
      //   height: MediaQuery.of(context).size.height*0.2 ,))
      //   :
      _mediaFiles.isEmpty == true
          ? InkWell(
              onTap: () {
                changeimg();
              },
              child: Image(
                image: NetworkImage(vendor.photo),
                width: 150,
              ))
          : _imageBuilder(_mediaFiles.first)
    ]);
  }

  changeimg() {
    final action = CupertinoActionSheet(
      message: Text(
        'Change Picture'.tr(),
        style: TextStyle(fontSize: 15.0),
      ),
      actions: [
        CupertinoActionSheetAction(
          child: Text('Choose image from gallery'.tr()),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              // _mediaFiles.removeLast();
              setState(() {
                _mediaFiles.add(File(image.path));
              });

              // _mediaFiles.add(null);

            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture'.tr()),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              // _mediaFiles.removeLast();
              _mediaFiles.add(File(image.path));
              // _mediaFiles.add(null);

            }
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'.tr()),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK".tr()),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Restaurant Field".tr()),
      content: Text("Please Select Image to Continue.".tr()),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  validate() async {
    if (MyAppState.currentUser!.vendorID != '') {
      if (_formKey.currentState?.validate() ?? false) {
        // catselect();
        filter();
        if (_mediaFiles.isNotEmpty) {
          await showProgress(context, 'Updating Photo...'.tr(), false);

          var uniqueID = Uuid().v4();
          Reference upload = FirebaseStorage.instance.ref().child('flutter/uberEats/productImages/$uniqueID'
              '.png');
          UploadTask uploadTask = upload.putFile(_mediaFiles.first);
          uploadTask.whenComplete(() {}).catchError((onError) {
            print((onError as PlatformException).message);
          });
          var storageRef = (await uploadTask.whenComplete(() {})).ref;
          downloadUrl = await storageRef.getDownloadURL();
          downloadUrl.toString();
          await hideProgress();
          DeliveryChargeModel deliveryChargeModel = DeliveryChargeModel(
              vendor_can_modify: true,
              delivery_charges_per_km: num.parse(deliverChargeKm.text),
              minimum_delivery_charges: num.parse(minDeliveryCharge.text),
              minimum_delivery_charges_within_km: num.parse(minDeliveryChargewkm.text));
          push(
            context,
            RestaurantLocationScreen(
                restname: restaurantName.text,
                catid: categoryId,
                filter: filters,
                cat: selectCategoryName,
                opentime: time1.text,
                closetime: time2.text,
                desc: description.text,
                phonenumber: phonenumber.text,
                pic: downloadUrl ?? img,
                vendor: vendors,
                deliveryChargeModel: deliveryChargeModel),
          );
        } else {
          DeliveryChargeModel deliveryChargeModel = DeliveryChargeModel(
              vendor_can_modify: true,
              delivery_charges_per_km: num.parse(deliverChargeKm.text),
              minimum_delivery_charges: num.parse(minDeliveryCharge.text),
              minimum_delivery_charges_within_km: num.parse(minDeliveryChargewkm.text));
          push(
            context,
            RestaurantLocationScreen(
                restname: restaurantName.text,
                catid: categoryId,
                filter: filters,
                cat: selectCategoryName,
                opentime: time1.text,
                closetime: time2.text,
                desc: description.text,
                phonenumber: phonenumber.text,
                pic: img,
                vendor: vendors,
                deliveryChargeModel: deliveryChargeModel),
          );
        }
        /* if(isTimeValid == false){
      */ /*    showimgAlertDialog(context, 'Please select valid time',
              'Please select valid close restaurant time', true);*/ /*
          showAlertDialog1(context);

        }*/

        print(isTimeValid.toString() + "====TINME");
      }
    } else if (_formKey.currentState?.validate() ?? false) {
      if (_mediaFiles.isEmpty) {
        showimgAlertDialog(context, 'Please add Image'.tr(), 'Add Image to continue'.tr(), true);
      } else if (phonenumber.text.isEmpty) {
        showimgAlertDialog(context, 'Please enter valid number'.tr(), 'Add phone no. to continue'.tr(), true);
      }
      /* else if(isTimeValid == false){
        */ /*showimgAlertDialog(context, 'Please select valid time',
            'Please select valid close restaurant time', true);*/ /*
        showAlertDialog1(context);

      }*/
      else {
        // catselect();
        filter();
        _formKey.currentState!.save();
        print(isTimeValid.toString() + "====TINME123");
        DeliveryChargeModel deliveryChargeModel = DeliveryChargeModel(
            vendor_can_modify: true,
            delivery_charges_per_km: num.parse(deliverChargeKm.text),
            minimum_delivery_charges: num.parse(minDeliveryCharge.text),
            minimum_delivery_charges_within_km: num.parse(minDeliveryChargewkm.text));
        push(
          context,
          RestaurantLocationScreen(
            restname: restaurantName.text,
            catid: selectedCategory!.id,
            filter: filters,
            cat: selectedCategory!.title.toString(),
            opentime: time1.text,
            closetime: time2.text,
            desc: description.text,
            phonenumber: phonenumber.text,
            pic: img ?? _mediaFiles.first,
            vendor: vendors,
            deliveryChargeModel: deliveryChargeModel,
          ),
        );
      }
    } else {
      setState(() {
        _autoValidateMode = AutovalidateMode.onUserInteraction;
      });
    }
  }

  _pickImage() {
    final action = CupertinoActionSheet(
      message: Text(
        'Add Picture'.tr(),
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('Choose image from gallery'.tr()),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              // _mediaFiles.removeLast();
              _mediaFiles.add(File(image.path));
              // _mediaFiles.add(null);
              setState(() {});
            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a picture'.tr()),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              // _mediaFiles.removeLast();
              _mediaFiles.add(File(image.path));
              // _mediaFiles.add(null);
              setState(() {});
            }
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'.tr()),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _imageBuilder(dynamic image) {
    // bool isLastItem = image == null;
    return GestureDetector(
      onTap: () {
        _viewOrDeleteImage(image);
      },
      child: Container(
        width: 100,
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          color: isDarkMode(context) ? Colors.black : Colors.white,
          child: ClipRRect(
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
            // _mediaFiles.removeLast();
            if (image is File) {
              _mediaFiles.removeWhere((value) => value is File && value.path == image.path);
            } else {
              _mediaFiles.removeWhere((value) => value is String && value == image);
            }
            // _mediaFiles.add(null);
            setState(() {});
          },
          child: Text('Remove picture'.tr()),
          isDestructiveAction: true,
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            push(context, image is File ? FullScreenImageViewer(imageFile: image) : FullScreenImageViewer(imageUrl: image));
          },
          isDefaultAction: true,
          child: Text('View picture'.tr()),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'.tr()),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  bool isPhoneNoValid(String? phoneNo) {
    if (phoneNo == null) return false;
    final regExp = RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)');
    return regExp.hasMatch(phoneNo);
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

  showAlertDialog1(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK".tr()),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("My title".tr()),
      content: Text("This is my message.".tr()),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
