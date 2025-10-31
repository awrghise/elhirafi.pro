import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../models/request_model.dart';
import '../../models/user_model.dart';
import 'settings_screen.dart';
import '../../widgets/banner_ad_widget.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        // --- تصحيح: استخدام الدالة والخصائص الصحيحة ---
        Provider.of<RequestProvider>(context, listen: false).fetchInitialRequests(
          userType: user.userType,
          userId: user.id,
          professionName: user.profession,
          primaryCity: user.primaryWorkCity,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.requestsLabel),
          backgroundColor: AppColors.primaryColor,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {
                Share.share('تابع طلباتك بسهولة مع تطبيق الصانع الحرفي! [رابط التطبيق]');
              },
            ),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'الطلبات الجديدة'),
              Tab(text: 'الطلبات المقبولة'),
            ],
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  // --- تصحيح: تمرير الحالة كنص String ---
                  _buildRequestsList(context, 'pending'),
                  _buildRequestsList(context, 'accepted'),
                ],
              ),
            ),
            const BannerAdWidget(screenName: 'RequestsScreen'),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(BuildContext context, String status) {
    final requestProvider = Provider.of<RequestProvider>(context);
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    if (requestProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final requests = requestProvider.requests.where((req) => req.status == status).toList();

    if (requests.isEmpty) {
      // --- تصحيح: استخدام نص String للمقارنة ---
      return Center(child: Text('لا توجد طلبات ${status == 'pending' ? 'جديدة' : 'مقبولة'} حاليًا.'));
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            // --- تصحيح: استخدام 'details' بدلاً من 'description' ---
            title: Text(request.details ?? 'لا توجد تفاصيل'),
            subtitle: Text('الحالة: ${request.status}'),
            // --- تصحيح: استخدام نص String للمقارنة ---
            trailing: (user?.userType == 'حرفي' && request.status == 'pending')
                ? ElevatedButton(
                    onPressed: () {
                      if (user != null && request.id != null) {
                        // --- تصحيح: استخدام الدالة والخصائص الصحيحة ---
                        requestProvider.acceptExistingRequest(request.id!, user);
                      }
                    },
                    child: const Text('قبول'),
                  )
                : null,
          ),
        );
      },
    );
  }
}
