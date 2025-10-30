import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import 'settings_screen.dart'; // استيراد شاشة الإعدادات

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? user = authProvider.user;

    // --- بداية التعديل: إضافة أيقونات القائمة والمشاركة في الشريط العلوي ---
    final appBarActions = [
      // أيقونة المشاركة
      IconButton(
        icon: const Icon(Icons.share_outlined),
        onPressed: () {
          // يمكنك تخصيص الرسالة هنا
          Share.share('تطبيق الصانع الحرفي - الحل الأمثل لإيجاد الحرفيين وخدماتهم. حمله الآن! [رابط التطبيق]');
        },
      ),
      // أيقونة القائمة (بدلاً من الإعدادات)
      IconButton(
        icon: const Icon(Icons.menu), // تغيير الأيقونة إلى menu
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
      ),
    ];
    // --- نهاية التعديل ---

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        backgroundColor: AppColors.primaryColor,
        actions: appBarActions, // استخدام الأيقونات المجهزة
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : _buildUserDashboard(context, user),
    );
  }

  Widget _buildUserDashboard(BuildContext context, UserModel user) {
    // بناء لوحة التحكم بناءً على نوع المستخدم
    switch (user.userType) {
      case AppStrings.client:
        return _buildClientDashboard(context, user);
      case AppStrings.craftsman:
        return _buildCraftsmanDashboard(context, user);
      case AppStrings.supplier:
        return _buildSupplierDashboard(context, user);
      default:
        return Center(child: Text('مرحباً ${user.name}'));
    }
  }

  // لوحة تحكم العميل
  Widget _buildClientDashboard(BuildContext context, UserModel user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('مرحباً بك يا عميل، ${user.name}!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('استعرض الحرفيين المتاحين أو ابحث عن منتجات في المتجر.'),
        ],
      ),
    );
  }

  // لوحة تحكم الحرفي
  Widget _buildCraftsmanDashboard(BuildContext context, UserModel user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('مرحباً بك يا حرفي، ${user.name}!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('تفقد طلبات العمل الجديدة وقم بإدارة ملفك الشخصي.'),
        ],
      ),
    );
  }

  // لوحة تحكم المورد
  Widget _buildSupplierDashboard(BuildContext context, UserModel user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('مرحباً بك يا مورد، ${user.name}!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('قم بإدارة متجرك ومنتجاتك من خلال قسم المتجر.'),
        ],
      ),
    );
  }
}
