import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../auth/register_screen.dart';
import 'settings_screen.dart';

// --- بداية التعديل 1: استيراد ويدجت إعلان البانر ---
import '../../widgets/banner_ad_widget.dart';
// --- نهاية التعديل 1 ---

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileLabel),
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Share.share('انضم إلى مجتمع الحرفيين والعملاء في تطبيق الصانع الحرفي! [رابط التطبيق]');
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
      ),
      // --- بداية التعديل 2: تغيير هيكل body لإضافة البانر ---
      body: Column(
        children: [
          Expanded(
            child: user == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: user.profileImageUrl.isNotEmpty
                              ? NetworkImage(user.profileImageUrl)
                              : const AssetImage('assets/images/placeholder_icon.png') as ImageProvider,
                        ),
                        const SizedBox(height: 16),
                        Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(user.email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('نوع الحساب: ${user.userType}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 24),
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('تعديل الملف الشخصي'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen(isEditing: true)),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                          onTap: () async {
                            await authProvider.signOut();
                            // The AuthWrapper in main.dart will handle navigation to LoginScreen
                          },
                        ),
                      ],
                    ),
                  ),
          ),
          // العنصر الثاني: إعلان البانر الخاص بهذه الشاشة
          const BannerAdWidget(screenName: 'ProfileScreen'),
        ],
      ),
      // --- نهاية التعديل 2 ---
    );
  }
}
