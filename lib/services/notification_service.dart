// lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // طلب صلاحية استقبال الإشعارات
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // جلب التوكن الخاص بالجهاز
    final fcmToken = await getToken();
    if (kDebugMode) {
      print('FCM Token: $fcmToken');
    }
    // يمكنك هنا حفظ التوكن في قاعدة البيانات مرتبطًا بالمستخدم إذا احتجت

    // التعامل مع الإشعارات الواردة والتطبيق في المقدمة
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        if (kDebugMode) {
          print('Message also contained a notification: ${message.notification}');
        }
        // هنا يمكنك إظهار إشعار محلي إذا أردت
      }
    });
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
