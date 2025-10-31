import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../models/request_model.dart';
import 'settings_screen.dart';

// --- بداية التعديل 1: استيراد ويدجت إعلان البانر ---
import '../../widgets/banner_ad_widget.dart';
// --- نهاية التعديل 1 ---

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
        Provider.of<RequestProvider>(context, listen: false).fetchRequests(user.userType, user.uid);
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
        // --- بداية التعديل 2: تغيير هيكل body لإضافة البانر ---
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildRequestsList(context, RequestStatus.pending),
                  _buildRequestsList(context, RequestStatus.accepted),
                ],
              ),
            ),
            // العنصر الثاني: إعلان البانر الخاص بهذه الشاشة
            const BannerAdWidget(screenName: 'RequestsScreen'),
          ],
        ),
        // --- نهاية التعديل 2 ---
      ),
    );
  }

  Widget _buildRequestsList(BuildContext context, RequestStatus status) {
    final requestProvider = Provider.of<RequestProvider>(context);
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    if (requestProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final requests = requestProvider.requests
        .where((req) => req.status == status)
        .toList();

    if (requests.isEmpty) {
      return Center(child: Text('لا توجد طلبات ${status == RequestStatus.pending ? 'جديدة' : 'مقبولة'} حاليًا.'));
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(request.description),
            subtitle: Text('الحالة: ${request.status.name}'),
            trailing: (user?.userType == 'craftsman' && request.status == Request.pending)
                ? ElevatedButton(
                    onPressed: () {
                      requestProvider.acceptRequest(request.id, user!.uid, user.name);
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
