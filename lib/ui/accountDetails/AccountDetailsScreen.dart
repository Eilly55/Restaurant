import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uber_eats_restaurant_dashboard/constants.dart';
import 'package:uber_eats_restaurant_dashboard/main.dart';
import 'package:uber_eats_restaurant_dashboard/model/User.dart';
import 'package:uber_eats_restaurant_dashboard/model/VendorModel.dart';
import 'package:uber_eats_restaurant_dashboard/services/FirebaseHelper.dart';
import 'package:uber_eats_restaurant_dashboard/services/helper.dart';
import 'package:uber_eats_restaurant_dashboard/ui/fullScreenImageViewer/FullScreenImageViewer.dart';
import 'package:uber_eats_restaurant_dashboard/ui/reauthScreen/reauth_user_screen.dart';

class AccountDetailsScreen extends StatefulWidget {
  // final User user;
  final VendorModel vendor;

  AccountDetailsScreen({Key? key, /*required this.user,*/ required this.vendor}) : super(key: key);

  @override
  _AccountDetailsScreenState createState() {
    return _AccountDetailsScreenState();
  }
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  User? user;
  late VendorModel vendor;
  GlobalKey<FormState> _key = new GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  String? firstName, lastName, email, mobile;
  List<dynamic> _mediaFiles = [];
  final ImagePicker _imagePicker = ImagePicker();
  FireStoreUtils fireStoreUtils = FireStoreUtils();
  bool? isLoader = false;

