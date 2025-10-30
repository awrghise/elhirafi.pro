import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/store_item_model.dart';
import '../../providers/store_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../main/settings_screen.dart'; // استيراد شاشة الإعدادات

class StoreManagementScreen extends StatefulWidget {
  const StoreManagementScreen({super.key});

  @override
  State<StoreManagementScreen> createState() => _StoreManagementScreenState();
}

class _StoreManagementScreenState extends State<StoreManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<StoreProvider>(context, listen: false).fetchStoreItems(user.id);
      }
    });
  }

  // دالة لعرض نافذة إضافة/تعديل المنتج
  void _showItemDialog({StoreItemModel? item}) {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    // التحقق من حد المنتجات المجانية قبل فتح نافذة إضافة منتج جديد
    if (item == null && storeProvider.items.length >= 4) {
      _showUpgradeDialog();
      return;
    }

    final _nameController = TextEditingController(text: item?.name);
    final _priceController = TextEditingController(text: item?.price.toString());
    final _descriptionController = TextEditingController(text: item?.description); // حقل الوصف
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'إضافة منتج جديد' : 'تعديل المنتج'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'اسم المنتج'),
                    validator: (value) => value!.isEmpty ? 'الرجاء إدخال اسم المنتج' : null,
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'السعر'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'الرجاء إدخال السعر' : null,
                  ),
                  TextFormField( // حقل الوصف
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'وصف المنتج'),
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? 'الرجاء إدخال وصف للمنتج' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newItem = StoreItemModel(
                    id: item?.id ?? '', // سيتم إنشاء ID جديد في Firebase إذا كان فارغًا
                    name: _nameController.text,
                    price: double.parse(_priceController.text),
                    description: _descriptionController.text, // حفظ الوصف
                    imageUrl: item?.imageUrl ?? '', // الاحتفاظ بالصورة الحالية أو تركها فارغة
                    supplierId: user!.id,
                  );

                  if (item == null) {
                    storeProvider.addStoreItem(newItem);
                  } else {
                    storeProvider.updateStoreItem(newItem);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  // دالة لعرض نافذة الترقية
  void _showUpgradeDialog() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    String price = '\$7 USD'; // السعر الافتراضي
    if (user != null) {
      switch (user.country) {
        case 'المغرب':
          price = '75 MAD';
          break;
        case 'الجزائر':
          price = '1200 DZD';
          break;
        case 'تونس':
          price = '25 TND';
          break;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الوصول للحد الأقصى'),
        content: Text('لقد وصلت إلى الحد الأقصى للمنتجات المسموح بها في الباقة المجانية (4 منتجات). قم بترقية حسابك لإضافة عدد غير محدود من المنتجات مقابل $price شهريًا.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('لاحقًا'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement payment logic
              Navigator.of(context).pop();
            },
            child: const Text('الترقية الآن'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- بداية التعديل: إضافة Scaffold و AppBar ---
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.storeManagement),
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Share.share('تصفح متجري على تطبيق الصانع الحرفي! [رابط المتجر]');
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
      body: UpgradeAlert(
        upgrader: Upgrader(
          dialogStyle: UpgradeDialogStyle.material,
          canDismissDialog: false,
          showLater: true,
          showIgnore: false,
        ),
        child: Consumer<StoreProvider>(
          builder: (context, storeProvider, child) {
            if (storeProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (storeProvider.items.isEmpty) {
              return const Center(child: Text('متجرك فارغ. قم بإضافة أول منتج لك!'));
            }
            return ListView.builder(
              itemCount: storeProvider.items.length,
              itemBuilder: (context, index) {
                final item = storeProvider.items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.inventory_2_outlined, color: AppColors.primaryColor),
                    title: Text(item.name),
                    subtitle: Text('${item.price} ${AppStrings.currency}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showItemDialog(item: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => storeProvider.deleteStoreItem(item.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      // هذا الزر سيظهر الآن بشكل صحيح
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
    // --- نهاية التعديل ---
  }
}
