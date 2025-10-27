# دليل البناء - الصانع الحرفي

## المتطلبات الأساسية

### 1. تثبيت Flutter
```bash
# تحقق من تثبيت Flutter
flutter --version

# يجب أن يكون الإصدار 3.16.5 أو أحدث
```

### 2. تثبيت Android SDK
```bash
# تحقق من تثبيت Android SDK
flutter doctor

# يجب أن تكون جميع العناصر ✓
```

### 3. تثبيت التبعيات
```bash
cd /path/to/project
flutter pub get
```

## الإعداد قبل البناء

### 1. إعداد Firebase

#### الطريقة الأولى: باستخدام FlutterFire CLI (موصى بها)
```bash
# تثبيت FlutterFire CLI
dart pub global activate flutterfire_cli

# تكوين Firebase
flutterfire configure

# اختر المشروع من Firebase Console
# سيتم إنشاء lib/firebase_options.dart تلقائياً
```

#### الطريقة الثانية: يدوياً
1. افتح [Firebase Console](https://console.firebase.google.com)
2. اختر مشروعك أو أنشئ مشروع جديد
3. أضف تطبيق Android:
   - Package name: `com.elsane3.app`
   - App nickname: `الصانع الحرفي`
4. حمّل ملف `google-services.json`
5. ضعه في: `android/app/google-services.json`

### 2. إعداد AdMob

#### الحصول على AdMob IDs:
1. افتح [AdMob Console](https://apps.admob.com)
2. أنشئ تطبيق جديد أو اختر تطبيق موجود
3. أنشئ Ad Units:
   - **Banner Ad** (للشاشات)
   - **Interstitial Ad** (للخروج)
   - **Rewarded Ad** (للمميزات الإضافية)

#### تحديث المعرفات:

**في `android/app/src/main/AndroidManifest.xml`:**
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
```

**في `lib/services/ads_service.dart`:**
```dart
// غيّر هذا السطر
static const bool _isTestMode = false; // كان true

// غيّر Ad Unit IDs
static const String _bannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';
static const String _interstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/WWWWWWWWWW';
static const String _rewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/VVVVVVVVVV';
```

### 3. إعداد التوقيع (للإصدار النهائي)

#### إنشاء Keystore:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

#### إنشاء `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>/upload-keystore.jks
```

#### تحديث `android/app/build.gradle`:
```gradle
// أضف هذا قبل android {
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## البناء

### 1. بناء APK للاختبار (Debug)
```bash
flutter build apk --debug

# الملف الناتج:
# build/app/outputs/flutter-apk/app-debug.apk
```

### 2. بناء APK للإصدار (Release)
```bash
flutter build apk --release

# الملف الناتج:
# build/app/outputs/flutter-apk/app-release.apk
```

### 3. بناء App Bundle للنشر على Play Store
```bash
flutter build appbundle --release

# الملف الناتج:
# build/app/outputs/bundle/release/app-release.aab
```

### 4. بناء APK لكل معمارية (لتقليل الحجم)
```bash
flutter build apk --split-per-abi --release

# الملفات الناتجة:
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

## الاختبار

### 1. تشغيل على المحاكي
```bash
flutter run
```

### 2. تشغيل على جهاز حقيقي
```bash
# تأكد من تفعيل USB Debugging
flutter devices

# تشغيل على جهاز محدد
flutter run -d <device-id>
```

### 3. اختبار APK
```bash
# تثبيت APK على الجهاز
adb install build/app/outputs/flutter-apk/app-release.apk

# أو
flutter install
```

## التحقق من الجودة

### 1. تشغيل flutter analyze
```bash
flutter analyze

# يجب ألا يكون هناك errors
# warnings و info مقبولة
```

### 2. تشغيل الاختبارات
```bash
flutter test
```

### 3. فحص الأداء
```bash
flutter run --profile
```

## حل المشاكل الشائعة

### مشكلة: "Execution failed for task ':app:processReleaseGoogleServices'"
**الحل:**
- تأكد من أن `google-services.json` موجود في `android/app/`
- تأكد من أن package name في `google-services.json` هو `com.elsane3.app`

### مشكلة: "Gradle build failed"
**الحل:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### مشكلة: "SDK location not found"
**الحل:**
```bash
# أنشئ ملف android/local.properties
echo "sdk.dir=/path/to/Android/sdk" > android/local.properties
```

### مشكلة: "Ads not showing"
**الحل:**
- تأكد من تغيير `_isTestMode` إلى `false`
- تأكد من إضافة Ad Unit IDs الحقيقية
- انتظر 24 ساعة بعد إنشاء Ad Units في AdMob

## قائمة التحقق قبل النشر

- [ ] تم تحديث Firebase Config
- [ ] تم تحديث AdMob IDs
- [ ] تم إنشاء Keystore للتوقيع
- [ ] تم اختبار التطبيق على أجهزة حقيقية
- [ ] تم فحص جميع الشاشات والميزات
- [ ] تم اختبار الإعلانات
- [ ] تم اختبار الرسائل الصوتية
- [ ] تم اختبار نظام الطلبات
- [ ] تم اختبار المحادثات
- [ ] تم اختبار متجر الموردين
- [ ] `flutter analyze` بدون errors
- [ ] تم تحديث رقم الإصدار في `pubspec.yaml`

## معلومات إضافية

### حجم APK المتوقع:
- **Debug**: ~50-60 MB
- **Release**: ~25-35 MB
- **Split per ABI**: ~15-20 MB لكل معمارية

### وقت البناء المتوقع:
- **أول بناء**: 5-10 دقائق
- **بناء متكرر**: 1-3 دقائق

### متطلبات النظام:
- **RAM**: 8 GB أو أكثر
- **Storage**: 10 GB مساحة حرة
- **Internet**: مطلوب لتحميل التبعيات

---

**ملاحظة**: إذا واجهت أي مشاكل، راجع `KNOWN_ISSUES.md` أو `CHANGELOG.md`

