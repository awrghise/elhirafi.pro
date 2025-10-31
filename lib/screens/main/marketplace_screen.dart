import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'settings_screen.dart'; // افترضت وجوده في main/settings_screen.dart
import '../../widgets/banner_ad_widget.dart';

// --- استيراد الشاشات التي ستكون داخل التبويبات ---
import 'all_products_screen.dart'; // سنقوم بإنشاء هذا الملف في الخطوة التالية
import 'stores_tab_screen.dart';   // سنقوم بإنشاء هذا الملف في الخطوة التالية

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام DefaultTabController لتنسيق عمل التبويبات
    return DefaultTabController(
      length: 2, // عدد التبويبات: المنتجات، المتاجر
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.storeLabel), // يمكن تغييره إلى "السوق"
          backgroundColor: AppColors.primaryColor,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {
                Share.share('تصفح أفضل المنتجات والمتاجر في تطبيق الصانع الحرفي! [رابط التطبيق]');
              },
            ),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
          // --- هذا هو الجزء الخاص بالتبويبات ---
          bottom: const TabBar(
            tabs: [
              Tab(text: 'المنتجات'),
              Tab(text: 'المتاجر'),
            ],
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 14),
          ),
        ),
        body: Column(
          children: [
            // --- هذا الجزء يعرض محتوى التبويب المحدد ---
            const Expanded(
              child: TabBarView(
                children: [
                  // المحتوى الأول: شاشة كل المنتجات
                  AllProductsScreen(),

                  // المحتوى الثاني: شاشة المتاجر
                  StoresTabScreen(),
                ],
              ),
            ),
            // --- إعلان البانر الثابت في أسفل شاشة السوق ---
            const BannerAdWidget(screenName: 'MarketplaceScreen'),
          ],
        ),
      ),
    );
  }
}
