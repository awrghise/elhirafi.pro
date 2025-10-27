import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.aboutUs),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'الصانع الحرفي',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'من نحن',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '"الصانع الحرفي" هي منصة تقنية مبتكرة تهدف إلى ربط الحرفيين المهرة بأصحاب المشاريع والعملاء في جميع أنحاء العالم العربي.',
              style: TextStyle(
                fontSize: 16,
                height: 1.8,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'رؤيتنا',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'نسعى لأن نكون الجسر الذي يربط المهارات الحرفية التقليدية بالتكنولوجيا الحديثة، مما يسهل على الحرفيين إيجاد فرص عمل ويساعد العملاء في الوصول إلى أفضل الخدمات.',
              style: TextStyle(
                fontSize: 16,
                height: 1.8,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'مهمتنا',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'توفير منصة آمنة وسهلة الاستخدام تمكن الحرفيين من عرض مهاراتهم والعملاء من إيجاد الخدمات التي يحتاجونها بسرعة وكفاءة.',
              style: TextStyle(
                fontSize: 16,
                height: 1.8,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 32),
            _buildFeatureCard(
              icon: Icons.verified_user,
              title: 'موثوقية',
              description: 'نضمن جودة الخدمات المقدمة',
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              icon: Icons.speed,
              title: 'سرعة',
              description: 'تواصل فوري بين الحرفيين والعملاء',
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              icon: Icons.language,
              title: 'دعم اللهجات',
              description: 'نتحدث بلهجتك المحلية',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

