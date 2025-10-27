import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/banner_ad_widget.dart';
import 'settings_screen.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Route to the correct dashboard based on user type
    switch (user.userType) {
      case 'client':
        return const _ClientDashboard();
      case 'craftsman':
        return const _CraftsmanDashboard();
      case 'supplier':
        return const _SupplierDashboard();
      default:
        return const Scaffold(
          body: Center(child: Text('Unknown user type')),
        );
    }
  }
}

// CLIENT DASHBOARD
class _ClientDashboard extends StatefulWidget {
  const _ClientDashboard();

  @override
  State<_ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<_ClientDashboard> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.clientDashboardTitle),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareApp(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
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
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن حرفي أو خدمة...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.mic, color: Colors.white, size: 20),
                    onPressed: () {
                      // TODO: Implement voice search
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('البحث الصوتي قريباً')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primaryColor,
                            child: Text(
                              user?.displayName[0].toUpperCase() ?? 'ع',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'مرحباً، ${user?.displayName ?? ""}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ما الخدمة التي تحتاجها اليوم؟',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions
                  const Text(
                    'الإجراءات السريعة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.add_circle,
                          title: 'طلب جديد',
                          color: AppColors.primaryColor,
                          onTap: () {
                            // TODO: Navigate to new request screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('شاشة الطلب الجديد قريباً')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.history,
                          title: 'طلباتي',
                          color: AppColors.secondaryColor,
                          onTap: () {
                            // TODO: Navigate to my requests
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Popular Professions
                  const Text(
                    'المهن الأكثر طلباً',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPopularProfessions(context),
                ],
              ),
            ),
          ),

          // Banner Ad
          const BannerAdWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to new request screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('شاشة الطلب الجديد قريباً')),
          );
        },
        label: const Text(AppStrings.makeNewRequest),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularProfessions(BuildContext context) {
    final professions = [
      {'name': 'بناء', 'icon': Icons.construction},
      {'name': 'كهربائي', 'icon': Icons.electrical_services},
      {'name': 'سباك', 'icon': Icons.plumbing},
      {'name': 'نجار', 'icon': Icons.carpenter},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: professions.length,
      itemBuilder: (context, index) {
        final profession = professions[index];
        return InkWell(
          onTap: () {
            // TODO: Navigate to profession details
          },
          borderRadius: BorderRadius.circular(12),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  profession['icon'] as IconData,
                  size: 32,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  profession['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _shareApp() {
    Share.share(
      'تطبيق الصانع الحرفي - منصة ربط الحرفيين بأصحاب المشاريع\nhttps://play.google.com/store/apps/details?id=com.elsane3.app',
    );
  }
}

// CRAFTSMAN DASHBOARD
class _CraftsmanDashboard extends StatefulWidget {
  const _CraftsmanDashboard();

  @override
  State<_CraftsmanDashboard> createState() => _CraftsmanDashboardState();
}

class _CraftsmanDashboardState extends State<_CraftsmanDashboard> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isAvailable = user?.isAvailable ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.craftsmanDashboardTitle),
        backgroundColor: AppColors.primaryColor,
        actions: [
          // Availability Toggle
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isAvailable ? AppColors.successColor : Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAvailable ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  isAvailable ? 'متاح' : 'مشغول',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareApp(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
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
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن طلبات أو حرفيين...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.mic, color: Colors.white, size: 20),
                    onPressed: () {
                      // TODO: Implement voice search
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('البحث الصوتي قريباً')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Availability Card
                  Card(
                    elevation: 2,
                    color: isAvailable
                        ? AppColors.successColor.withOpacity(0.1)
                        : Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            isAvailable ? Icons.work : Icons.work_off,
                            size: 40,
                            color: isAvailable ? AppColors.successColor : Colors.grey,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.workStatus,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAvailable
                                      ? AppStrings.willReceiveJobAlerts
                                      : AppStrings.willNotReceiveJobAlerts,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isAvailable,
                            onChanged: (value) {
                              authProvider.updateAvailability(value);
                            },
                            activeColor: AppColors.successColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recent Requests
                  const Text(
                    AppStrings.recentJobRequests,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            AppStrings.noRequestsYet,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Banner Ad
          const BannerAdWidget(),
        ],
      ),
    );
  }

  void _shareApp() {
    Share.share(
      'تطبيق الصانع الحرفي - منصة ربط الحرفيين بأصحاب المشاريع\nhttps://play.google.com/store/apps/details?id=com.elsane3.app',
    );
  }
}

// SUPPLIER DASHBOARD
class _SupplierDashboard extends StatelessWidget {
  const _SupplierDashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المورد'),
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store, size: 80, color: AppColors.primaryColor),
                  const SizedBox(height: 16),
                  const Text(
                    'مرحباً بك في لوحة تحكم الموردين',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'قم بإدارة متجرك ومنتجاتك',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to store management
                      Navigator.pushNamed(context, '/store_management');
                    },
                    icon: const Icon(Icons.store),
                    label: const Text('إدارة المتجر'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }
}

