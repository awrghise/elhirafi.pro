// lib/screens/main/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alsana_alharfiyin/models/user_model.dart';
import 'package:alsana_alharfiyin/providers/auth_provider.dart';
import 'package:alsana_alharfiyin/constants/app_colors.dart';
import 'package:alsana_alharfiyin/constants/app_strings.dart'; // <-- ١. استيراد الثوابت
import 'package:alsana_alharfiyin/widgets/banner_ad_widget.dart';
import 'package:alsana_alharfiyin/services/store_service.dart';
import 'package:alsana_alharfiyin/models/product_model.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('مرحباً ${user.name}'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                'تطبيق الصانع الحرفي - منصة ربط الحرفيين بأصحاب المشاريع\nhttps://play.google.com/store/apps/details?id=com.elsane3.app',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildDashboard(context, user),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, UserModel user) {
    // --- بداية التعديل ---
    switch (user.userType) {
      case AppStrings.client: // استخدام الثابت بدلاً من النص
        return const _ClientDashboard();
      case AppStrings.craftsman: // استخدام الثابت بدلاً من النص
        return _CraftsmanDashboard(user: user);
      case AppStrings.supplier: // استخدام الثابت بدلاً من النص
        return _SupplierDashboard(user: user);
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'نوع المستخدم غير معروف: "${user.userType}"',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).signOut();
                },
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
        );
    }
    // --- نهاية التعديل ---
  }
}

// --- لوحة تحكم العميل ---
class _ClientDashboard extends StatelessWidget {
  const _ClientDashboard();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build_circle, size: 100, color: AppColors.primaryColor),
            const SizedBox(height: 24),
            const Text('لوحة تحكم العميل', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('ابحث عن الحرفيين المتاحين أو أنشئ طلب جديد', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigator.pushNamed(context, '/create_request');
              },
              icon: const Icon(Icons.add),
              label: const Text('إنشاء طلب جديد'),
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
}

// --- لوحة تحكم الحرفي ---
class _CraftsmanDashboard extends StatelessWidget {
  final UserModel user;
  const _CraftsmanDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.handyman, size: 100, color: AppColors.primaryColor),
            const SizedBox(height: 24),
            const Text('لوحة تحكم الحرفي', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('المهنة: ${user.professionName ?? 'غير محدد'}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('جاهز للعمل'),
                const SizedBox(width: 16),
                Switch(
                  value: user.isAvailable ?? false,
                  onChanged: (value) async {
                    await Provider.of<AuthProvider>(context, listen: false).updateAvailability(value);
                  },
                  activeColor: AppColors.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- لوحة تحكم المورد ---
class _SupplierDashboard extends StatefulWidget {
  final UserModel user;
  const _SupplierDashboard({required this.user});

  @override
  State<_SupplierDashboard> createState() => _SupplierDashboardState();
}

class _SupplierDashboardState extends State<_SupplierDashboard> {
  final StoreService _storeService = StoreService();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. بطاقات الإحصائيات
          _buildStatsCards(),
          const SizedBox(height: 24),

          // 2. أزرار الإجراءات السريعة
          _buildQuickActions(),
          const SizedBox(height: 24),

          // 3. قسم أحدث المنتجات
          const Text('أحدث المنتجات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildRecentProducts(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'المنتجات',
            icon: Icons.inventory_2,
            color: Colors.blue,
            future: _storeService.getProductCount(widget.user.id),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'الطلبات',
            icon: Icons.shopping_cart,
            color: Colors.orange,
            future: _storeService.getOrdersCount(widget.user.id),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _QuickActionButton(
          icon: Icons.store,
          label: 'إدارة المتجر',
          onTap: () {
            Navigator.pushNamed(context, '/store_management');
          },
        ),
        _QuickActionButton(
          icon: Icons.add_circle,
          label: 'إضافة منتج',
          onTap: () {
            // TODO: Navigate to add product screen directly
            Navigator.pushNamed(context, '/store_management'); // مؤقتًا
          },
        ),
        _QuickActionButton(
          icon: Icons.visibility,
          label: 'عرض المتجر',
          onTap: () {
            // TODO: Navigate to public store view
          },
        ),
      ],
    );
  }

  Widget _buildRecentProducts() {
    return StreamBuilder<List<ProductModel>>(
      stream: _storeService.getStoreProducts(widget.user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('لم تقم بإضافة أي منتجات بعد.'));
        }
        final products = snapshot.data!;
        // Limit to 3 recent products for the dashboard
        final recentProducts = products.take(3).toList();
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentProducts.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final product = recentProducts[index];
            return ListTile(
              leading: product.imageUrls.isNotEmpty
                  ? Image.network(product.imageUrls.first, width: 50, height: 50, fit: BoxFit.cover)
                  : Container(width: 50, height: 50, color: Colors.grey[200], child: const Icon(Icons.image)),
              title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${product.price} درهم'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to product details
              },
            );
          },
        );
      },
    );
  }
}

// -- Widgets مساعدة للوحة تحكم المورد --
class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Future<int> future;

  const _StatCard({required this.title, required this.icon, required this.color, required this.future});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 4),
            FutureBuilder<int>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2));
                }
                return Text(
                  snapshot.data?.toString() ?? '0',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: AppColors.primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
