// First, create a service class to handle Firebase Messaging

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseNotificationService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final RxBool notificationsEnabled = true.obs;
  final String _prefsKey = 'notifications_enabled';

  Future<FirebaseNotificationService> init() async {
    // Load saved preference
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getBool(_prefsKey);

    if (savedValue != null) {
      notificationsEnabled.value = savedValue;
    }

    if (notificationsEnabled.value) {
      await enableNotifications();
    }

    return this;
  }

  Future<void> enableNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    await FirebaseMessaging.instance.subscribeToTopic("Common");
    await FirebaseMessaging.instance.subscribeToTopic("Asset");
    await FirebaseMessaging.instance.subscribeToTopic("Land");
    await FirebaseMessaging.instance.subscribeToTopic("Vehicle");
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    print('FCM Token: $fCMToken');

    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }

  Future<void> disableNotifications() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic("Common");
    await FirebaseMessaging.instance.unsubscribeFromTopic("Asset");
    await FirebaseMessaging.instance.unsubscribeFromTopic("Land");
    await FirebaseMessaging.instance.unsubscribeFromTopic("Vehicle");
    print('Notifications disabled');

    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, false);
  }

  Future<void> toggleNotifications(bool value) async {
    if (value) {
      await enableNotifications();
    } else {
      await disableNotifications();
    }
    notificationsEnabled.value = value;
  }
}

// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  print('Body: ${message.notification?.body}');
  print('Title: ${message.notification?.title}');
  print('Payload: ${message.data}');
}

// Modify your main.dart to initialize the service:
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize services
  await Get.putAsync(() => FirebaseNotificationService().init());
  // ... other initializations
  
  runApp(MyApp());
}
*/