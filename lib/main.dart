// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import 'firebase_options.dart';
import 'services/ads_service.dart';
import 'services/notification_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/user_provider.dart';
import 'providers/craftsmen_provider.dart';
import 'providers/store_provider.dart';
import 'providers/theme_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen_holder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();
  await AdsService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CraftsmenProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'الصانع الحرفي',
            theme: themeProvider.getTheme(),
            home: AuthWrapper(),
            debugShowCheckedModeBanner: false,
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

    // --- بداية التعديل: تحديث Upgrader ---
    // الإصدار الجديد من Upgrader يستخدم تهيئة مباشرة.
    // الخصائص القديمة مثل dialogStyle و showLater تم تغييرها أو إزالتها.
    // هذا هو الإعداد الأساسي الذي يعمل.
    final upgrader = Upgrader(
      dialogStyle: UpgradeDialogStyle.material, // أو .cupertino
      canDismissDialog: true,
      showLater: true,
      showIgnore: false,
    );
    // --- نهاية التعديل ---

    return UpgradeAlert(
      upgrader: upgrader,
      child: StreamBuilder<UserModel?>(
        stream: authProvider.userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final UserModel? user = snapshot.data;
            if (user == null) {
              return const LoginScreen();
            }
            // تحديث بيانات المستخدم في UserProvider عند تسجيل الدخول
            Provider.of<UserProvider>(context, listen: false).setUser(user);
            return const MainScreenHolder();
          }
          // أثناء انتظار بيانات المصادقة، أظهر شاشة تحميل
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}
