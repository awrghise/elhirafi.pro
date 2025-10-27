# المشاكل المعروفة والحلول

## 📌 نظرة عامة

هذا الملف يوثق الأخطاء البرمجية المتبقية في المشروع وكيفية إصلاحها.

---

## ⚠️ أخطاء التحليل (Flutter Analyze)

عند تشغيل `flutter analyze`، ستظهر بعض الأخطاء والتحذيرات. معظمها **لا يمنع** بناء التطبيق.

### 1. أخطاء في ملفات الشاشات (Screens)

#### المشكلة: استخدام Stream.when() غير موجود

```
error • The method 'when' isn't defined for the type 'Stream'
```

**الحل:**
في `lib/screens/main/chats_screen.dart` و `lib/screens/chat/chat_detail_screen.dart`، استخدم `StreamBuilder` بدلاً من `.when()`:

```dart
// بدلاً من:
chatStream.when(...)

// استخدم:
StreamBuilder(
  stream: chatStream,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    if (!snapshot.hasData) {
      return Text('No data');
    }
    return YourWidget(data: snapshot.data);
  },
)
```

#### المشكلة: متغيرات غير معرفة (chatId, userId)

```
error • Undefined name 'chatId'
error • Undefined name 'userId'
```

**الحل:**
تأكد من تمرير هذه المتغيرات كـ parameters للـ Widget:

```dart
class ChatDetailScreen extends StatelessWidget {
  final String chatId;
  final String userId;
  
  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.userId,
  });
  
  // ...
}
```

### 2. نصوص مفقودة في AppStrings

بعض النصوص المستخدمة في الكود غير موجودة في `app_strings.dart`. تم إضافة معظمها، لكن إذا ظهرت أخطاء جديدة:

**الحل:**
أضف النصوص المفقودة في `lib/constants/app_strings.dart`:

```dart
static const String yourMissingString = 'النص بالعربية';
```

### 3. تحذيرات const

```
info • Use 'const' with the constructor to improve performance
```

**الحل:**
أضف `const` حيثما أمكن:

```dart
// بدلاً من:
Text('مرحباً')

// استخدم:
const Text('مرحباً')
```

**ملاحظة:** لا تستخدم `const` مع Widgets تحتوي على متغيرات ديناميكية.

### 4. استيرادات غير مستخدمة

```
warning • Unused import
```

**الحل:**
احذف الاستيرادات غير المستخدمة، أو شغّل:

```bash
dart fix --apply
```

---

## 🔧 أخطاء البناء (Build Errors)

### 1. خطأ: "Namespace not specified"

**الحل:**
تأكد من وجود `namespace` في `android/app/build.gradle`:

```gradle
android {
    namespace "com.elsane3.app"
    // ...
}
```

### 2. خطأ: "Minimum supported Gradle version is X.X"

**الحل:**
حدّث `android/gradle/wrapper/gradle-wrapper.properties`:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
```

### 3. خطأ: "google-services.json is missing"

**الحل:**
ضع ملف `google-services.json` الخاص بك في `android/app/`

---

## 🚀 أخطاء وقت التشغيل (Runtime Errors)

### 1. MissingPluginException

**السبب:** Plugins غير مثبتة بشكل صحيح

**الحل:**
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean
cd ..
flutter run
```

### 2. PlatformException: sign_in_failed

**السبب:** Firebase Authentication غير مُعد بشكل صحيح

**الحل:**
- تأكد من تفعيل Email/Password في Firebase Console
- تأكد من صحة `google-services.json`
- تأكد من إضافة SHA-1 fingerprint في Firebase Console

### 3. FirebaseException: permission-denied

**السبب:** Security Rules في Firestore/Storage تمنع الوصول

**الحل:**
راجع ملف `DEPLOYMENT.md` لقواعد الأمان الصحيحة

---

## 📱 مشاكل AdMob

### 1. الإعلانات لا تظهر

**الأسباب المحتملة:**
- استخدام Test IDs في الإنتاج
- التطبيق غير منشور على Play Store
- حساب AdMob غير مفعّل

**الحل:**
- استخدم Test IDs أثناء التطوير:
  ```dart
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  ```
- بعد النشر، استبدلها بـ IDs الحقيقية

### 2. خطأ: "Ad failed to load"

**الحل:**
- تحقق من اتصال الإنترنت
- انتظر بضع دقائق (الإعلانات تحتاج وقت للتحميل)
- تحقق من Logcat للتفاصيل

---

## 🔍 نصائح للتشخيص

### عرض Logs مفصلة

```bash
flutter run --verbose
```

### تشغيل Analyzer

```bash
flutter analyze
```

### تشغيل Tests

```bash
flutter test
```

### عرض Logcat (Android)

```bash
adb logcat | grep flutter
```

---

## ✅ الأولويات

الأخطاء مرتبة حسب الأهمية:

1. **حرجة (Critical)**: تمنع بناء التطبيق → يجب إصلاحها فوراً
2. **عالية (High)**: تسبب crashes → يجب إصلاحها قبل النشر
3. **متوسطة (Medium)**: تحذيرات وأخطاء تحليل → يُفضل إصلاحها
4. **منخفضة (Low)**: تحسينات الأداء → اختيارية

---

## 📝 ملاحظات مهمة

### حول الأخطاء المتبقية

- معظم الأخطاء الموجودة هي **تحذيرات** وليست أخطاء حرجة
- التطبيق **يمكن بناؤه وتشغيله** رغم وجود بعض التحذيرات
- الأخطاء الحرجة تم إصلاحها (user.id → user.uid، AuthProvider conflict، إلخ)

### التحسينات المستقبلية

يُنصح بـ:
- إعادة هيكلة ملفات الشاشات لاستخدام StreamBuilder بشكل صحيح
- إضافة Unit Tests
- إضافة Integration Tests
- تحسين Error Handling
- إضافة Offline Support

---

## 🆘 طلب المساعدة

إذا واجهت مشكلة غير مذكورة هنا:

1. تحقق من [Flutter Documentation](https://docs.flutter.dev/)
2. ابحث في [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
3. راجع [Firebase Documentation](https://firebase.google.com/docs)
4. تحقق من GitHub Issues للـ packages المستخدمة

---

**آخر تحديث: أكتوبر 2024**

