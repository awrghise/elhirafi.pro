import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../data/cities_data.dart';
import '../auth/register_screen.dart';
import '../content/privacy_policy_screen.dart';
import '../content/terms_of_service_screen.dart';
import '../content/about_us_screen.dart';
import '../content/contact_us_screen.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  void _showCitySelectionDialog(UserModel user) {
    if (user.country.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن تحديد دولة المستخدم لعرض المدن.'))
      );
      return;
    }
    
    final List<String> citiesForUserCountry = CitiesData.getRegions(user.country)
        .expand((region) => CitiesData.getCities(user.country, region))
        .toSet()
        .toList()
      ..sort();
    
    List<String> tempSelectedCities = List<String>.from(user.subscribedCities);
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredCities = citiesForUserCountry
                .where((city) => city.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return AlertDialog(
              title: Text('اختر مدن التنبيهات في ${user.country}'),
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
                    await _saveSubscribedCities(user, tempSelectedCities);
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

  Future<void> _saveSubscribedCities(UserModel user, List<String> newCities) async {
    setState(() { _isLoading = true; });
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .updateUserProfileWithImage(userId: user.id, data: {'subscribedCities': newCities});
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.settings),
            backgroundColor: AppColors.primaryColor,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : user == null
                  ? const Center(child: Text('خطأ: لا يمكن تحميل بيانات المستخدم.'))
                  : _buildSettingsList(context, themeProvider, authProvider, user),
        );
      },
    );
  }

  Widget _buildSettingsList(BuildContext context, ThemeProvider themeProvider, AuthProvider authProvider, UserModel user) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        _buildSectionTitle('الحساب'),
        _buildSettingsTile(
          icon: Icons.person_outline,
          title: 'تعديل الملف الشخصي',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen(isEditing: true, userToEdit: user)));
          },
        ),
        if (user.userType == AppStrings.craftsman)
          _buildSettingsTile(
            icon: Icons.location_city_outlined,
            title: 'مدن التنبيهات',
            subtitle: user.subscribedCities.isNotEmpty ? user.subscribedCities.join(', ') : 'لم تختر مدن بعد',
            onTap: () => _showCitySelectionDialog(user),
          ),
        
        _buildSectionTitle('التطبيق'),
        SwitchListTile(
          title: const Text(AppStrings.darkMode),
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            themeProvider.toggleTheme(value);
          },
          secondary: const Icon(Icons.dark_mode_outlined),
        ),
        // --- بداية التعديل: إضافة مفتاح التحكم بالخلفية ---
        SwitchListTile(
          title: const Text('إظهار الخلفية المزخرفة'),
          value: themeProvider.showBackgroundPattern,
          onChanged: (value) {
            themeProvider.toggleBackgroundPattern(value);
          },
          secondary: const Icon(Icons.pattern_outlined),
        ),
        // --- نهاية التعديل ---
        _buildSettingsTile(
          icon: Icons.share_outlined,
          title: 'مشاركة التطبيق',
          onTap: () {
            Share.share('تطبيق الصانع الحرفي - الحل الأمثل لإيجاد الحرفيين. حمله الآن! [رابط التطبيق]');
          },
        ),
        _buildSettingsTile(
          icon: Icons.star_border,
          title: 'تقييم التطبيق',
          onTap: () { /* TODO: إضافة رابط المتجر */ },
        ),

        _buildSectionTitle('حول'),
        _buildSettingsTile(
          icon: Icons.info_outline,
          title: AppStrings.aboutUs,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen()));
          },
        ),
        _buildSettingsTile(
          icon: Icons.contact_support_outlined,
          title: AppStrings.contactUs,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen()));
          },
        ),
        _buildSettingsTile(
          icon: Icons.policy_outlined,
          title: AppStrings.privacyPolicy,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
          },
        ),
        _buildSettingsTile(
          icon: Icons.description_outlined,
          title: AppStrings.termsOfService,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
          onTap: () async {
            await authProvider.signOut();
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
