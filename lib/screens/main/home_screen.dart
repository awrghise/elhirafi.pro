import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alsana_alharfiyin/models/user_model.dart';
import 'package:alsana_alharfiyin/providers/auth_provider.dart';
import 'package:alsana_alharfiyin/constants/app_colors.dart';
import 'package:alsana_alharfiyin/constants/app_strings.dart';
import 'package:alsana_alharfiyin/widgets/banner_ad_widget.dart';
import 'package:alsana_alharfiyin/services/store_service.dart';
import 'package:alsana_alharfiyin/models/product_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:alsana_alharfiyin/screens/supplier/public_store_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('مرحباً ${user.name}'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                'تطبيق الصانع الحرفي - منصة ربط الحرفيين بأصحاب المشاريع\nhttps://play.google.com/store/apps/details?id=com.elsane3.app',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildDashboard(context, user),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, UserModel user) {
    switch (user.userType) {
      case AppStrings.client:
        return const _ClientDashboard();
      case AppStrings.craftsman:
        return _CraftsmanDashboard(user: user);
      case AppStrings.supplier:
        return _SupplierDashboard(user: user);
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'نوع المستخدم غير معروف: ${user.userType}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).signOut();
                },
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
        );
    }
  }
}

class _ClientDashboard extends StatelessWidget {
  const _ClientDashboard();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build_circle, size: 100, color: AppColors.primaryColor),
            const SizedBox(height: 24),
            const Text('لوحة تحكم العميل', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('ابحث عن الحرفيين المتاحين أو أنشئ طلب جديد', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigator.pushNamed(context, '/create_request');
              },
              icon: const Icon(Icons.add),
              label: const Text('إنشاء طلب جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CraftsmanDashboard extends StatelessWidget {
  final UserModel user;
  const _CraftsmanDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
