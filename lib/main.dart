import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

import 'firebase_options.dart';
import 'services/ads_service.dart';
import 'services/notification_service.dart';
import 'models/user_model.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/user_provider.dart';
import 'providers/craftsmen_provider.dart';
import 'providers/store_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen_holder.dart';
import 'providers/profession_provider.dart';

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
        ChangeNotifierProvider(create: (_) => ProfessionProvider()),
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

    // تهيئة Upgrader بدون الخصائص الإضافية
    final upgrader = Upgrader(
      messages: UpgraderMessages(code: 'ar'),
    );

    // --- بداية الحل النهائي ---
    // إعادة الخصائص إلى ويدجت UpgradeAlert كما هو متوقع في الإصدار القديم
    return UpgradeAlert(
      upgrader: upgrader,
      dialogStyle: UpgradeDialogStyle.material,
      canDismissDialog: true,
      showIgnore: false,
      showLater: true,
      child: StreamBuilder<UserModel?>(
        stream: authProvider.userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasError) {
            print('AuthWrapper Error: ${snapshot.error}');
            return const Scaffold(body: Center(child: Text('حدث خطأ في المصادقة')));
          }

          final UserModel? user = snapshot.data;

          if (user == null) {
            Provider.of<UserProvider>(context, listen: false).clearUser();
            return const LoginScreen();
          }
          
          Provider.of<UserProvider>(context, listen: false).setUser(user);
          return const MainScreenHolder();
        },
      ),
    );
    // --- نهاية الحل النهائي ---
  }
}
