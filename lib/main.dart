// 1. Directives (Imports) must come first
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/request_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/main/settings_screen.dart';
import 'screens/supplier/store_management_screen.dart';
import 'screens/content/privacy_policy_screen.dart';
import 'screens/content/terms_of_service_screen.dart';
import 'screens/content/about_us_screen.dart';
import 'screens/content/contact_us_screen.dart';
import 'services/ads_service.dart';

// 2. The main function
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Ads and preload interstitial
  await AdsService.initialize();
  
  runApp(const MyApp());
}

// 3. The root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MultiProvider to provide all providers to the app
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        // Add other providers here in the future
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: AppColors.primaryMaterialColor,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Cairo', // You can change the font
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          buttonTheme: const ButtonThemeData(
            buttonColor: AppColors.primaryColor,
            textTheme: ButtonTextTheme.primary,
          ),
        ),
        home: const AuthWrapper(), // The starting point is the Wrapper
        routes: {
          '/settings': (context) => const SettingsScreen(),
          '/store_management': (context) => const StoreManagementScreen(),
          '/privacy_policy': (context) => const PrivacyPolicyScreen(),
          '/terms_of_service': (context) => const TermsOfServiceScreen(),
          '/about_us': (context) => const AboutUsScreen(),
          '/contact_us': (context) => const ContactUsScreen(),
        }
      ),
    );
  }
}

// 4. The AuthWrapper widget to handle routing
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to AuthProvider
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check authentication state
        if (authProvider.isAuthenticated && authProvider.user != null) {
          // If the user is logged in, go to the main screen
          return const MainScreen();
        } else {
          // If not logged in, go to the login screen
          return const LoginScreen();
        }
      },
    );
  }
}
