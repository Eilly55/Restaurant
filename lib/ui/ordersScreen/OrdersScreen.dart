import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';
import 'package:uber_eats_restaurant_dashboard/constants.dart';
import 'package:uber_eats_restaurant_dashboard/main.dart';
import 'package:uber_eats_restaurant_dashboard/model/ConversationModel.dart';
import 'package:uber_eats_restaurant_dashboard/model/CurrencyModel.dart';
import 'package:uber_eats_restaurant_dashboard/model/HomeConversationModel.dart';
import 'package:uber_eats_restaurant_dashboard/model/OrderModel.dart';
import 'package:uber_eats_restaurant_dashboard/model/OrderProductModel.dart';
import 'package:uber_eats_restaurant_dashboard/services/FirebaseHelper.dart';
import 'package:uber_eats_restaurant_dashboard/services/helper.dart';
import 'package:uber_eats_restaurant_dashboard/services/pushnotification.dart';
import 'package:uber_eats_restaurant_dashboard/ui/chat/ChatScreen.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  late Stream<List<OrderModel>> ordersStream;

  late Future<List<CurrencyModel>> futureCurrency;

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Soundpool? _pool;
  SoundpoolOptions _soundpoolOptions = SoundpoolOptions();
  Soundpool pool = Soundpool.fromOptions(options: SoundpoolOptions.kDefault);

  final audioPlayer = AudioPlayer(playerId: "playerId");
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    ordersStream = _fireStoreUtils.watchOrdersStatus(MyAppState.currentUser!.vendorID);
    final pushNotificationService = PushNotificationService(_firebaseMessaging);
    pushNotificationService.initialise();
    futureCurrency = FireStoreUtils().getCurrency();
    getcurcy();
  }

  @override
  void dispose() {
    _fireStoreUtils.closeOrdersStream();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDarkMode(context) ? Color(DARK_VIEWBG_COLOR) : Color(0XFFFFFFFF),
        body: SingleChildScrollView(
            child: Column(children: [
          getcurcy(),
          StreamBuilder<List<OrderModel>>(
              stream: ordersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                print(snapshot.data!.length.toString() + "-----L");
                if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                  return Center(
                    child: showEmptyState('No Orders'.tr(), 'New order requests will show up here'.tr()),
                  );
                } else {
                  // for(int a=0;a<snapshot.data!.length;a++){
                  //   // print("====TOKEN===${a}===="+snapshot.data![a].author!.fcmToken);
                  // }
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                      itemBuilder: (context, index) =>
                          buildOrderItem(snapshot.data![index], index, (index != 0) ? snapshot.data![index - 1] : null));
                }
              }),
        ])));
  }

  getcurcy() {
    return Container(
        height: 0,
        child: FutureBuilder<List<CurrencyModel>>(
            future: futureCurrency,
            initialData: [],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                return Center(
                  child: showEmptyState('No Orders'.tr(), 'New order requests will show up here'.tr()),
                );
              } else {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return curcy(snapshot.data![index]);
                    });
              }
            }));
  }

  curcy(CurrencyModel currency) {
    if (currency.isactive == true) {
      symbol = currency.symbol;
      isRight = currency.symbolatright;
      decimal = currency.decimal;

      return Center();
    }
    return Center();
  }

  Widget buildOrderItem(OrderModel orderModel, int index, OrderModel? prevModel) {
    double total = 0.0;
    total = 0.0;
    String extrasDisVal = '';
    orderModel.orderProduct.forEach((element) {
      if (orderModel.status == ORDER_STATUS_PLACED) {
        playSound();
      }

      try {
        if (element.extras_price! != null && element.extras_price!.isNotEmpty && double.parse(element.extras_price!) != 0.0) {
          total += element.quantity * double.parse(element.extras_price!);
        }
        total += element.quantity * double.parse(element.price);
        List addOnVal = [];
        if (element.extras == null) {
          addOnVal.clear();
        } else {
          if (element.extras is String) {
            if (element.extras == '[]') {
              addOnVal.clear();
            } else {
              String extraDecode = element.extras.toString().replaceAll("[", "").replaceAll("]", "").replaceAll("\"", "");
              if (extraDecode.contains(",")) {
                addOnVal = extraDecode.split(",");
              } else {
                if (extraDecode.trim().isNotEmpty) {
                  addOnVal = [extraDecode];
                }
              }
            }
          }
          if (element.extras is List) {
            addOnVal = List.from(element.extras);
          }
        }
        for (int i = 0; i < addOnVal.length; i++) {
          extrasDisVal += '${addOnVal[index].toString().replaceAll("\"", "")} ${(index == addOnVal.length - 1) ? "" : ","}';
        }
      } catch (ex) {}
    });
    // log("extra add on ${(orderModel.author!.firstName + ' ' + orderModel.author!.lastName)}  id is ${orderModel.id}");
    // if(orderModel.deliveryCharge!=null && orderModel.deliveryCharge!.isNotEmpty){
    //   total+=double.parse(orderModel.deliveryCharge!);
    // }
    String date = DateFormat(' MMM d yyyy').format(DateTime.fromMillisecondsSinceEpoch(orderModel.createdAt.millisecondsSinceEpoch));
    String date2 = "";
    if (prevModel != null) {
      date2 = DateFormat(' MMM d yyyy').format(DateTime.fromMillisecondsSinceEpoch(prevModel.createdAt.millisecondsSinceEpoch));
    }
    print("cond1 ${(index == 0)} cond 2 ${(index != 0 && prevModel != null && date != date2)}");
    return Column(children: [
      Visibility(
        visible: index == 0 || (index != 0 && prevModel != null && date != date2),
        child: Wrap(children: [
          Container(
            height: 50.0,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : Colors.grey.shade300,
            ),
            alignment: Alignment.center,
            child: Text(
              '${date}',
              style: TextStyle(
                  fontSize: 16, color: isDarkMode(context) ? Colors.white : Colors.black, letterSpacing: 0.5, fontFamily: 'Poppinsm'),
            ),
          )
        ]),
      ),
      Card(
        elevation: 3,
        margin: EdgeInsets.only(bottom: 10, top: 10),
        color: isDarkMode(context) ? Color(DARK_CARD_BG_COLOR) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // if you need this
          side: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.only(bottom: 10.0, top: 5),
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Row(children: [
                    Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(orderModel.orderProduct.first.photo),
                            fit: BoxFit.cover,
                            // colorFilter: ColorFilter.mode(
                            //     Colors.black.withOpacity(0.5), BlendMode.darken),
                          ),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        orderModel.author!.firstName + ' ' + orderModel.author!.lastName,
                        style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode(context) ? Colors.white : Color(0XFF000000),
                            letterSpacing: 0.5,
                            fontFamily: 'Poppinsm'),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      orderModel.takeAway!
                          ? Text(
                              'Takeaway'.tr(),
                              style: TextStyle(
                                  fontSize: 15,
                                  color: isDarkMode(context) ? Colors.white : Color(0XFF555353),
                                  letterSpacing: 0.5,
                                  fontFamily: 'Poppinsl'),
                            )
                          : Row(children: [
                              Icon(Icons.location_pin, size: 17, color: Colors.grey),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                'Deliver to:'.tr(),
                                style: TextStyle(
                                    fontSize: 15,
                                    color: isDarkMode(context) ? Colors.white : Color(0XFF555353),
                                    letterSpacing: 0.5,
                                    fontFamily: 'Poppinsl'),
                              ),
                            ]),
                      orderModel.takeAway!
                          ? Container()
                          : Container(
                              padding: EdgeInsets.only(bottom: 8),
                              constraints: BoxConstraints(maxWidth: 200),
                              child: Text(
                                '${orderModel.deliveryAddress()}',
                                maxLines: 1,
                                style: TextStyle(
                                    color: isDarkMode(context) ? Colors.white : Color(0XFF555353),
                                    fontSize: 15,
                                    letterSpacing: 0.5,
                                    fontFamily: 'Poppinsr'),
                              ),
                            ),
                    ])
                  ])),
              // SizedBox(height: 10,),
              Divider(
                color: Color(0XFFD7DDE7),
              ),
              Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.centerLeft,
                child: Text(
                  'ORDER LIST'.tr(),
                  style: TextStyle(fontSize: 14, color: Color(0XFF9091A4), letterSpacing: 0.5, fontFamily: 'Poppinsm'),
                ),
              ),

              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: orderModel.orderProduct.length,
                  padding: EdgeInsets.only(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    OrderProductModel product = orderModel.orderProduct[index];
                    return Column(
                      children: [
                        ListTile(
                          minLeadingWidth: 10,
                          contentPadding: EdgeInsets.only(left: 10, right: 10),
                          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                          leading: CircleAvatar(
                            radius: 13,
                            backgroundColor: Color(COLOR_PRIMARY),
                            child: Text(
                              '${product.quantity}',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: TextStyle(
                                color: isDarkMode(context) ? Colors.white : Color(0XFF333333),
                                fontSize: 18,
                                letterSpacing: 0.5,
                                fontFamily: 'Poppinsr'),
                          ),
                          trailing: Text(
                            symbol != ''
                                ? symbol +
                                    double.parse((product.extras_price! != null &&
                                                product.extras_price!.isNotEmpty &&
                                                double.parse(product.extras_price!) != 0.0)
                                            ? (double.parse(product.extras_price!) + double.parse(product.price)).toString()
                                            : product.price)
                                        .toStringAsFixed(decimal)
                                : '$symbol${double.parse((product.extras_price! != null && product.extras_price!.isNotEmpty && double.parse(product.extras_price!) != 0.0) ? (double.parse(product.extras_price!) + double.parse(product.price)).toString() : product.price).toStringAsFixed(2)}',
                            style: TextStyle(
                                color: isDarkMode(context) ? Colors.grey.shade200 : Color(0XFF333333),
                                fontSize: 17,
                                letterSpacing: 0.5,
                                fontFamily: 'Poppinsr'),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 55, right: 10),
                          child: Row(children: [
                            product.size == ""
                                ? Container()
                                : Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      product.size!.toString().trim() + ",",
                                      style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Poppinsr'),
                                    ),
                                  ),
                            extrasDisVal.isEmpty
                                ? Container()
                                : Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      extrasDisVal,
                                      style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Poppinsr'),
                                    ),
                                  )
                          ]),
                        )
                      ],
                    );
                  }),
              SizedBox(
                height: 10,
              ),
              Container(
                  padding: EdgeInsets.only(bottom: 8, top: 8, left: 10, right: 10),
                  color: isDarkMode(context) ? null : Color(0XFFF4F4F5),
                  alignment: Alignment.centerLeft,
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(
                      'Order Total'.tr(),
                      style: TextStyle(
                          fontSize: 15,
                          color: isDarkMode(context) ? Colors.white : Color(0XFF333333),
                          letterSpacing: 0.5,
                          fontFamily: 'Poppinsr'),
                    ),
                    Text(
                      symbol != '' ? symbol + total.toDouble().toStringAsFixed(decimal) : '$symbol${total.toDouble().toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, color: Color(COLOR_PRIMARY), letterSpacing: 0.5, fontFamily: 'Poppinssm'),
                    ),
                  ])),
              orderModel.notes!.isEmpty
                  ? Container()
                  : SizedBox(
                      height: 10,
                    ),
              orderModel.notes!.isEmpty
                  ? Container()
                  : Container(
                      padding: EdgeInsets.only(bottom: 8, top: 8, left: 10, right: 10),
                      color: isDarkMode(context) ? null : Colors.white,
                      alignment: Alignment.centerLeft,
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(
                          'Remark'.tr(),
                          style: TextStyle(
                              fontSize: 15,
                              color: isDarkMode(context) ? Colors.white : Color(0XFF333333),
                              letterSpacing: 0.5,
                              fontFamily: 'Poppinsr'),
                        ),

                        // ElevatedButton(
                        //     onPressed: (){
                        //       final url = "https://soundcloud.com/scutoidmusic/darren-styles-dougal-gammer-party-dont-stop-scutoids-sus-edit?utm_source=clipboard&utm_medium=text&utm_campaign=social_sharing";
                        //       if(!isPlaying){
                        //         audioPlayer.play(UrlSource(url),
                        //             mode: PlayerMode.mediaPlayer, );
                        //       }else{
                        //         audioPlayer.stop();
                        //       }
                        //     },
                        //     child: Text("pay done !!")
                        // ),

                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                isDismissible: true,
                                context: context,
                                backgroundColor: Colors.transparent,
                                enableDrag: true,
                                builder: (BuildContext context) => viewNotesheet(orderModel.notes!));
                          },
                          child: Text(
                            "View".tr(),
                            style: TextStyle(fontSize: 18, color: Color(COLOR_PRIMARY), letterSpacing: 0.5, fontFamily: 'Poppinsm'),
                          ),
                        ),
                      ])),
              Container(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Expanded(
                      //   child: Center(
                      //     child: Padding(
                      //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      //       child: Text(
                      //         'Total: \$${total.toStringAsFixed(2)}',
                      //         style: TextStyle(
                      //             color: isDarkMode(context)
                      //                 ? Colors.grey.shade200
                      //                 : Colors.grey.shade700,
                      //             fontWeight: FontWeight.w700),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      if (orderModel.status == ORDER_STATUS_PLACED)

                        // int soundId = await rootBundle.load("sounds/dices.m4a").then((ByteData soundData) {
                        // return pool.load(soundData);
                        // });
                        // int streamId = await pool.play(soundId);

                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              padding: EdgeInsets.all(8),
                              side: BorderSide(color: Color(COLOR_PRIMARY), width: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                              primary: isDarkMode(context) ? Colors.black45 : Colors.white,
                            ),
                            onPressed: () {
                              audioPlayer.stop();
                              orderModel.status = ORDER_STATUS_ACCEPTED;
                              FireStoreUtils.updateOrder(orderModel);
                              FireStoreUtils.sendFcmMessage("Your Order has Accepted".tr(),
                                  '${orderModel.vendor.title}' + "AcceptedOrder".tr(), orderModel.author!.fcmToken);

                              if (orderModel.status == ORDER_STATUS_PLACED && !orderModel.takeAway!) {
                                FireStoreUtils.sendFcmMessage(
                                    "New Delivery!".tr(), 'New Delivery Request'.tr(), orderModel.driver!.fcmToken);
                              }
                            },
                            child: Text(
                              'ACCEPT'.tr(),
                              style: TextStyle(letterSpacing: 0.5, color: Color(COLOR_PRIMARY), fontFamily: 'Poppinsm'),
                            ),
                          ),
                        ),
                      SizedBox(
                        width: 20,
                      ),

                      // ElevatedButton(
                      //     onPressed: () async {
                      //
                      //       //push(context, SoundpoolInitializer());
                      //       final path = await rootBundle.load("assets/audio/ringing_old_phone.mp3");
                      //          // "assets/audio/ringing_old_phone.mp3";
                      //       final url = "http://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Sevish_-__nbsp_.mp3";
                      //       audioPlayer.setSourceBytes(path.buffer.asUint8List());
                      //       //audioPlayer.setSourceUrl(url);
                      //       audioPlayer.play(BytesSource(path.buffer.asUint8List()));
                      //       //audioPlayer.play(AssetSource(path),);
                      //       print(audioPlayer.playerId);
                      //       //audioPlayer.play(UrlSource(url),volume: 10);
                      //       print(audioPlayer.playerId);
                      //       // if(!isPlaying){
                      //       //   audioPlayer.play(UrlSource(url),);
                      //       // }else{
                      //       //   audioPlayer.pause();
                      //       // }
                      //     },
                      //     child: Text("pay done !!")
                      // ),

                      // if (orderModel.status == ORDER_STATUS_PLACED)
                      //   playSound(),

                      if (orderModel.status == ORDER_STATUS_PLACED)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              padding: EdgeInsets.all(8),
                              side: BorderSide(color: Color(0XFF63605F), width: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(2),
                                ),
                              ),
                              primary: isDarkMode(context) ? Colors.black45 : Colors.white,
                            ),
                            onPressed: () {
                              audioPlayer.stop();
                              orderModel.status = ORDER_STATUS_REJECTED;
                              FireStoreUtils.updateOrder(orderModel);
                              //orderModel.status = ORDER_STATUS_REJECTED;
                              FireStoreUtils.updateOrder(orderModel);
                              FireStoreUtils.sendFcmMessage("Your Order has Rejected".tr(),
                                  '${orderModel.vendor.title}' + ' has Reject Your Order'.tr(), orderModel.author!.fcmToken);

                              if (orderModel.paymentMethod!.toLowerCase() != 'cod') {
                                FireStoreUtils.createPaymentId().then((value) {
                                  final paymentID = value;
                                  FireStoreUtils.topUpWalletAmount(
                                          paymentMethod: "Refund Amount".tr(),
                                          userId: orderModel.author!.userID,
                                          amount: total.toDouble(),
                                          id: paymentID)
                                      .then((value) {
                                    FireStoreUtils.updateWalletAmount(userId: orderModel.author!.userID, amount: total.toDouble())
                                        .then((value) {});
                                  });
                                });
                              }

                              if (orderModel.status == ORDER_STATUS_REJECTED && !orderModel.takeAway!) {
                                FireStoreUtils.sendFcmMessage(
                                    "Reject Order!".tr(), 'Reject Order Request'.tr(), orderModel.driver!.fcmToken);
                              }
                            },
                            child: Text(
                              'REJECT'.tr(),
                              style: TextStyle(
                                  letterSpacing: 0.5,
                                  color: isDarkMode(context) ? Color(0XFF9c9fa0) : Color(0XFF63605F),
                                  fontFamily: 'Poppinsm'),
                            ),
                          ),
                        ),
                      if (orderModel.status != ORDER_STATUS_PLACED && !orderModel.takeAway!)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(6),
                                ),
                              ),
                              side: BorderSide(
                                color: Color(COLOR_PRIMARY),
                              ),
                            ),
                            onPressed: () => null,
                            child: Text(
                              '${orderModel.status}'.tr(),
                              style: TextStyle(
                                color: Color(COLOR_PRIMARY),
                              ),
                            ),
                          ),
                        ),

                      orderModel.status == ORDER_STATUS_ACCEPTED && orderModel.takeAway!
                          ? Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  orderModel.status = ORDER_STATUS_COMPLETED;
                                  FireStoreUtils.updateOrder(orderModel);
                                  updateWallateAmount(orderModel);
                                  FireStoreUtils.sendFcmMessage("Your Order has been Completed".tr(),
                                      '${orderModel.vendor.title}' + ' has Complete Your Order'.tr(), orderModel.author!.fcmToken);
                                },
                                child: Container(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    // height: 50,
                                    padding: EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
                                    // primary: Colors.white,

                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(width: 0.8, color: Color(COLOR_PRIMARY))),
                                    child: Text(
                                      'Delivered'.tr().toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color(COLOR_PRIMARY), fontFamily: "Poppinsm", fontSize: 15
                                          // fontWeight: FontWeight.bold,
                                          ),
                                    )),
                              ),
                            )
                          : orderModel.status == ORDER_STATUS_COMPLETED && orderModel.takeAway!
                              ? Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(6),
                                        ),
                                      ),
                                      side: BorderSide(
                                        color: Color(COLOR_PRIMARY),
                                      ),
                                    ),
                                    onPressed: () => null,
                                    child: Text(
                                      '${orderModel.status}'.tr(),
                                      style: TextStyle(
                                        color: Color(COLOR_PRIMARY),
                                      ),
                                    ),
                                  ),
                                )
                              : orderModel.status == ORDER_STATUS_REJECTED && orderModel.takeAway!
                                  ? Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(6),
                                            ),
                                          ),
                                          side: BorderSide(
                                            color: Color(COLOR_PRIMARY),
                                          ),
                                        ),
                                        onPressed: () => null,
                                        child: Text(
                                          '${orderModel.status}'.tr(),
                                          style: TextStyle(
                                            color: Color(COLOR_PRIMARY),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),

                      Visibility(
                          visible: orderModel.status == ORDER_STATUS_ACCEPTED ||
                              orderModel.status == ORDER_STATUS_SHIPPED ||
                              orderModel.status == ORDER_STATUS_DRIVER_PENDING ||
                              orderModel.status == ORDER_STATUS_DRIVER_REJECTED ||
                              orderModel.status == ORDER_STATUS_IN_TRANSIT ||
                              orderModel.status == ORDER_STATUS_SHIPPED,
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: InkWell(
                              onTap: () async {
                                String channelID;
                                if (MyAppState.currentUser!.userID.compareTo(orderModel.author!.userID) < 0) {
                                  channelID = MyAppState.currentUser!.userID + orderModel.author!.userID;
                                } else {
                                  channelID = orderModel.author!.userID + MyAppState.currentUser!.userID;
                                }

                                ConversationModel? conversationModel = await _fireStoreUtils.getChannelByIdOrNull(channelID);
                                push(
                                    context,
                                    ChatScreen(
                                      homeConversationModel:
                                          HomeConversationModel(members: [orderModel.author!], conversationModel: conversationModel),
                                    ));
                              },
                              child: Image(
                                image: AssetImage("assets/images/user_chat.png"),
                                height: 30,
                                color: Color(COLOR_PRIMARY),
                                width: 30,
                              ),
                            ),
                          ))
                    ],
                  )),
            ],
          ),
        ),
      )
    ]);
  }

  viewNotesheet(String notes) {
    return Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 4.3, left: 25, right: 25),
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(color: Colors.transparent, border: Border.all(style: BorderStyle.none)),
        child: Column(children: [
          InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 45,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.white, width: 0.3), color: Colors.transparent, shape: BoxShape.circle),

                // radius: 20,
                child: Center(
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              )),
          SizedBox(
            height: 25,
          ),
          Expanded(
              child: Container(
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(10), color: isDarkMode(context) ? Color(COLOR_DARK) : Colors.white),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Remark'.tr(),
                        style: TextStyle(fontFamily: 'Poppinssb', color: isDarkMode(context) ? Colors.white60 : Colors.white, fontSize: 16),
                      )),
                  Container(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                      // height: 120,
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          child: Container(
                              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                              color: isDarkMode(context) ? Color(0XFF2A2A2A) : Color(0XFFF1F4F7),
                              // height: 120,
                              alignment: Alignment.center,
                              child: Text(
                                notes,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDarkMode(context) ? Colors.white60 : Colors.black,
                                  fontFamily: 'Poppinsm',
                                ),
                              )))),
                ],
              ),
            ),
          )),
        ]));
  }

  buildDetails({required IconData iconsData, required String title, required String value}) {
    return ListTile(
      enabled: false,
      dense: true,
      contentPadding: EdgeInsets.only(left: 8),
      horizontalTitleGap: 0.0,
      visualDensity: VisualDensity.comfortable,
      leading: Icon(
        iconsData,
        color: isDarkMode(context) ? Colors.white : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: isDarkMode(context) ? Colors.white : Colors.black87),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black54),
      ),
    );
  }

  playSound() async {
    final path = await rootBundle.load("assets/audio/mixkit-happy-bells-notification-937.mp3");

    audioPlayer.setSourceBytes(path.buffer.asUint8List());
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    //audioPlayer.setSourceUrl(url);
    audioPlayer.play(BytesSource(path.buffer.asUint8List()),
        volume: 15,
        ctx: AudioContext(
            android: AudioContextAndroid(
                contentType: AndroidContentType.music,
                isSpeakerphoneOn: true,
                stayAwake: true,
                usageType: AndroidUsageType.alarm,
                audioFocus: AndroidAudioFocus.gainTransient),
            iOS: AudioContextIOS(defaultToSpeaker: true, category: AVAudioSessionCategory.playback, options: [])));
  }
}
