import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../constants/app_colors.dart';

// تصحيح مسارات الاستيراد
import '../../models/store_item_model.dart';
import '../../providers/store_provider.dart';

class StoreManagementScreen extends StatefulWidget {
  const StoreManagementScreen({super.key});

  @override
  State<StoreManagementScreen> createState() => _StoreManagementScreenState();
}

class _StoreManagementScreenState extends State<StoreManagementScreen> {
  @override
  void initState() {
    super.initState();
    // جلب البيانات الأولية عند تحميل الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<StoreProvider>(context, listen: false).fetchStoreItems(user.id);
      }
    });
  }

  // --- بداية التعديل 1: منطق التحقق من الاشتراك والحد الأقصى ---
  void _handleAddNewItem() {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    // نفترض أن المستخدم الحالي ليس مشتركًا (لأغراض العرض)
    // في المستقبل، سنتحقق من قيمة حقيقية مثل user.isPremium
    const isPremium = false; 
    const productLimit = 4;
    final currentProductCount = storeProvider.items.length;

    if (!isPremium && currentProductCount >= productLimit) {
      // إذا وصل للحد الأقصى وليس مشتركًا، نعرض رسالة الترقية
      _showUpgradeDialog(user?.country ?? 'المغرب');
    } else {
      // إذا لم يصل للحد، نعرض حوار إضافة المنتج
      _showItemDialog();
    }
  }

  void _showUpgradeDialog(String country) {
    // تحديد السعر والعملة بناءً على الدولة
    String priceText;
    switch (country) {
      case 'المغرب':
        priceText = '75 درهم مغربي شهرياً';
        break;
      case 'الجزائر':
        priceText = '1200 دينار جزائري شهرياً';
        break;
      case 'تونس':
        priceText = '25 دينار تونسي شهرياً';
        break;
      default:
        priceText = '7 دولارات شهرياً';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 قم بترقية حسابك!'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const Text('لقد وصلت إلى الحد الأقصى (4 منتجات) للباقة المجانية.'),
              const SizedBox(height: 16),
              Text('لإضافة عدد لا محدود من المنتجات، قم بالترقية إلى الباقة المميزة مقابل $priceText.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('لاحقًا'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('الترقية الآن'),
            onPressed: () {
              // هنا سيتم وضع منطق الربط مع بوابة الدفع في المستقبل
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ميزة الدفع سيتم تفعيلها قريباً!')),
              );
            },
          ),
        ],
      ),
    );
  }
  // --- نهاية التعديل 1 ---

  void _showItemDialog({StoreItem? item}) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: item?.name);
    // --- بداية التعديل 2: إضافة حقل الوصف ---
    final descriptionController = TextEditingController(text: item?.description);
    // --- نهاية التعديل 2 ---
    final priceController = TextEditingController(text: item?.price.toString());
    File? image;
    String? networkImage = item?.imageUrl;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickImage() async {
              final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setDialogState(() {
                  image = File(pickedFile.path);
                  networkImage = null;
                });
              }
            }

            return AlertDialog(
              title: Text(item == null ? 'إضافة منتج جديد' : 'تعديل المنتج'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: pickImage,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: image != null
                              ? Image.file(image!, fit: BoxFit.cover)
                              : (networkImage != null && networkImage!.isNotEmpty
                                  ? Image.network(networkImage!, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.error))
                                  : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'اسم المنتج'),
                        validator: (value) => value!.isEmpty ? 'الحقل مطلوب' : null,
                      ),
                      // --- بداية التعديل 3: إضافة حقل الوصف للواجهة ---
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'وصف المنتج'),
                        maxLines: 3,
                        validator: (value) => value!.isEmpty ? 'الحقل مطلوب' : null,
                      ),
                      // --- نهاية التعديل 3 ---
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'السعر'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'الحقل مطلوب' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
                      final price = double.tryParse(priceController.text) ?? 0.0;

                      if (item == null) {
                        if (image == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار صورة للمنتج')));
                          return;
                        }
                        final newItem = StoreItem(
                          id: '',
                          name: nameController.text,
                          description: descriptionController.text,
                          price: price,
                          imageUrl: '',
                          supplierId: user.id,
                          createdAt: Timestamp.now(),
                        );
                        await storeProvider.addStoreItem(newItem, image!);
                      } else {
                        final updatedItem = item.copyWith(
                          name: nameController.text,
                          description: descriptionController.text,
                          price: price,
                        );
                        await storeProvider.updateStoreItem(updatedItem, newImage: image);
                      }
                      if(mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المتجر'),
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? const Center(child: Text('الرجاء تسجيل الدخول لإدارة متجرك'))
          : Consumer<StoreProvider>(
              builder: (context, storeProvider, child) {
                if (storeProvider.isLoading && storeProvider.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (storeProvider.items.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.storefront, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('متجرك فارغ. أضف منتجك الأول!', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80), // لإعطاء مساحة للزر العائم
                  itemCount: storeProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = storeProvider.items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: item.imageUrl.isNotEmpty
                            ? Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                            : Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${item.description}\nالسعر: ${item.price}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.primaryColor),
                              onPressed: () => _showItemDialog(item: item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('تأكيد الحذف'),
                                    content: const Text('هل أنت متأكد من رغبتك في حذف هذا المنتج؟'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  Provider.of<StoreProvider>(context, listen: false).deleteStoreItem(item.id, user.id);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: user != null && user.userType == 'supplier'
          ? FloatingActionButton.extended(
              // --- بداية التعديل 4: تغيير الزر واستدعاء الدالة الجديدة ---
              onPressed: _handleAddNewItem,
              // --- نهاية التعديل 4 ---
              backgroundColor: AppColors.primaryColor,
              icon: const Icon(Icons.add),
              label: const Text("إضافة منتج"),
            )
          : null,
    );
  }
}
