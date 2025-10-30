import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/request_model.dart';
import '../../providers/request_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'settings_screen.dart'; // استيراد شاشة الإعدادات

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  @override
  void initState() {
    super.initState();
    // جلب الطلبات عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RequestProvider>(context, listen: false).fetchRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- بداية التعديل: إضافة AppBar مع أيقونات ---
      appBar: AppBar(
        title: const Text(AppStrings.incomingRequests),
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false, // لإخفاء سهم الرجوع
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Share.share('انضم إلى تطبيق الصانع الحرفي لتلقي طلبات عمل جديدة! [رابط التطبيق]');
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
      ),
      // --- نهاية التعديل ---
      body: Consumer<RequestProvider>(
        builder: (context, requestProvider, child) {
          if (requestProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (requestProvider.requests.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد طلبات واردة حاليًا.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => requestProvider.fetchRequests(),
            child: ListView.builder(
              itemCount: requestProvider.requests.length,
              itemBuilder: (context, index) {
                final RequestModel request = requestProvider.requests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      child: const Icon(Icons.work_outline, color: AppColors.primaryColor),
                    ),
                    title: Text(
                      request.description,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        'المدينة: ${request.city}\nالحالة: ${request.status}',
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: الانتقال إلى صفحة تفاصيل الطلب
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
