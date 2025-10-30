import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/decorative_background.dart';

// --- بداية التعديل 1: استيراد ThemeProvider ---
import '../../providers/theme_provider.dart';
// --- نهاية التعديل 1 ---

// استيراد جميع الشاشات الرئيسية
import 'available_craftsmen_screen.dart';
import 'requests_screen.dart';
import 'chats_screen.dart';
import 'profile_screen.dart';
import 'stores_list_screen.dart';
import '../supplier/store_management_screen.dart';

class MainScreenHolder extends StatefulWidget {
  const MainScreenHolder({super.key});

  @override
  State<MainScreenHolder> createState() => _MainScreenHolderState();
}

class _MainScreenHolderState extends State<MainScreenHolder> {
  int _selectedIndex = 0;

  String _normalizeUserType(String userType) {
    final normalized = userType.trim().toLowerCase();
    if (normalized == 'client' || normalized == 'عميل') {
      return AppStrings.client;
    } else if (normalized == 'craftsman' || normalized == 'حرفي') {
      return AppStrings.craftsman;
    } else if (normalized == 'supplier' || normalized == 'مورد') {
      return AppStrings.supplier;
    }
    return 'عميل';
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<BottomNavigationBarItem> _getNavItems(String userType) {
    List<BottomNavigationBarItem> items = [
      if (userType == AppStrings.client)
        const BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: AppStrings.craftsmenLabel)
      else
        const BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: AppStrings.requestsLabel),
      
      const BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: AppStrings.storeLabel),
      const BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: AppStrings.chatsLabel),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: AppStrings.profileLabel),
    ];
    return items;
  }

  List<Widget> _getScreens(String userType) {
    if (userType == AppStrings.client) {
      return const [
        AvailableCraftsmenScreen(),
        StoresListScreen(),
        ChatsScreen(),
        ProfileScreen(),
      ];
    } else if (userType == AppStrings.craftsman) {
      return const [
        RequestsScreen(),
        StoresListScreen(),
        ChatsScreen(),
        ProfileScreen(),
      ];
    } else if (userType == AppStrings.supplier) {
      return const [
        RequestsScreen(),
        StoreManagementScreen(),
        ChatsScreen(),
        ProfileScreen(),
      ];
    }
    return [
      Center(child: Text('نوع مستخدم غير معروف: $userType'))
    ];
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<AuthProvider>(context).user;
    // --- بداية التعديل 2: الوصول إلى ThemeProvider ---
    final themeProvider = Provider.of<ThemeProvider>(context);
    // --- نهاية التعديل 2 ---

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final normalizedUserType = _normalizeUserType(user.userType);
    final navItems = _getNavItems(normalizedUserType);
    final screens = _getScreens(normalizedUserType);

    if (_selectedIndex >= navItems.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: Stack(
        children: [
          // --- بداية التعديل 3: جعل الخلفية مشروطة ---
          // لن تظهر الخلفية إلا إذا كان الخيار مفعلاً في الإعدادات
          if (themeProvider.showBackgroundPattern)
            const DecorativeBackground(),
          // --- نهاية التعديل 3 ---

          IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).cardColor,
        showUnselectedLabels: true,
      ),
    );
  }
}
