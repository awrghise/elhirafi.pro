// lib/screens/content/terms_of_service_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.termsOfService),
        backgroundColor: AppColors.primaryColor,
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/terms_of_service.md'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'خطأ في تحميل شروط الاستخدام',
                style: TextStyle(color: Colors.red[700]),
              ),
            );
          }

          // --- هذا هو التعديل الوحيد المطلوب ---
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Markdown(
              data: snapshot.data ?? '',
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(
                  fontSize: 22, // تصغير حجم الخط
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
                h2: const TextStyle(
                  fontSize: 18, // تصغير حجم الخط
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
                p: const TextStyle(
                  fontSize: 14, // تصغير حجم الخط
                  height: 1.6,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ),
          );
          // --- نهاية التعديل ---
        },
      ),
    );
  }
}
