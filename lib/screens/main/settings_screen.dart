// lib/screens/main/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (user != null) _buildUserTypeSwitcher(context, user),
            _buildThemeSwitcher(context),
            const Divider(),
            _buildInfoSection(context),
            const Divider(),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeSwitcher(BuildContext context, UserModel user) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Only show the switcher if the user is a craftsman or a supplier
    if (user.userType != AppStrings.craftsman && user.userType != AppStrings.supplier) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تبديل وضع الحساب',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك التبديل بين حسابك كـ"${AppStrings.client}" (لطلب الخدمات) وحسابك كـ"${user.userType}" (لعرض خدماتك).',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUserTypeOption(
                  context,
                  'أنا زبون',
                  AppStrings.client,
                  user.userType == AppStrings.client,
                  () => authProvider.updateUserType(AppStrings.client),
                ),
                _buildUserTypeOption(
                  context,
                  'أنا ${user.userType}',
                  user.userType,
                  user.userType != AppStrings.client,
                  () => authProvider.updateUserType(user.userType),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeOption(
      BuildContext context, String title, String type, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSwitcher(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          leading: const Icon(Icons.brightness_6),
          title: const Text('الوضع الداكن'),
          trailing: Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Column(
      children: [
        _buildInfoTile(
          context,
          icon: Icons.description_outlined,
          title: 'شروط الاستخدام',
          onTap: () => _launchURL('https://elhirafi.pro/terms'),
        ),
        _buildInfoTile(
          context,
          icon: Icons.privacy_tip_outlined,
          title: 'سياسة الخصوصية',
          onTap: () => _launchURL('https://elhirafi.pro/privacy'),
        ),
        _buildInfoTile(
          context,
          icon: Icons.info_outline,
          title: 'عن التطبيق',
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: AppStrings.appName,
              applicationVersion: '1.0.0', // Replace with dynamic version later
              applicationLegalese: '© 2024 Elhirafi.pro. All rights reserved.',
              children: [
                const SizedBox(height: 16),
                const Text('تطبيق لمساعدة المستخدمين في العثور على حرفيين وخدمات.'),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.share_outlined),
            label: const Text('مشاركة التطبيق'),
            onPressed: () {
              Share.share(
                'تحقق من تطبيق ${AppStrings.appName}! إنه رائع للعثور على حرفيين. \n\nhttps://play.google.com/store/apps/details?id=pro.elhirafi.app',
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.star_outline),
            label: const Text('تقييم التطبيق'),
            onPressed: () => _launchURL('https://play.google.com/store/apps/details?id=pro.elhirafi.app'),
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('تسجيل الخروج'),
            onPressed: () => _confirmSignOut(context),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Could not launch the URL
    }
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('تأكيد تسجيل الخروج'),
          content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                Provider.of<AuthProvider>(context, listen: false).signOut();
              },
            ),
          ],
        );
      },
    );
  }
}
