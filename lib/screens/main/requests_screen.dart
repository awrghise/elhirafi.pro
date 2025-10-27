// lib/screens/main/requests_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../widgets/request_card.dart';

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
    // استخدام addPostFrameCallback لضمان أن الـ context متاح
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialRequests();
      _scrollController.addListener(_onScroll);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialRequests() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      await Provider.of<RequestProvider>(context, listen: false).fetchInitialRequests(
        userType: user.userType,
        userId: user.id,
        professionName: user.professionName,
        primaryCity: user.primaryCity,
      );
    }
  }

  void _onScroll() {
    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    // التحقق من الوصول إلى 80% من نهاية القائمة لجلب المزيد
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
        !requestProvider.isLoadingMore &&
        requestProvider.hasMore) {
      
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        requestProvider.fetchMoreRequests(
          userType: user.userType,
          userId: user.id,
          professionName: user.professionName,
          primaryCity: user.primaryCity,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.requests),
      ),
      body: Consumer<RequestProvider>(
        builder: (context, requestProvider, child) {
          if (requestProvider.isLoading && requestProvider.requests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (requestProvider.requests.isEmpty) {
            return Center(
              child: RefreshIndicator(
                onRefresh: _loadInitialRequests,
                child: ListView(
                  children: const [
                    SizedBox(height: 150),
                    Center(
                      child: Text(
                        AppStrings.noRequestsFound,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadInitialRequests,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: requestProvider.requests.length + (requestProvider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // إذا وصلنا لآخر عنصر وهناك المزيد، نعرض مؤشر تحميل
                if (index == requestProvider.requests.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final request = requestProvider.requests[index];
                return RequestCard(request: request);
              },
            ),
          );
        },
      ),
    );
  }
}
