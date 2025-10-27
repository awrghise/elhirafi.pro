// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';

import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/request_provider.dart';
import 'providers/store_provider.dart';
import 'providers/theme_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen_holder.dart';

// Unused import, as pointed out by the analyzer
// import 'services/ads_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MobileAds.instance.initialize();
  await FirebaseMessaging.instance.requestPermission();

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
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        // ChatProvider depends on AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, auth, chat) {
            if (chat == null) return ChatProvider();
            if (auth.user != null) {
              chat.setCurrentUserId(auth.user!.id);
            }
            return chat;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppStrings.appName,
            theme: themeProvider.getTheme(),
            debugShowCheckedModeBanner: false,
            home: UpgradeAlert(
              upgrader: Upgrader(
                dialogStyle: UpgradeDialogStyle.material,
                canDismissDialog: false,
                showLater: false,
                showIgnore: false,
              ),
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
    // --- بداية التعديل ---
    // We use the user object from the provider to determine auth state.
    // The provider listens to authStateChanges internally.
    final authProvider = Provider.of<AuthProvider>(context);

    // Show a loading indicator while the auth state is being determined.
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If the user object is not null, the user is authenticated.
    if (authProvider.user != null) {
      return const MainScreenHolder();
    } else {
      // Otherwise, show the login screen.
      return const LoginScreen();
    }
    // --- نهاية التعديل ---
  }
}
