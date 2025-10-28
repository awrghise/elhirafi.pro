// lib/screens/main/main_screen_holder.dart

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
import '../supplier/store_management_screen.dart'; // For suppliers

class MainScreenHolder extends StatefulWidget {
  const MainScreenHolder({super.key});

  @override
  State<MainScreenHolder> createState() => _MainScreenHolderState();
}

class _MainScreenHolderState extends State<MainScreenHolder> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> screens;
    final List<BottomNavigationBarItem> navItems;

    if (user.userType == AppStrings.client) {
      screens = const [
        AvailableCraftsmenScreen(),
        RequestsScreen(),
        ChatsScreen(),
        ProfileScreen(),
      ];
      // --- بداية التعديل 1: إزالة const وتصحيح اسم المتغير ---
      navItems = [
        BottomNavigationBarItem(icon: Icon(Icons.people), label: AppStrings.craftsmenLabel),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: AppStrings.requestsLabel),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: AppStrings.chatsLabel),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.profileLabel),
      ];
      // --- نهاية التعديل 1 ---
    } else if (user.userType == AppStrings.craftsman) {
      screens = const [
        RequestsScreen(),
        ChatsScreen(),
        ProfileScreen(),
        SettingsScreen(),
      ];
      // --- بداية التعديل 2: إزالة const وتصحيح اسم المتغير ---
      navItems = [
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: AppStrings.requestsLabel),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: AppStrings.chatsLabel),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.profileLabel),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: AppStrings.settingsLabel),
      ];
      // --- نهاية التعديل 2 ---
    } else if (user.userType == AppStrings.supplier) {
      screens = const [
        StoreManagementScreen(),
        ChatsScreen(),
        ProfileScreen(),
        SettingsScreen(),
      ];
      // --- بداية التعديل 3: إزالة const وتصحيح اسم المتغير ---
      navItems = [
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'المتجر'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: AppStrings.chatsLabel),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.profileLabel),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: AppStrings.settingsLabel),
      ];
      // --- نهاية التعديل 3 ---
    } else {
      screens = [const Center(child: Text('نوع مستخدم غير معروف'))];
      navItems = [const BottomNavigationBarItem(icon: Icon(Icons.error), label: 'خطأ')];
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
