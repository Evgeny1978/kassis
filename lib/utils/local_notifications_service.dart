import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kassis/utils/local_notifications.dart';



class LocalNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _started = false;

  LocalNotificationService._internal();

  static final LocalNotificationService instance = LocalNotificationService._internal();

  // ********************************************************* //
  // YOU HAVE TO CALL THIS FROM SOMEWHERE (May be main widget)
  // ********************************************************* //
  void start() {
    if (!_started) {
      _start();
      _started = true;
      _refreshToken();
    }
  }

  void _refreshToken() {
    _firebaseMessaging.getToken().then(_tokenRefresh, onError: _tokenRefreshFailure);
  }

  void _start() {
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.onTokenRefresh.listen(_tokenRefresh, onError: _tokenRefreshFailure);
    _firebaseMessaging.configure(
      onMessage: _onMessage,
      onLaunch: _onLaunch,
      onResume: _onResume,
    );
  }

  void _tokenRefresh(String newToken) async {
    print(" New FCM Token $newToken");
  }

  void _tokenRefreshFailure(error) {
    print("FCM token refresh failed with error $error");
  }

  Future<void> _onMessage(Map<String, dynamic> message) async {
    print("onMessage $message");
    if (message['notification'] != null) {
      final notification = LocalNotification("notification", message['notification'] as Map);
      NotificationsBloc.instance.newNotification(notification);
      return null;
    }
    if (message['data'] != null) {
      final notification = LocalNotification("data", message['data'] as Map);
      NotificationsBloc.instance.newNotification(notification);
      return null;
    }
  }

  Future<void> _onLaunch(Map<String, dynamic> message) {
    print("onLaunch $message");
    return null;
  }

  Future<void> _onResume(Map<String, dynamic> message) {
    print("onResume $message");
    return null;
  }
}