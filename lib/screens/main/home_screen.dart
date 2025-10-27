// lib/screens/main/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../data/cities_data.dart'; // <-- إضافة جديدة
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/store_service.dart';
import '../../widgets/banner_ad_widget.dart';

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
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildDashboard(context, user),
          ),
          const BannerAdWidget(screenName: 'HomeScreen'),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, UserModel user) {
    switch (user.userType) {
      case AppStrings.client:
        return const _ClientDashboard();
      case AppStrings.craftsman:
        return _CraftsmanDashboard(user: user);
      case AppStrings.supplier:
        return _SupplierDashboard(user: user);
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'نوع المستخدم غير معروف: ${user.userType}',
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
  }
}

// --- لوحة تحكم العميل (Client) ---
class _ClientDashboard extends StatelessWidget {
  const _ClientDashboard();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            color: AppColors.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          AppStrings.clientDashboardWelcomeMessage,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'أنشئ طلبًا أو تصفح الحرفيين المتاحين.',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.add_circle_outline,
                  label: AppStrings.makeNewRequest,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('شاشة إنشاء الطلب قيد التطوير')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.people_outline,
                  label: AppStrings.availableCraftsmen,
                  onTap: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('شاشة الحرفيين قيد التطوير')),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('طلباتك الأخيرة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'لا توجد طلبات حاليًا.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- لوحة تحكم الحرفي (Craftsman) ---
class _CraftsmanDashboard extends StatelessWidget {
  final UserModel user;
  const _CraftsmanDashboard({required this.user});

  // --- بداية الإضافة: دالة لعرض مربع حوار اختيار المدن ---
  void _showCitySelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AlertCitySelectionDialog(
          user: user,
          onCitiesSelected: (selectedCities) async {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            await authProvider.updateUserProfile(user.id, {'alertCities': selectedCities});
          },
        );
      },
    );
  }
  // --- نهاية الإضافة ---

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // البطاقة الأولى: المعلومات الأساسية والجاهزية
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.grey),
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                      Column(
                        children: [
                          Text(
                            'جاهز للعمل',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: user.isAvailable ?? false ? AppColors.successColor : AppColors.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
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
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.construction, color: AppColors.primaryColor, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        user.professionName ?? 'غير محدد',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                   const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_pin, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'مقر العمل: ${user.primaryCity ?? 'غير محدد'}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // البطاقة الثانية: مدن تلقي التنبيهات
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active, color: AppColors.primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'مدن تلقي التنبيهات',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (user.alertCities.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: user.alertCities.map((city) => Chip(label: Text(city))).toList(),
                    )
                  else
                    const Text('لم تحدد أي مدن لتلقي التنبيهات.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit_notifications),
                      label: const Text('تعديل مدن التنبيهات'),
                      onPressed: () => _showCitySelectionDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        side: const BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'الطلبات الجديدة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'لا توجد طلبات جديدة حاليًا.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- لوحة تحكم المورد (Supplier) ---
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
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
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
            Navigator.pushNamed(context, '/store_management');
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

// -- Widgets مساعدة --
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

// --- بداية الإضافة: مربع حوار اختيار مدن التنبيهات ---
class _AlertCitySelectionDialog extends StatefulWidget {
  final UserModel user;
  final Function(List<String>) onCitiesSelected;

  const _AlertCitySelectionDialog({
    required this.user,
    required this.onCitiesSelected,
  });

  @override
  State<_AlertCitySelectionDialog> createState() => _AlertCitySelectionDialogState();
}

class _AlertCitySelectionDialogState extends State<_AlertCitySelectionDialog> {
  late List<String> _tempSelectedCities;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempSelectedCities = List.from(widget.user.alertCities);
  }

  List<String> get _filteredCities {
    if (widget.user.country == null) {
      return [];
    }
    final cities = CitiesData.getRegions(widget.user.country!);
    if (_searchQuery.isEmpty) {
      return cities;
    }
    return cities.where((city) => city.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اختر مدن تلقي التنبيهات'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: AppStrings.search,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredCities.length,
                itemBuilder: (context, index) {
                  final city = _filteredCities[index];
                  final isSelected = _tempSelectedCities.contains(city);
                  return CheckboxListTile(
                    title: Text(city, style: const TextStyle(fontSize: 14)),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _tempSelectedCities.add(city);
                        } else {
                          _tempSelectedCities.remove(city);
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
          onPressed: () {
            widget.onCitiesSelected(_tempSelectedCities);
            Navigator.of(context).pop();
          },
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}
// --- نهاية الإضافة ---