  @override
  void initState() {
    super.initState();
    vendor = widget.vendor;
    if (vendor.photos.isNotEmpty == true) {
      _mediaFiles.addAll(widget.vendor.photos);
    }

    FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID).then((value) {
      setState(() {
        user = value!;
        MyAppState.currentUser = value;
        _mediaFiles.addAll(user!.photos);
        isLoader = true;
      });
    }).whenComplete(() {
      _mediaFiles.add(null);
    });
    //user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Colors.white,
        appBar: AppBar(
          title: Text(
            'Account Details'.tr(),
            style: TextStyle(
              color: isDarkMode(context) ? Color(0xFFFFFFFF) : Color(0Xff333333),
            ),
          ),
          automaticallyImplyLeading: false,
          leading: GestureDetector(
              onTap: () {
                Navigator.pop(context, true);
              },
              child: Icon(Icons.arrow_back)),
        ),
        body: Builder(
            builder: (buildContext) => !isLoader!
                ? Center(
                    child: CircularProgressIndicator(color: Color(COLOR_PRIMARY)),
                  )
                : SingleChildScrollView(
                    child: Form(
                      key: _key,
                      autovalidateMode: _validate,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 8, top: 24),
                          child: Text(
                            'PUBLIC INFO',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ).tr(),
                        ),
                        Material(
                            elevation: 2,
                            color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                            child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: ListTile.divideTiles(context: buildContext, tiles: [
                                  ListTile(
                                    title: Text(
                                      'First Name',
                                      style: TextStyle(
                                        color: isDarkMode(context) ? Colors.white : Colors.black,
                                      ),
                                    ).tr(),
                                    trailing: ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 100),
                                      child: TextFormField(
                                        onSaved: (String? val) {
                                          firstName = val;
                                        },
                                        validator: validateName,
                                        textInputAction: TextInputAction.next,
                                        textAlign: TextAlign.end,
                                        initialValue: user! == null ? "" : user!.firstName,
                                        style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                                        cursorColor: Color(COLOR_ACCENT),
                                        textCapitalization: TextCapitalization.words,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'First Name'.tr(),
                                            contentPadding: EdgeInsets.symmetric(vertical: 5)),
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      'Last Name',
                                      style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                                    ).tr(),
                                    trailing: ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 100),
                                      child: TextFormField(
                                        onSaved: (String? val) {
                                          lastName = val;
                                        },
                                        validator: validateName,
                                        textInputAction: TextInputAction.next,
                                        textAlign: TextAlign.end,
                                        initialValue: user! == null ? "" : user!.lastName,
                                        style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                                        cursorColor: Color(COLOR_ACCENT),
                                        textCapitalization: TextCapitalization.words,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Last Name'.tr(),
                                            contentPadding: EdgeInsets.symmetric(vertical: 5)),
                                      ),
                                    ),
                                  ),
                                ]).toList())),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 8, top: 24),
                          child: Text(
                            'PRIVATE DETAILS',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ).tr(),
                        ),
                        Material(
                          elevation: 2,
                          color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                          child: ListView(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              children: ListTile.divideTiles(
                                context: buildContext,
                                tiles: [
                                  ListTile(
                                    title: Text(
                                      'Email Address',
                                      style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                                    ).tr(),
                                    trailing: ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 200),
                                      child: TextFormField(
                                        onSaved: (String? val) {
                                          email = val;
                                        },
                                        validator: validateEmail,
                                        textInputAction: TextInputAction.next,
                                        initialValue: user! == null ? "" : user!.email,
                                        textAlign: TextAlign.end,
                                        enabled: user!.email.isEmpty ? true : false,
                                        style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                                        cursorColor: Color(COLOR_ACCENT),
                                        keyboardType: TextInputType.emailAddress,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Email Address'.tr(),
                                            contentPadding: EdgeInsets.symmetric(vertical: 5)),
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      'Phone Number',
                                      style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black),
                                    ).tr(),
                                    trailing: ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 150),
                                      child: TextFormField(
                                        onSaved: (String? val) {
                                          mobile = val;
                                        },
                                        validator: validateMobile,
                                        textInputAction: TextInputAction.done,
                                        initialValue: user! == null ? "" : user!.phoneNumber,
                                        textAlign: TextAlign.end,
                                        style: TextStyle(fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
                                        cursorColor: Color(COLOR_ACCENT),
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Phone Number'.tr(),
                                            contentPadding: EdgeInsets.only(bottom: 2)),
                                      ),
                                    ),
                                  ),
                                ],
                              ).toList()),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 8, top: 24),
                          child: Text(
                            'ADD RESTAURANT PHOTOS',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ).tr(),
                        ),
                        ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: double.infinity),
                            child: Material(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16, top: 8, right: 8, bottom: 20),
                                  child: SizedBox(
                                    height: 100,
                                    child: ListView.builder(
                                      itemCount: _mediaFiles.length,
                                      itemBuilder: (context, index) => _imageBuilder(_mediaFiles[index]),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                    ),
                                  ),
                                ))),
                        Padding(
                            padding: const EdgeInsets.only(top: 32.0, bottom: 16),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: double.infinity),
                              child: Material(
                                elevation: 2,
                                color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.white,
                                child: CupertinoButton(
                                  padding: const EdgeInsets.all(12.0),
                                  onPressed: () async {
                                    _validateAndSave(buildContext);
                                  },
                                  child: Text(
                                    'Save',
                                    style: TextStyle(fontSize: 18, color: Color(COLOR_PRIMARY)),
                                  ).tr(),
                                ),
                              ),
                            )),
                      ]),
                    ),
                  )));
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
                  ? Color(DARK_CARD_BG_COLOR)
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

  _validateAndSave(BuildContext buildContext) async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState?.save();
      if (user!.email != email) {
        bool emailLogin = false;
        List<auth.UserInfo> userInfoList = auth.FirebaseAuth.instance.currentUser?.providerData ?? [];
        await Future.forEach(userInfoList, (auth.UserInfo info) {
          if (info.providerId == 'password') {
            emailLogin = true;
          }
        });
        if (emailLogin) {
          TextEditingController _passwordController = new TextEditingController();
          showDialog(
            context: context,
            builder: (context) => Dialog(
              elevation: 16,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "changeToEmailEnterPassword",
                      style: TextStyle(color: Colors.red, fontSize: 17),
                      textAlign: TextAlign.start,
                    ).tr(),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(hintText: 'Password'.tr()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(COLOR_ACCENT),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          if (_passwordController.text.isEmpty) {
                            showAlertDialog(context, 'Empty Password'.tr(), 'Password is required to update email'.tr(), true);
                          } else {
                            Navigator.pop(context);
                            showProgress(context, 'Verifying...'.tr(), false);
                            auth.UserCredential? result = await FireStoreUtils.reAuthUser(AuthProviders.PASSWORD,
                                email: user!.email, password: _passwordController.text);
                            if (result == null) {
                              hideProgress();
                              showAlertDialog(context, "notVerify".tr(), 'Please double check the password and try again.'.tr(), true);
                            } else {
                              _passwordController.dispose();
                              if (result.user != null) {
                                await result.user?.updateEmail(email!);
                                updateProgress('Saving details...'.tr());
                                await _updateUser(buildContext);
                                hideProgress();
                              } else {
                                hideProgress();
                                ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
                                    content: Text(
                                  "notVerifyTryAgain".tr(),
                                  style: TextStyle(fontSize: 17),
                                )));
                              }
                            }
                          }
                        },
                        child: Text(
                          'Verify',
                          style: TextStyle(color: isDarkMode(context) ? Colors.black : Colors.white),
                        ).tr(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          showProgress(context, 'Saving details...'.tr(), false);
          await _updateUser(buildContext);
          hideProgress();
        }
      } else {
        showProgress(context, 'Saving details...'.tr(), false);
        await _updateUser(buildContext);
        hideProgress();
      }
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  _updateUser(BuildContext buildContext) async {
    List<String> mediaFilesURLs = _mediaFiles.where((element) => element is String).toList().cast<String>();
    List<File> imagesToUpload = _mediaFiles.where((element) => element is File).toList().cast<File>();
    if (imagesToUpload.isNotEmpty) {
      updateProgress(
        'Uploading Restaurant Images {} of {}'.tr(args: ['1', '${imagesToUpload.length}']),
      );
      for (int i = 0; i < imagesToUpload.length; i++) {
        if (i != 0)
          updateProgress(
            'Uploading Restaurant Images {} of {}'.tr(
              args: ['${i + 1}', '${imagesToUpload.length}'],
            ),
          );
        String url = await fireStoreUtils.uploadProductImage(
          imagesToUpload[i],
          'Uploading Restaurant Images {} of {}'.tr(
            args: ['${i + 1}', '${imagesToUpload.length}'],
          ),
        );
        mediaFilesURLs.add(url);
      }
    }
    vendor.photos = mediaFilesURLs;
    user!.firstName = firstName!;
    user!.lastName = lastName!;
    user!.email = email!;
    user!.phoneNumber = mobile!;
    var updatedUser = await FireStoreUtils.updateCurrentUser(user!);
    var updatedVendor = await FireStoreUtils.updateVendor(vendor);
    if (updatedUser != null || updatedVendor != null) {
      MyAppState.currentUser = user;
      ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
          content: Text(
        'Details saved successfully',
        style: TextStyle(fontSize: 17),
      ).tr()));
    } else {
      ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
          content: Text(
        "notSaveDetailsTryAgain",
        style: TextStyle(fontSize: 17),
      ).tr()));
    }
  }
}
