import 'package:firebase_messaging/firebase_messaging.dart';


Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  print('Body: ${message.notification?.body}');
  print('Title: ${message.notification?.title}');
  print('Payload: ${message.data}');
}
class FirebaseApi{
  final firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications()async{
    await firebaseMessaging.requestPermission();
    final fCMToken = await firebaseMessaging.getToken();
    await FirebaseMessaging.instance.subscribeToTopic("Common");
    await FirebaseMessaging.instance.subscribeToTopic("Asset");
    await FirebaseMessaging.instance.subscribeToTopic("Land");
    await FirebaseMessaging.instance.subscribeToTopic("Vehicle");
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    print('FCM Token: $fCMToken');

  }

}

