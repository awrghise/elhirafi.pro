import 'package:flutter/material.dart';
import 'dart:math';

/// ويدجت لعرض خلفية مزخرفة بنمط متكرر من الأيقونات.
/// يتم عرض الأيقونات بشكل خفيف وشفاف.
class DecorativeBackground extends StatelessWidget {
  const DecorativeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة من الأيقونات المتعلقة بالحرف والصناعة
    const List<IconData> patternIcons = [
      Icons.construction,
      Icons.handyman,
      Icons.format_paint,
      Icons.hardware,
      Icons.build_circle_outlined,
      Icons.plumbing,
      Icons.lightbulb_outline,
      Icons.carpenter_outlined,
    ];

    // استخدام IgnorePointer لمنع أي تفاعل مع الخلفية
    return IgnorePointer(
      ignoring: true,
      child: Container(
        color: Colors.transparent, // الخلفية نفسها شفافة
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, // عدد الأيقونات في العرض
            mainAxisSpacing: 20.0,
            crossAxisSpacing: 20.0,
          ),
          itemBuilder: (context, index) {
            // اختيار أيقونة عشوائية من القائمة في كل مرة
            final icon = patternIcons[Random().nextInt(patternIcons.length)];
            return Icon(
              icon,
              // استخدام لون رمادي فاتح جداً مع شفافية عالية
              color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.05),
              size: 40.0,
            );
          },
        ),
      ),
    );
  }
}
