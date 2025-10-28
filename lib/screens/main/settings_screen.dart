// lib/screens/main/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';

// --- بداية التعديل 1: استيراد ملف بيانات المدن ---
import '../../data/data_cities.dart'; // تأكد من أن هذا المسار صحيح

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  void _showCitySelectionDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    // --- بداية التعديل 2: جعل قائمة المدن ديناميكية ---
    // إذا لم نجد المستخدم أو دولته، نعرض قائمة فارغة كإجراء احترازي
    if (user == null || user.country.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن تحديد دولة المستخدم لعرض المدن.'))
      );
      return;
    }
    // جلب المدن الخاصة بدولة المستخدم فقط من الخريطة
    final List<String> citiesForUserCountry = citiesByCountry[user.country] ?? [];
    // --- نهاية التعديل 2 ---

    List<String> tempSelectedCities = List<String>.from(user.subscribedCities ?? []);
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredCities = citiesForUserCountry // <-- استخدام القائمة المفلترة هنا
                .where((city) => city.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return AlertDialog(
              title: Text('اختر مدن التنبيهات في ${user.country}'), // <-- عنوان ديناميكي
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: TextField(
                        onChanged: (value) {
                          setDialogState(() { searchQuery = value; });
                        },
                        decoration: const InputDecoration(
                          labelText: 'بحث عن مدينة...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredCities.length,
                        itemBuilder: (context, index) {
                          final city = filteredCities[index];
                          final isSelected = tempSelectedCities.contains(city);
                          return CheckboxListTile(
                            title: Text(city),
                            value: isSelected,
                            onChanged: (bool? selected) {
                              setDialogState(() {
                                if (selected == true) {
                                  tempSelectedCities.add(city);
                                } else {
                                  tempSelectedCities.remove(city);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(AppStrings.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _saveSubscribedCities(tempSelectedCities);
                  },
                  child: const Text(AppStrings.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveSubscribedCities(List<String> newCities) async {
    setState(() { _isLoading = true; });
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .updateUserSubscribedCities(newCities);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ تفضيلات المدن بنجاح!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... بقية الكود لم يتغير ...
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الحساب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text(AppStrings.myProfile),
                    onTap: () { /* ... */ },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text(AppStrings.logout),
                    onTap: () async {
                      await authProvider.signOut();
                    },
                  ),
                  const SizedBox(height: 24),

                  if (user?.userType == AppStrings.craftsman) ...[
                    const Text('تنبيهات الطلبات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.location_city),
                      title: const Text('مدن التنبيهات'),
                      subtitle: Text(
                        (user?.subscribedCities != null && user.subscribedCities!.isNotEmpty)
                            ? user.subscribedCities!.join(', ')
                            : 'لم تختر أي مدن بعد',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: _showCitySelectionDialog,
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Text('المظهر', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppStrings.primaryColor)),
                  const Divider(),
                  SwitchListTile(
                    title: const Text(AppStrings.darkMode),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                    secondary: const Icon(Icons.dark_mode_outlined),
                  ),
                  const SizedBox(height: 24),

                  const Text('حول التطبيق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppStrings.primaryColor)),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.policy_outlined),
                    title: const Text(AppStrings.privacyPolicy),
                    onTap: () { /* ... */ },
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text(AppStrings.termsOfService),
                    onTap: () { /* ... */ },
                  ),
                ],
              ),
            ),
    );
  }
}
