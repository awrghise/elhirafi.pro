import 'package:alsana_alharfiyin/firebase_options.dart';
import 'package:alsana_alharfiyin/models/user_model.dart';
import 'package:alsana_alharfiyin/providers/auth_provider.dart';
import 'package:alsana_alharfiyin/providers/chat_provider.dart';
import 'package:alsana_alharfiyin/providers/craftsmen_provider.dart';
import 'package:alsana_alharfiyin/providers/profession_provider.dart';
import 'package:alsana_alharfiyin/providers/request_provider.dart';
import 'package:alsana_alharfiyin/providers/store_provider.dart';
import 'package:alsana_alharfiyin/providers/theme_provider.dart';
import 'package:alsana_alharfiyin/providers/user_provider.dart';
import 'package:alsana_alharfiyin/screens/auth/login_screen.dart';
import 'package:alsana_alharfiyin/screens/main/main_screen_holder.dart';
import 'package:alsana_alharfiyin/services/analytics_service.dart'; // <-- تم إعادة تفعيله
import 'package:alsana_alharfiyin/services/notification_service.dart'; // <-- تم إعادة تفعيله
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init(); // <-- تم تعديل اسم الدالة
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProfessionProvider()),
        ChangeNotifierProvider(create: (_) => CraftsmenProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'الصناع الحرفيين',
            theme: themeProvider.getTheme(),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', ''), // Arabic
            ],
            locale: const Locale('ar', ''),
            navigatorObservers: [AnalyticsService.getAnalyticsObserver()], // <-- تم إعادة تفعيله
            home: UpgradeAlert( // <-- تم حذف const
              child: const AuthWrapper(),
            ),
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

    return StreamBuilder<UserModel?>(
      stream: authProvider.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final UserModel? user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          }
          return const MainScreenHolder();
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
