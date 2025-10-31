import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../../models/store_model.dart';
import '../../widgets/custom_button.dart';
import '../main/settings_screen.dart';

// --- بداية التعديل 1: استيراد ويدجت إعلان البانر ---
import '../../widgets/banner_ad_widget.dart';
// --- نهاية التعديل 1 ---

class StoreManagementScreen extends StatefulWidget {
  const StoreManagementScreen({super.key});

  @override
  State<StoreManagementScreen> createState() => _StoreManagementScreenState();
}

class _StoreManagementScreenState extends State<StoreManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  String _storeName = '';
  String _storeSpecialization = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<StoreProvider>(context, listen: false).fetchStore(user.uid);
      }
    });
  }

  void _saveStore() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        final store = StoreModel(
          id: user.uid, // Using user ID as store ID
          name: _storeName,
          specialization: _storeSpecialization,
          ownerId: user.uid,
          imageUrl: Provider.of<StoreProvider>(context, listen: false).store?.imageUrl ?? '',
        );
        Provider.of<StoreProvider>(context, listen: false).createOrUpdateStore(store);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final store = storeProvider.store;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.manageStoreLabel),
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Share.share('إدارة متجرك بسهولة مع تطبيق الصانع الحرفي! [رابط التطبيق]');
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
            child: storeProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            initialValue: store?.name,
                            decoration: const InputDecoration(labelText: 'اسم المتجر'),
                            validator: (value) => value!.isEmpty ? 'الرجاء إدخال اسم المتجر' : null,
                            onSaved: (value) => _storeName = value!,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: store?.specialization,
                            decoration: const InputDecoration(labelText: 'تخصص المتجر'),
                            validator: (value) => value!.isEmpty ? 'الرجاء إدخال تخصص المتجر' : null,
                            onSaved: (value) => _storeSpecialization = value!,
                          ),
                          const SizedBox(height: 32),
                          CustomButton(
                            text: 'حفظ التغييرات',
                            onPressed: _saveStore,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          // العنصر الثاني: إعلان البانر الخاص بهذه الشاشة
          const BannerAdWidget(screenName: 'StoreManagementScreen'),
        ],
      ),
      // --- نهاية التعديل 2 ---
    );
  }
}
