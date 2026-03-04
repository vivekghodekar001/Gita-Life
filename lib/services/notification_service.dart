import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: \${message.messageId}");
}

class NotificationService {
  void _ensureFirebase() {
    if (Firebase.apps.isEmpty) {
      throw Exception('[NotificationService] Firebase not initialized. Ensure Firebase.initializeApp() is called and verified before accessing this service.');
    }
  }

  FirebaseMessaging get _fcm {
    _ensureFirebase();
    return FirebaseMessaging.instance;
  }
  
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  FirebaseFirestore get _firestore {
    _ensureFirebase();
    return FirebaseFirestore.instanceFor(app: Firebase.app());
  }

  Future<void> initNotifications() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _localNotifications.initialize(settings: initializationSettings);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(message.notification!);
      }
    });

    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleInteraction(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleInteraction);
    
    await _fcm.subscribeToTopic('all_students');
  }

  Future<void> _showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'gitalife_high_importance_channel', 
      'Announcements', 
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  void _handleInteraction(RemoteMessage message) {
    print('User tapped notification: \${message.data}');
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  Future<void> saveTokenToDatabase(String userId) async {
    String? token = await getToken();
    if (token != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    }
  }

  Future<void> sendToAll(String title, String body, String adminId) async {
    await _firestore.collection('notifications').add({
      'title': title,
      'body': body,
      'sentBy': adminId,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending', 
    });
  }

  Stream<QuerySnapshot> getNotificationHistory() {
    return _firestore.collection('notifications').orderBy('createdAt', descending: true).snapshots();
  }
}
