import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut(); // <-- تم التصحيح
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 24),
            const Divider(),
            _buildProfileInfoCard(user),
            const SizedBox(height: 16),
            if (user.userType == AppStrings.craftsman) ...[
              _buildCraftsmanInfoCard(user),
              const SizedBox(height: 16),
            ],
            // Add other sections like settings, etc.
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: user.profileImageUrl.isNotEmpty
              ? NetworkImage(user.profileImageUrl)
              : null,
          child: user.profileImageUrl.isEmpty
              ? const Icon(Icons.person, size: 50)
              : null,
        ),
        const SizedBox(height: 12),
        Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(user.email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfileInfoCard(UserModel user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppStrings.clientInfo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            _buildInfoRow(Icons.phone, AppStrings.phone, user.phoneNumber),
            _buildInfoRow(Icons.account_circle, AppStrings.accountType, user.userType),
          ],
        ),
      ),
    );
  }

  Widget _buildCraftsmanInfoCard(UserModel user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppStrings.myProfession, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            _buildInfoRow(Icons.work, AppStrings.profession, user.professionName ?? AppStrings.notSpecified),
            const SizedBox(height: 12),
            const Text(AppStrings.myWorkCities, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            if (user.workCities.isNotEmpty) // <-- تم التصحيح
              Wrap(
                spacing: 8.0,
                children: user.workCities.map((city) => Chip(label: Text(city))).toList(),
              )
            else
              const Text(AppStrings.notSpecified),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor),
          const SizedBox(width: 16),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
