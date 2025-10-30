import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'settings_screen.dart'; // استيراد شاشة الإعدادات

class StoresListScreen extends StatefulWidget {
  const StoresListScreen({super.key});

  @override
  State<StoresListScreen> createState() => _StoresListScreenState();
}

class _StoresListScreenState extends State<StoresListScreen> {
  // بيانات وهمية مؤقتة لعرض التصميم
  final List<Map<String, dynamic>> _stores = [
    {'name': 'متجر مواد البناء الحديثة', 'owner': 'أحمد علي', 'image': 'assets/images/placeholder_image.png'},
    {'name': 'الورشة الفنية للأخشاب', 'owner': 'فاطمة الزهراء', 'image': 'assets/images/placeholder_image.png'},
    {'name': 'معرض الأصباغ والديكور', 'owner': 'يوسف إبراهيم', 'image': 'assets/images/placeholder_image.png'},
    {'name': 'أدوات السباكة والكهرباء', 'owner': 'خالد منصور', 'image': 'assets/images/placeholder_image.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- بداية التعديل: إضافة AppBar مع أيقونات ---
      appBar: AppBar(
        title: const Text(AppStrings.storesLabel),
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false, // لإخفاء سهم الرجوع
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Share.share('تصفح أفضل متاجر الحرفيين والموردين على تطبيق الصانع الحرفي! [رابط التطبيق]');
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
      // --- نهاية التعديل ---
      body: ListView.builder(
        itemCount: _stores.length,
        itemBuilder: (context, index) {
          final store = _stores[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  store['image'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                store['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('صاحب المتجر: ${store['owner']}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: الانتقال إلى صفحة المتجر العامة لعرض المنتجات
              },
            ),
          );
        },
      ),
    );
  }
}
