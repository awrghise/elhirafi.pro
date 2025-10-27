import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../models/profession_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/banner_ad_widget.dart';

class AvailableCraftsmenScreen extends StatefulWidget {
  const AvailableCraftsmenScreen({super.key});

  @override
  State<AvailableCraftsmenScreen> createState() => _AvailableCraftsmenScreenState();
}

class _AvailableCraftsmenScreenState extends State<AvailableCraftsmenScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  
  List<UserModel> _craftsmen = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  final int _pageSize = 20;

  String? _selectedProfession;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadCraftsmen();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoading && _hasMore) {
        _loadCraftsmen();
      }
    }
  }

  Future<void> _loadCraftsmen() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      Query query = _firestore
          .collection('users')
          .where('userType', isEqualTo: 'craftsman')
          .where('isAvailable', isEqualTo: true);

      if (_selectedProfession != null) {
        query = query.where('profession', isEqualTo: _selectedProfession);
      }

      if (_selectedCity != null) {
        query = query.where('cities', arrayContains: _selectedCity);
      }

      query = query.orderBy('createdAt', descending: true).limit(_pageSize);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
        return;
      }

      final newCraftsmen = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      setState(() {
        _craftsmen.addAll(newCraftsmen);
        _lastDocument = snapshot.docs.last;
        _hasMore = snapshot.docs.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading craftsmen: $e');
      setState(() => _isLoading = false);
    }
  }

  void _resetAndReload() {
    setState(() {
      _craftsmen.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    _loadCraftsmen();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).user;
    final isClient = currentUser?.userType == 'client';

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.availableCraftsmen),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceColor,
            child: Column(
              children: [
                // Profession Filter
                DropdownButtonFormField<String>(
                  value: _selectedProfession,
                  decoration: InputDecoration(
                    labelText: 'اختر المهنة',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('جميع المهن')),
                    ...ProfessionsData().getAllProfessions().map((profession) {
                      return DropdownMenuItem(
                        value: profession.conceptKey,
                        child: Text(profession.names['MA'] ?? profession.conceptKey),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedProfession = value;
                    });
                    _resetAndReload();
                  },
                ),
                const SizedBox(height: 12),

                // City Filter
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: InputDecoration(
                    labelText: 'اختر المدينة',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('جميع المدن')),
                    DropdownMenuItem(value: 'Casablanca', child: Text('الدار البيضاء')),
                    DropdownMenuItem(value: 'Rabat', child: Text('الرباط')),
                    DropdownMenuItem(value: 'Marrakech', child: Text('مراكش')),
                    DropdownMenuItem(value: 'Fes', child: Text('فاس')),
                    DropdownMenuItem(value: 'Tangier', child: Text('طنجة')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                    _resetAndReload();
                  },
                ),
              ],
            ),
          ),

          // Craftsmen List
          Expanded(
            child: _craftsmen.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_search, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'لا يوجد حرفيون متاحون',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'جرب تغيير الفلاتر',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _craftsmen.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _craftsmen.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final craftsman = _craftsmen[index];
                      return _buildCraftsmanCard(craftsman, isClient);
                    },
                  ),
          ),

          // Banner Ad
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildCraftsmanCard(UserModel craftsman, bool isClient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryColor,
                  child: Text(
                    craftsman.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        craftsman.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        craftsman.profession ?? 'حرفي',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            craftsman.cities.join(', '),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (craftsman.yearsOfExperience != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.work, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${craftsman.yearsOfExperience} سنوات خبرة',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: AppColors.successColor),
                      SizedBox(width: 4),
                      Text(
                        'متاح',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isClient
                        ? () => _contactCraftsman(craftsman)
                        : () => _showClientModeRequired(),
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text('محادثة'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isClient
                        ? () => _callCraftsman(craftsman)
                        : () => _showClientModeRequired(),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('اتصال'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.successColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isClient
                        ? () => _whatsappCraftsman(craftsman)
                        : () => _showClientModeRequired(),
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text('واتساب'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _contactCraftsman(UserModel craftsman) {
    // TODO: Navigate to chat
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('المحادثة قريباً')),
    );
  }

  void _callCraftsman(UserModel craftsman) async {
    final url = Uri.parse('tel:${craftsman.phoneNumber}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _whatsappCraftsman(UserModel craftsman) async {
    final url = Uri.parse('https://wa.me/${craftsman.phoneNumber}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showClientModeRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحويل الوضع'),
        content: const Text('يجب التحول إلى وضع العميل للتواصل مع الحرفيين'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to settings to switch mode
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('اذهب إلى الإعدادات لتغيير الوضع')),
              );
            },
            child: const Text('الإعدادات'),
          ),
        ],
      ),
    );
  }
}

