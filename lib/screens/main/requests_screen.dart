import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../widgets/request_card.dart'; // <-- تم تصحيح المسار

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  @override
  void initState() {
    super.initState();
    // استخدام addPostFrameCallback لضمان أن الـ context متاح
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final UserModel? user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        // بدء الاستماع للطلبات
        Provider.of<RequestProvider>(context, listen: false).listenToRequests(
          userType: user.userType,
          userId: user.id,
          professionName: user.professionName,
          workCities: user.workCities,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.requests),
      ),
      body: Consumer<RequestProvider>(
        builder: (context, requestProvider, child) {
          if (requestProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (requestProvider.requests.isEmpty) {
            return const Center(
              child: Text(
                AppStrings.noRequestsFound,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshRequests,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: requestProvider.requests.length,
              itemBuilder: (context, index) {
                final request = requestProvider.requests[index];
                return RequestCard(request: request); // <-- تم التصحيح
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _refreshRequests() async {
    final UserModel? user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      Provider.of<RequestProvider>(context, listen: false).listenToRequests(
        userType: user.userType,
        userId: user.id,
        professionName: user.professionName,
        workCities: user.workCities,
      );
    }
  }
}
