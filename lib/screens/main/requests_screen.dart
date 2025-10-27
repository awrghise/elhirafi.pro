// lib/screens/main/requests_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../widgets/request_card.dart';
import '../../models/user_model.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      // --- بداية التعديل ---
      requestProvider.fetchInitialRequests(
        userType: user.userType,
        userId: user.id,
        professionName: user.professionName,
        primaryCity: user.primaryWorkCity, // <-- استخدام الحقل الصحيح
      );
      // --- نهاية التعديل ---
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
        final user = authProvider.user;
        if (user != null) {
          // --- بداية التعديل ---
          requestProvider.fetchMoreRequests(
            userType: user.userType,
            userId: user.id,
            professionName: user.professionName,
            primaryCity: user.primaryWorkCity, // <-- استخدام الحقل الصحيح
          );
          // --- نهاية التعديل ---
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.requests),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Consumer<RequestProvider>(
        builder: (context, requestProvider, child) {
          if (requestProvider.isLoading && requestProvider.requests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (requestProvider.requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد طلبات حالياً', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            itemCount: requestProvider.requests.length + (requestProvider.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == requestProvider.requests.length) {
                return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
              }
              final RequestModel request = requestProvider.requests[index];
              return RequestCard(request: request);
            },
          );
        },
      ),
    );
  }
}
