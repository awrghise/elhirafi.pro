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
      // This should ideally not happen if AuthWrapper is working correctly,
      // but as a fallback, show a loading indicator.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Define the screens and navigation items based on user type
    final List<Widget> screens;
    final List<BottomNavigationBarItem> navItems;

    if (user.userType == AppStrings.client) {
      screens = const [
        AvailableCraftsmenScreen(),
        RequestsScreen(),
        ChatsScreen(),
        ProfileScreen(),
      ];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.people), label: AppStrings.craftsmen),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: AppStrings.requests),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: AppStrings.chats),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.profile),
      ];
    } else if (user.userType == AppStrings.craftsman) {
      screens = const [
        RequestsScreen(), // Craftsmen see available requests
        ChatsScreen(),
        ProfileScreen(),
        SettingsScreen(),
      ];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: AppStrings.requests),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: AppStrings.chats),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.profile),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: AppStrings.settings),
      ];
    } else if (user.userType == AppStrings.supplier) {
      screens = const [
        StoreManagementScreen(),
        ChatsScreen(),
        ProfileScreen(),
        SettingsScreen(),
      ];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'المتجر'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: AppStrings.chats),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.profile),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: AppStrings.settings),
      ];
    } else {
      // Fallback for any other case
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
        type: BottomNavigationBarType.fixed, // Good for 4+ items
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
