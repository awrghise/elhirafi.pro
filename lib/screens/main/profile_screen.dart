// lib/screens/main/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../auth/register_screen.dart';
import '../../models/user_model.dart'; // Import UserModel

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('لم يتم تحميل بيانات المستخدم')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RegisterScreen(isEditing: true, userToEdit: user),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: user.profileImageUrl.isNotEmpty
                    ? NetworkImage(user.profileImageUrl)
                    : null,
                child: user.profileImageUrl.isEmpty
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 48, color: Colors.white),
                      )
                    : null,
                backgroundColor: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(user.email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            const Divider(),
            _buildInfoTile(Icons.phone, 'رقم الهاتف', user.phoneNumber),
            _buildInfoTile(Icons.person_outline, 'نوع الحساب', user.userType),
            if (user.userType == AppStrings.craftsman) ...[
              _buildInfoTile(Icons.work, 'المهنة', user.professionName ?? 'غير محدد'),
              // --- بداية التعديل ---
              _buildInfoTile(Icons.location_city, 'مدينة العمل الأساسية', user.primaryWorkCity ?? 'غير محدد'),
              // --- نهاية التعديل ---
              _buildInfoTile(Icons.notifications_active, 'مدن التنبيهات', user.alertCities.join(', ')),
            ],
            const Divider(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    if (subtitle.isEmpty) return const SizedBox.shrink();
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16)),
    );
  }
}
