import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية
  static const Color primaryColor = Color(0xFF2E7D32); // أخضر داكن (يرمز للعمل والحرفة)
  static const Color primaryLightColor = Color(0xFF4CAF50); // أخضر فاتح
  static const Color primaryDarkColor = Color(0xFF1B5E20); // أخضر أغمق
  
  // الألوان الثانوية
  static const Color secondaryColor = Color(0xFFFF9800); // برتقالي (يرمز للنشاط والحيوية)
  static const Color secondaryLightColor = Color(0xFFFFB74D);
  static const Color secondaryDarkColor = Color(0xFFE65100);
  static const Color accentColor = secondaryColor; // Accent color
  
  // ألوان الخلفية
  static const Color backgroundColor = Color(0xFFF5F5F5); // رمادي فاتح جداً
  static const Color surfaceColor = Color(0xFFFFFFFF); // أبيض
  static const Color cardBackgroundColor = Color(0xFFFAFAFA); // رمادي فاتح للبطاقات
  
  // ألوان النصوص
  static const Color textPrimaryColor = Color(0xFF212121); // أسود داكن
  static const Color textSecondaryColor = Color(0xFF757575); // رمادي متوسط
  static const Color textHintColor = Color(0xFFBDBDBD); // رمادي فاتح
  static const Color textOnPrimaryColor = Color(0xFFFFFFFF); // أبيض على الأساسي
  
  // ألوان الحالة
  static const Color successColor = Color(0xFF4CAF50); // أخضر للنجاح
  static const Color warningColor = Color(0xFFFF9800); // برتقالي للتحذير
  static const Color errorColor = Color(0xFFF44336); // أحمر للخطأ
  static const Color infoColor = Color(0xFF2196F3); // أزرق للمعلومات
  
  // ألوان خاصة بالتطبيق
  static const Color microphoneButtonColor = Color(0xFF4CAF50); // أخضر للميكروفون
  static const Color audioWaveColor = Color(0xFF81C784); // أخضر فاتح لموجات الصوت
  static const Color availableStatusColor = Color(0xFF4CAF50); // أخضر للحالة المتاحة
  static const Color busyStatusColor = Color(0xFFFF5722); // أحمر برتقالي للحالة المشغولة
  static const Color offlineStatusColor = Color(0xFF9E9E9E); // رمادي للحالة غير متصل
  
  // ألوان الحدود والفواصل
  static const Color borderColor = Color(0xFFE0E0E0); // رمادي فاتح للحدود
  static const Color dividerColor = Color(0xFFBDBDBD); // رمادي للفواصل
  
  // ألوان الظلال
  static const Color shadowColor = Color(0x1A000000); // ظل خفيف
  static const Color shadowDarkColor = Color(0x33000000); // ظل أغمق
  
  // ألوان إضافية
  static const Color textFieldFillColor = Color(0xFFF5F5F5); // لون خلفية حقول النص
  
  // MaterialColor for ThemeData
  static const MaterialColor primaryMaterialColor = MaterialColor(
    0xFF2E7D32,
    <int, Color>{
      50: Color(0xFFE8F5E9),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: Color(0xFF2E7D32),
      600: Color(0xFF43A047),
      700: Color(0xFF388E3C),
      800: Color(0xFF2E7D32),
      900: Color(0xFF1B5E20),
    },
  );

  // Aliases (أسماء مستعارة) للتوافق مع الكود القديم وحل الأخطاء
  static const Color primary = primaryColor;
  static const Color primaryLight = primaryLightColor;
  static const Color primaryDark = primaryDarkColor;
  static const Color secondary = secondaryColor;
  static const Color secondaryLight = secondaryLightColor;
  static const Color secondaryDark = secondaryDarkColor;
  static const Color background = backgroundColor;
  static const Color surface = surfaceColor;
  static const Color cardBackground = cardBackgroundColor;
  static const Color textPrimary = textPrimaryColor;
  static const Color textSecondary = textSecondaryColor;
  static const Color textHint = textHintColor;
  static const Color textOnPrimary = textOnPrimaryColor;
  static const Color success = successColor;
  static const Color warning = warningColor;
  static const Color error = errorColor;
  static const Color info = infoColor;
  static const Color microphoneButton = microphoneButtonColor;
  static const Color audioWave = audioWaveColor;
  static const Color availableStatus = availableStatusColor;
  static const Color busyStatus = busyStatusColor;
  static const Color offlineStatus = offlineStatusColor;
  static const Color border = borderColor;
  static const Color divider = dividerColor;
  static const Color shadow = shadowColor;
  static const Color shadowDark = shadowDarkColor;
}
