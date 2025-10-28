// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import 'firebase_options.dart';
import 'services/ads_service.dart';

// --- بداية الإصلاح 1: إضافة الاستيرادات الصحيحة ---
import 'services/notification_service.dart';
import 'models/user_model.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/user_provider.dart';       // ملف جديد
import 'providers/craftsmen_provider.dart';  // ملف جديد
import 'providers/store_provider.dart';
import 'providers/theme_provider.dart';
// --- نهاية الإصلاح 1 ---

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen_holder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // --- بداية الإصلاح 2: تهيئة الخدمات بالطريقة الصحيحة ---
  await NotificationService().init();
  await AdsService.instance.initialize();
  // --- نهاية الإصلاح 2 ---
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- بداية الإصلاح 3: تسجيل الـ Providers الجدد ---
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),      // <-- إضافة مهمة
        ChangeNotifierProvider(create: (_) => CraftsmenProvider()), // <-- إضافة مهمة
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        // --- نهاية الإصلاح 3 ---
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'الصانع الحرفي',
            theme: themeProvider.getTheme(),
            home: const AuthWrapper(), // استخدام const هنا آمن
            debugShowCheckedModeBanner: false,
            // تحديد اللغة العربية كلغة أساسية للتطبيق
            locale: const Locale('ar'),
            supportedLocales: const [
              Locale('ar'),
            ],
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // --- بداية الإصلاح 4: تهيئة Upgrader بالطريقة الصحيحة للإصدار الجديد ---
    final upgrader = Upgrader(
      dialogStyle: UpgradeDialogStyle.material,
      canDismissDialog: true,
      showIgnore: false,
      showLater: true,
    );
    // --- نهاية الإصلاح 4 ---

    return UpgradeAlert(
      upgrader: upgrader,
      child: StreamBuilder<UserModel?>(
        // --- بداية الإصلاح 5: استخدام authProvider.userStream الصحيح ---
        stream: authProvider.userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasError) {
            return const Scaffold(body: Center(child: Text('حدث خطأ ما')));
          }

          final UserModel? user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          }
          
          // --- بداية الإصلاح 6: تحديث بيانات المستخدم في UserProvider ---
          // هذا السطر مهم جدًا لربط بيانات المستخدم ببقية التطبيق
          Provider.of<UserProvider>(context, listen: false).setUser(user);
          // --- نهاية الإصلاح 6 ---

          return const MainScreenHolder();
        },
        // --- نهاية الإصلاح 5 ---
      ),
    );
  }
}
