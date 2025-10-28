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
import 'stores_list_screen.dart'; // <-- استيراد شاشة المتاجر الجديدة
import '../supplier/store_management_screen.dart';

class MainScreenHolder extends StatefulWidget {
  const MainScreenHolder({super.key});

  @override
  State<MainScreenHolder> createState() => _MainScreenHolderState();
}

class _MainScreenHolderState extends State<MainScreenHolder> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    // التأكد من أن الفهرس ضمن النطاق قبل تحديث الحالة
    // هذا يمنع الأخطاء عند التبديل بين أنواع المستخدمين التي لها أعداد مختلفة من الألسنة
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      final itemCount = _getNavItems(user.userType).length;
      if (index < itemCount) {
        setState(() {
          _selectedIndex = index;
        });
      } else {
        // إذا كان الفهرس خارج النطاق، أعده إلى الصفر
        setState(() {
          _selectedIndex = 0;
        });
      }
    }
  }

  // دالة مساعدة لتوليد عناصر شريط التنقل بناءً على نوع المستخدم
  List<BottomNavigationBarItem> _getNavItems(String userType) {
    if (userType == AppStrings.client) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.people), label: AppStrings.craftsmenLabel),
        BottomNavigationBarItem(icon: Icon(Icons.storefront), label: AppStrings.storeLabel), // <-- إضافة المتاجر للعميل
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: AppStrings.requestsLabel),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: AppStrings.chatsLabel),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.profileLabel),
      ];
    } else if (userType == AppStrings.craftsman) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: AppStrings.requestsLabel),
        BottomNavigationBarItem(icon: Icon(Icons.storefront), label: AppStrings.storeLabel), // <-- إضافة المتاجر للحرفي
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

  // دالة مساعدة لتوليد الشاشات بناءً على نوع المستخدم
  List<Widget> _getScreens(String userType) {
    if (userType == AppStrings.client) {
      return const [
        AvailableCraftsmenScreen(),
        StoresListScreen(), // <-- إضافة شاشة المتاجر للعميل
        RequestsScreen(),
        ChatsScreen(),
        ProfileScreen(),
      ];
    } else if (userType == AppStrings.craftsman) {
      return const [
        RequestsScreen(),
        StoresListScreen(), // <-- إضافة شاشة المتاجر للحرفي
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
    return [const Center(child: Text('نوع مستخدم غير معروف'))];
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      // هذا يحدث للحظة وجيزة قبل إعادة التوجيه، لذلك شاشة تحميل مناسبة
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // إعادة تعيين الفهرس إذا كان خارج النطاق بعد تغيير نوع المستخدم
    final itemCount = _getNavItems(user.userType).length;
    if (_selectedIndex >= itemCount) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _getScreens(user.userType),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _getNavItems(user.userType),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // مهم لعرض كل العناوين
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
  }
}
