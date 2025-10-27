// lib/screens/main/available_craftsmen_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../data/professions_data.dart';
import '../../data/cities_data.dart';
import '../chat/chat_detail_screen.dart';

class AvailableCraftsmenScreen extends StatefulWidget {
  const AvailableCraftsmenScreen({super.key});

  @override
  State<AvailableCraftsmenScreen> createState() => _AvailableCraftsmenScreenState();
}

class _AvailableCraftsmenScreenState extends State<AvailableCraftsmenScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  
  final List<UserModel> _craftsmen = [];
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
          .where('userType', isEqualTo: AppStrings.craftsman)
          .where('isAvailable', isEqualTo: true);

      if (_selectedProfession != null) {
        query = query.where('professionName', isEqualTo: _selectedProfession);
      }

      if (_selectedCity != null) {
        query = query.where('alertCities', arrayContains: _selectedCity);
      }

      query = query.orderBy('createdAt', descending: true).limit(_pageSize);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        if(mounted) setState(() => _hasMore = false);
      } else {
        final newCraftsmen = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
        if(mounted) {
          setState(() {
            _craftsmen.addAll(newCraftsmen);
            _lastDocument = snapshot.docs.last;
            _hasMore = newCraftsmen.length == _pageSize;
          });
        }
      }
    } catch (e) {
      print('Error loading craftsmen: $e');
    } finally {
      if(mounted) setState(() => _isLoading = false);
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
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
    final userCountry = currentUser?.country ?? 'المغرب';
    final availableCities = CitiesData.getRegions(userCountry);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.availableCraftsmen),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.surface,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedProfession,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'اختر المهنة',
                    prefixIcon: const Icon(Icons.work_outline, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('جميع المهن')),
                    ...ProfessionsData().getAllProfessions().map((profession) {
                      return DropdownMenuItem(
                        value: profession.getNameByDialect('AR'),
                        child: Text(profession.getNameByDialect('AR'), style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedProfession = value);
                    _resetAndReload();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'اختر المدينة',
                    prefixIcon: const Icon(Icons.location_city_outlined, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('جميع المدن')),
                    ...availableCities.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCity = value);
                    _resetAndReload();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _craftsmen.isEmpty && !_isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('لا يوجد حرفيون متاحون بالفلتر الحالي', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _craftsmen.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _craftsmen.length) {
                        return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                      }
                      final craftsman = _craftsmen[index];
                      return _buildCraftsmanCard(craftsman, currentUser?.userType == AppStrings.client);
                    },
                  ),
          ),
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
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  backgroundImage: craftsman.profileImageUrl.isNotEmpty ? NetworkImage(craftsman.profileImageUrl) : null,
                  child: craftsman.profileImageUrl.isEmpty
                      ? Text(craftsman.name.isNotEmpty ? craftsman.name[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(craftsman.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(craftsman.professionName ?? 'حرفي', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              craftsman.primaryWorkCity ?? 'غير محدد',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isClient ? () => _contactCraftsman(craftsman) : null,
                    icon: const Icon(Icons.chat_outlined, size: 18),
                    label: const Text('محادثة'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryColor, side: const BorderSide(color: AppColors.primaryColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isClient ? () => _callCraftsman(craftsman) : null,
                    icon: const Icon(Icons.phone_outlined, size: 18),
                    label: const Text('اتصال'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _contactCraftsman(UserModel craftsman) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentUser = authProvider.user;

    if (currentUser == null) return;

    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      final chatId = await chatProvider.getOrCreateChat(
        user1Id: currentUser.id,
        user1Name: currentUser.name,
        user2Id: craftsman.id,
        user2Name: craftsman.name,
      );

      if(mounted) Navigator.pop(context);

      if(mounted){
        // --- بداية التعديل: تمرير رقم الهاتف ---
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              chatId: chatId,
              otherUserId: craftsman.id,
              otherUserName: craftsman.name,
              otherUserPhone: craftsman.phoneNumber, // <-- هنا التعديل
            ),
          ),
        );
        // --- نهاية التعديل ---
      }
    } catch (e) {
      if(mounted) Navigator.pop(context);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل بدء المحادثة: $e')));
    }
  }

  void _callCraftsman(UserModel craftsman) async {
    final url = Uri.parse('tel:${craftsman.phoneNumber}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('لا يمكن إجراء الاتصال بالرقم ${craftsman.phoneNumber}')));
    }
  }
}
