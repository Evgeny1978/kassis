

import 'dart:io';
import 'package:kassis/utils/firebase_tools.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {

  final FirebaseMessaging _fcm;

  FirebaseApplicationTools firebaseApplicationTools = new FirebaseApplicationTools();

  PushNotificationService(this._fcm);

  Future initialise() async {
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    // If you want to test the push notification locally,
    // you need to get the token and input to the Firebase console
    // https://console.firebase.google.com/project/YOUR_PROJECT_ID/notification/compose
    try {
      String token = await _fcm.getToken();
      if (token != null) {
        firebaseApplicationTools.uploadToken(token);
      }
      print("FirebaseMessaging token: $token");

      _fcm.configure(
        onMessage: (Map<String, dynamic> message) async {
          firebaseApplicationTools.getNotifications();
          print("onMessage: $message");

        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
        },
      );
    } catch (e) {
      String s = "";
    }

  }
}