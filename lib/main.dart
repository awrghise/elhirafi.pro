import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import 'firebase_options.dart';
import 'services/ads_service.dart';
import 'services/notification_service.dart';
import 'models/user_model.dart';

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
  await AdsService.initialize();
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
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
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

    // تهيئة Upgrader
    final upgrader = Upgrader(
      messages: UpgraderMessages(code: 'ar'),
      // --- بداية التعديل: نقل الخصائص إلى هنا ---
      dialogStyle: UpgradeDialogStyle.material,
      canDismissDialog: true,
      showIgnore: false,
      showLater: true,
    );

    return UpgradeAlert(
      upgrader: upgrader,
      child: StreamBuilder<UserModel?>(
        // --- بداية التعديل: استخدام اسم الـ Stream الصحيح من AuthProvider ---
        stream: authProvider.userStream,
        // --- نهاية التعديل ---
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final UserModel? user = snapshot.data;
            if (user == null) {
              Provider.of<UserProvider>(context, listen: false).clearUser();
              return const LoginScreen();
            }
            
            Provider.of<UserProvider>(context, listen: false).setUser(user);
            return const MainScreenHolder();
          }

          // عرض شاشة تحميل أثناء انتظار حالة المصادقة الأولية
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }
}
