import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../providers/craftsmen_provider.dart';
import '../../data/cities_data.dart';
import '../../widgets/custom_button.dart';
import 'package:share_plus/share_plus.dart';
import 'settings_screen.dart';
import '../../widgets/banner_ad_widget.dart';

class AvailableCraftsmenScreen extends StatefulWidget {
  const AvailableCraftsmenScreen({super.key});

  @override
  State<AvailableCraftsmenScreen> createState() => _AvailableCraftsmenScreenState();
}

class _AvailableCraftsmenScreenState extends State<AvailableCraftsmenScreen> {
  String? _selectedProfession;
  String? _selectedCity;
  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // --- تصحيح: التأكد من أن الدالة لا تتطلب معاملات ---
      Provider.of<CraftsmenProvider>(context, listen: false).fetchCraftsmen();
    });
  }

  void _applyFilters() {
    // --- تصحيح: التأكد من أن الدالة تتلقى المعاملات الصحيحة ---
    Provider.of<CraftsmenProvider>(context, listen: false).filterCraftsmen(
      profession: _selectedProfession,
      city: _selectedCity,
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedProfession = null;
      _selectedCity = null;
      _selectedRegion = null;
    });
    Provider.of<CraftsmenProvider>(context, listen: false).fetchCraftsmen();
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontSize: 14)),
          value: value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Center(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final craftsmenProvider = Provider.of<CraftsmenProvider>(context);
    // --- تصحيح: التأكد من وجود الدالة ---
    final List<String> professions = CitiesData.professions;
    final List<String> regions = CitiesData.regions['المغرب']?.keys.toList() ?? [];
    final List<String> cities = (_selectedRegion != null && CitiesData.regions['المغرب']?[_selectedRegion] != null)
        ? CitiesData.regions['المغرب']![_selectedRegion]!
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.craftsmenLabel),
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Share.share('ابحث عن أفضل الحرفيين في تطبيق الصانع الحرفي! [رابط التطبيق]');
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
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _buildDropdown(
                        hint: 'اختر الحرفة',
                        value: _selectedProfession,
                        items: professions,
                        onChanged: (newValue) {
                          setState(() { _selectedProfession = newValue; });
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              hint: 'اختر الجهة',
                              value: _selectedRegion,
                              items: regions,
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedRegion = newValue;
                                  _selectedCity = null;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDropdown(
                              hint: 'اختر المدينة',
                              value: _selectedCity,
                              items: cities,
                              onChanged: (newValue) {
                                setState(() { _selectedCity = newValue; });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'بحث',
                              onPressed: _applyFilters,
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: AppColors.primaryColor),
                            onPressed: _resetFilters,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: craftsmenProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : craftsmenProvider.craftsmen.isEmpty
                          ? const Center(child: Text('لا يوجد حرفيون متاحون بهذه المواصفات.'))
                          : ListView.builder(
                              itemCount: craftsmenProvider.craftsmen.length,
                              itemBuilder: (context, index) {
                                UserModel craftsman = craftsmenProvider.craftsmen[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: craftsman.profileImageUrl.isNotEmpty
                                          ? NetworkImage(craftsman.profileImageUrl)
                                          : const AssetImage('assets/images/placeholder_icon.png') as ImageProvider,
                                    ),
                                    title: Text(craftsman.name),
                                    subtitle: Text('${craftsman.profession}\n${craftsman.subscribedCities.join(', ')}'),
                                    trailing: const Icon(Icons.arrow_forward_ios),
                                    onTap: () {
                                      // TODO: الانتقال إلى صفحة تفاصيل الحرفي
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          const BannerAdWidget(screenName: 'AvailableCraftsmenScreen'),
        ],
      ),
    );
  }
}
