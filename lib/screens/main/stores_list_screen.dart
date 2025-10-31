import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/store_provider.dart';
import '../../models/store_model.dart';
import 'settings_screen.dart';

// --- بداية التعديل 1: استيراد ويدجت إعلان البانر ---
import '../../widgets/banner_ad_widget.dart';
// --- نهاية التعديل 1 ---

class StoresListScreen extends StatefulWidget {
  const StoresListScreen({super.key});

  @override
  State<StoresListScreen> createState() => _StoresListScreenState();
}

class _StoresListScreenState extends State<StoresListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoreProvider>(context, listen: false).fetchAllStores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.storeLabel),
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Share.share('تصفح أفضل المتاجر في تطبيق الصانع الحرفي! [رابط التطبيق]');
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
                : storeProvider.allStores.isEmpty
                    ? const Center(child: Text('لا توجد متاجر متاحة حاليًا.'))
                    : ListView.builder(
                        itemCount: storeProvider.allStores.length,
                        itemBuilder: (context, index) {
                          final StoreModel store = storeProvider.allStores[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: store.imageUrl.isNotEmpty
                                    ? NetworkImage(store.imageUrl)
                                    : const AssetImage('assets/images/placeholder_icon.png') as ImageProvider,
                              ),
                              title: Text(store.name),
                              subtitle: Text(store.specialization),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                // TODO: الانتقال إلى صفحة تفاصيل المتجر
                              },
                            ),
                          );
                        },
                      ),
          ),
          // العنصر الثاني: إعلان البانر الخاص بهذه الشاشة
          const BannerAdWidget(screenName: 'StoresListScreen'),
        ],
      ),
      // --- نهاية التعديل 2 ---
    );
  }
}
