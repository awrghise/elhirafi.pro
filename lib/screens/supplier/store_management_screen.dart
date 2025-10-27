// lib/screens/supplier/store_management_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../models/store_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../../models/user_model.dart';

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
        // --- بداية التعديل 1 ---
        Provider.of<StoreProvider>(context, listen: false).fetchStoreItems(user.id);
        // --- نهاية التعديل 1 ---
      }
    });
  }

  void _showItemDialog({StoreItem? item}) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: item?.name);
    final descriptionController = TextEditingController(text: item?.description);
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
                  networkImage = null; // Clear network image if a new one is picked
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
                                  ? Image.network(networkImage!, fit: BoxFit.cover)
                                  : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'اسم المنتج'),
                        validator: (value) => value!.isEmpty ? 'الحقل مطلوب' : null,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'الوصف'),
                        maxLines: 3,
                      ),
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
                        // Add new item
                        if (image == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار صورة للمنتج')));
                          return;
                        }
                        final newItem = StoreItem(
                          id: '', // Firestore will generate it
                          name: nameController.text,
                          description: descriptionController.text,
                          price: price,
                          imageUrl: '', // Will be set after upload
                          // --- بداية التعديل 2 ---
                          supplierId: user.id,
                          // --- نهاية التعديل 2 ---
                          createdAt: Timestamp.now(),
                        );
                        await storeProvider.addStoreItem(newItem, image!);
                      } else {
                        // Update existing item
                        final updatedItem = item.copyWith(
                          name: nameController.text,
                          description: descriptionController.text,
                          price: price,
                          // --- بداية التعديل 3 ---
                          supplierId: user.id,
                          // --- نهاية التعديل 3 ---
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
      ),
      body: user == null
          ? const Center(child: Text('الرجاء تسجيل الدخول لإدارة متجرك'))
          : Consumer<StoreProvider>(
              builder: (context, storeProvider, child) {
                if (storeProvider.isLoading) {
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
                  itemCount: storeProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = storeProvider.items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: item.imageUrl.isNotEmpty
                            ? Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                            : Container(width: 50, height: 50, color: Colors.grey[200]),
                        title: Text(item.name),
                        subtitle: Text('السعر: ${item.price}'),
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
                                  // --- بداية التعديل 4 ---
                                  Provider.of<StoreProvider>(context, listen: false).deleteStoreItem(item.id, user.id);
                                  // --- نهاية التعديل 4 ---
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
          ? FloatingActionButton(
              onPressed: () => _showItemDialog(),
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
