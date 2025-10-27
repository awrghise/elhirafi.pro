import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/store_service.dart';
import '../../widgets/banner_ad_widget.dart';

class StoreManagementScreen extends StatefulWidget {
  const StoreManagementScreen({super.key});

  @override
  State<StoreManagementScreen> createState() => _StoreManagementScreenState();
}

class _StoreManagementScreenState extends State<StoreManagementScreen> {
  final StoreService _storeService = StoreService();
  StoreModel? _store;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final store = await _storeService.getStoreBySupplier(user.uid);
    setState(() {
      _store = store;
      _isLoading = false;
    });

    if (store == null) {
      _showCreateStoreDialog();
    }
  }

  void _showCreateStoreDialog() {
    // TODO: Show dialog to create store
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('يرجى إنشاء متجرك أولاً')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_store == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المتجر'),
          backgroundColor: AppColors.primaryColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'لا يوجد متجر بعد',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'قم بإنشاء متجرك للبدء',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showCreateStoreDialog,
                icon: const Icon(Icons.add),
                label: const Text('إنشاء متجر'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_store!.storeName),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to store settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Store Info Card
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceColor,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _store!.isPremium
                            ? Colors.amber.withOpacity(0.2)
                            : AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _store!.isPremium ? Icons.star : Icons.store,
                        color: _store!.isPremium ? Colors.amber : AppColors.primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _store!.storeName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _store!.isPremium ? 'عضوية مميزة' : 'عضوية مجانية',
                            style: TextStyle(
                              fontSize: 14,
                              color: _store!.isPremium ? Colors.amber[700] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_store!.isPremium)
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Show upgrade dialog
                          _showUpgradeDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('ترقية'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                StreamBuilder<int>(
                  stream: Stream.fromFuture(_storeService.getProductCount(user!.uid)),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    final maxProducts = _store!.actualMaxProducts;
                    return LinearProgressIndicator(
                      value: count / maxProducts,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        count >= maxProducts ? Colors.red : AppColors.primaryColor,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                StreamBuilder<int>(
                  stream: Stream.fromFuture(_storeService.getProductCount(user.uid)),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    final maxProducts = _store!.actualMaxProducts;
                    return Text(
                      'المنتجات: $count / $maxProducts',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _storeService.getStoreProducts(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('خطأ: ${snapshot.error}'));
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'لا توجد منتجات بعد',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'اضغط على + لإضافة منتج جديد',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(product);
                  },
                );
              },
            ),
          ),

          // Banner Ad
          const BannerAdWidget(),
        ],
      ),
      floatingActionButton: StreamBuilder<int>(
        stream: Stream.fromFuture(_storeService.getProductCount(user.uid)),
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          final canAdd = count < _store!.actualMaxProducts;

          return FloatingActionButton.extended(
            onPressed: canAdd
                ? () => _showAddProductDialog()
                : () => _showUpgradeDialog(),
            icon: Icon(canAdd ? Icons.add : Icons.lock),
            label: Text(canAdd ? 'إضافة منتج' : 'ترقية'),
            backgroundColor: canAdd ? AppColors.primaryColor : Colors.grey,
          );
        },
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // TODO: Show product details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.imageUrls.isNotEmpty
                    ? Image.network(
                        product.imageUrls.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(2)} درهم',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: product.isAvailable
                                ? AppColors.successColor.withOpacity(0.1)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.isAvailable ? 'متاح' : 'غير متاح',
                            style: TextStyle(
                              fontSize: 12,
                              color: product.isAvailable ? AppColors.successColor : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('تعديل'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('حذف', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    // TODO: Edit product
                  } else if (value == 'delete') {
                    _deleteProduct(product);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    // TODO: Show add product dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('شاشة إضافة منتج قريباً')),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 8),
            Text('الترقية للعضوية المميزة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مميزات العضوية المميزة:'),
            const SizedBox(height: 12),
            _buildFeature('50 منتج بدلاً من 10'),
            _buildFeature('أولوية في نتائج البحث'),
            _buildFeature('شارة مميزة على متجرك'),
            _buildFeature('دعم فني مخصص'),
            const SizedBox(height: 16),
            const Text(
              'السعر: 50 درهم شهرياً',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement payment
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('الدفع قريباً')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: const Text('ترقية الآن'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.successColor, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${product.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _storeService.deleteProduct(product.id, product.imageUrls);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'تم الحذف بنجاح' : 'فشل الحذف'),
            backgroundColor: success ? AppColors.successColor : AppColors.errorColor,
          ),
        );
      }
    }
  }
}

