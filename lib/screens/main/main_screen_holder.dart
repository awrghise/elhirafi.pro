import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

// Import all the main screens
import 'available_craftsmen_screen.dart';
import 'requests_screen.dart';
import 'chats_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'stores_list_screen.dart';
import '../supplier/store_management_screen.dart';

class MainScreenHolder extends StatefulWidget {
  const MainScreenHolder({super.key});

  @override
  State<MainScreenHolder> createState() => _MainScreenHolderState();
}

class _MainScreenHolderState extends State<MainScreenHolder> {
  int _selectedIndex = 0;

  // دالة مساعدة لتوحيد نوع المستخدم (التعامل مع القيم العربية والإنجليزية)
  String _normalizeUserType(String userType) {
    final normalized = userType.trim().toLowerCase();
    if (normalized == 'client' || normalized == 'عميل') {
      return AppStrings.client;
    } else if (normalized == 'craftsman' || normalized == 'حرفي') {
      return AppStrings.craftsman;
    } else if (normalized == 'supplier' || normalized == 'مورد') {
      return AppStrings.supplier;
    }
    return userType; // إرجاع القيمة الأصلية إذا لم تتطابق
  }

  void _onItemTapped(int index) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      final itemCount = _getNavItems(_normalizeUserType(user.userType)).length;
      if (index < itemCount) {
        setState(() {
          _selectedIndex = index;
        });
      } else {
        setState(() {
          _selectedIndex = 0;
        });
      }
    }
  }

  List<BottomNavigationBarItem> _getNavItems(String userType) {
    if (userType == AppStrings.client) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.people), label: AppStrings.craftsmenLabel),
        BottomNavigationBarItem(icon: Icon(Icons.storefront), label: AppStrings.storeLabel),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: AppStrings.requestsLabel),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: AppStrings.chatsLabel),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.profileLabel),
      ];
    } else if (userType == AppStrings.craftsman) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: AppStrings.requestsLabel),
        BottomNavigationBarItem(icon: Icon(Icons.storefront), label: AppStrings.storeLabel),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: AppStrings.chatsLabel),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.profileLabel),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: AppStrings.settingsLabel),
      ];
    } else if (userType == AppStrings.supplier) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.store), label: AppStrings.storeLabel),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: AppStrings.chatsLabel),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.profileLabel),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: AppStrings.settingsLabel),
      ];
    }
    return [const BottomNavigationBarItem(icon: Icon(Icons.error), label: 'خطأ')];
  }

  List<Widget> _getScreens(String userType) {
    if (userType == AppStrings.client) {
      return const [
        AvailableCraftsmenScreen(),
        StoresListScreen(),
        RequestsScreen(),
        ChatsScreen(),
        ProfileScreen(),
      ];
    } else if (userType == AppStrings.craftsman) {
      return const [
        RequestsScreen(),
        StoresListScreen(),
        ChatsScreen(),
        ProfileScreen(),
        SettingsScreen(),
      ];
    } else if (userType == AppStrings.supplier) {
      return const [
        StoreManagementScreen(),
        ChatsScreen(),
        ProfileScreen(),
        SettingsScreen(),
      ];
    }
    return [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'نوع مستخدم غير معروف: $userType',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'الرجاء التواصل مع الدعم الفني',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final normalizedUserType = _normalizeUserType(user.userType);
    final itemCount = _getNavItems(normalizedUserType).length;
    if (_selectedIndex >= itemCount) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _getScreens(normalizedUserType),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _getNavItems(normalizedUserType),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
  }
}
