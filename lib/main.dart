import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// --- بداية التعديل 1: استيراد خدمة الإعلانات ---
import 'services/ad_service.dart';
// --- نهاية التعديل 1 ---

import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/craftsmen_provider.dart';
import 'providers/request_provider.dart';
import 'providers/store_provider.dart';
import 'providers/chat_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen_holder.dart';
import 'constants/app_colors.dart';

// --- بداية التعديل 2: تحويل الدالة إلى async واستدعاء التهيئة ---
void main() async {
  // التأكد من أن Flutter جاهز قبل استدعاء أي خدمات
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // تهيئة خدمة الإعلانات (AdMob)
  await AdService.initialize();

  runApp(const MyApp());
}
// --- نهاية التعديل 2 ---

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CraftsmenProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'الصانع الحرفي',
            theme: ThemeData(
              primaryColor: AppColors.primaryColor,
              scaffoldBackgroundColor: AppColors.backgroundColor,
              fontFamily: 'Cairo',
              brightness: Brightness.light,
              cardColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            darkTheme: ThemeData(
              primaryColor: AppColors.primaryColor,
              scaffoldBackgroundColor: const Color(0xFF121212),
              fontFamily: 'Cairo',
              brightness: Brightness.dark,
              cardColor: const Color(0xFF1E1E1E),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
            // تحديد اتجاه النص من اليمين لليسار
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
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

    // التحقق من حالة المصادقة
    if (authProvider.user != null) {
      return const MainScreenHolder();
    } else {
      return const LoginScreen();
    }
  }
}
