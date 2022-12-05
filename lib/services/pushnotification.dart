import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm;

  PushNotificationService(this._fcm);

  Future initialise() async {
    // If you want to test the push notification locally,
    // you need to get the token and input to the Firebase console
    // https://console.firebase.google.com/project/YOUR_PROJECT_ID/notification/compose
    // String? token = await _fcm.getToken();
    // print("FirebaseMessaging token: $token");
    final NotificationSettings settings = await _fcm.requestPermission();

    //_fcm.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      try {
        final data = message.data;
        print(message.notification);
        print(message.notification!.title);
      } catch (e) {
        print(e);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      try {
        print('onResume: $message');
        final data = message.data;
        print(message.notification);
      } catch (e) {
        print(e);
      }
    });
  }
}
