# دليل النشر والتشغيل - الصانع الحرفي

## 📋 نظرة عامة

هذا الدليل يشرح كيفية إعداد ونشر تطبيق "الصانع الحرفي" بشكل كامل.

---

## 🔧 المتطلبات الأساسية

### 1. البرامج المطلوبة

- **Flutter SDK 3.16.5** أو أحدث
- **Android Studio** أو **VS Code**
- **Git**
- **Node.js** (لـ Firebase Functions)
- **Firebase CLI**: `npm install -g firebase-tools`

### 2. الحسابات المطلوبة

- حساب **Firebase** (مجاني للبداية)
- حساب **Google AdMob** (للإعلانات)
- حساب **GitHub** (اختياري للـ CI/CD)

---

## 🚀 خطوات الإعداد

### الخطوة 1: إعداد Firebase

#### 1.1 إنشاء مشروع Firebase

1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. انقر على "Add project" أو "إضافة مشروع"
3. أدخل اسم المشروع: `alsana-alharfiyin`
4. فعّل Google Analytics (اختياري)
5. انقر "Create project"

#### 1.2 إضافة تطبيق Android

1. في صفحة المشروع، انقر على أيقونة Android
2. أدخل اسم الحزمة: `com.elsane3.app`
3. أدخل اسم التطبيق: `الصانع الحرفي`
4. حمّل ملف `google-services.json`
5. ضع الملف في: `android/app/google-services.json`

#### 1.3 تفعيل الخدمات

في Firebase Console، فعّل الخدمات التالية:

**Authentication:**
- اذهب إلى Authentication > Sign-in method
- فعّل "Email/Password"
- فعّل "Phone" (اختياري)

**Firestore Database:**
- اذهب إلى Firestore Database
- انقر "Create database"
- اختر "Start in test mode" (ثم غيّر القواعد لاحقاً)
- اختر الموقع: `europe-west` (الأقرب للمغرب العربي)

**Storage:**
- اذهب إلى Storage
- انقر "Get started"
- اختر "Start in test mode"

**Analytics:**
- يتم تفعيله تلقائياً إذا اخترته عند إنشاء المشروع

**Crashlytics:**
- اذهب إلى Crashlytics
- انقر "Enable Crashlytics"

#### 1.4 قواعد الأمان (Security Rules)

**Firestore Rules** (`firestore.rules`):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Requests collection
    match /requests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         request.auth.token.userType == 'craftsman');
    }
    
    // Chats collection
    match /chats/{chatId} {
      allow read: if request.auth != null && 
        request.auth.uid in resource.data.participantIds;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        request.auth.uid in resource.data.participantIds;
        
      match /messages/{messageId} {
        allow read: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participantIds;
        allow create: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participantIds;
      }
    }
  }
}
```

**Storage Rules** (`storage.rules`):

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile pictures
    match /profiles/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Request audio files
    match /requests/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chat audio files
    match /chats/{chatId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

---

### الخطوة 2: إعداد AdMob

#### 2.1 إنشاء حساب AdMob

1. اذهب إلى [AdMob Console](https://apps.admob.com/)
2. سجّل الدخول بحساب Google
3. انقر "Get Started"

#### 2.2 إضافة التطبيق

1. انقر "Apps" من القائمة الجانبية
2. انقر "Add app"
3. اختر "Android"
4. أدخل اسم التطبيق: `الصانع الحرفي`
5. أدخل اسم الحزمة: `com.elsane3.app`

#### 2.3 إنشاء وحدات إعلانية

**Banner Ad:**
1. اذهب إلى "Ad units"
2. انقر "Add ad unit"
3. اختر "Banner"
4. أدخل الاسم: `Home Banner`
5. احفظ الـ Ad Unit ID

**Rewarded Ad:**
1. انقر "Add ad unit"
2. اختر "Rewarded"
3. أدخل الاسم: `Request Reward`
4. احفظ الـ Ad Unit ID

#### 2.4 تحديث الكود

افتح `lib/services/ads_service.dart` وحدّث:

```dart
// استبدل هذه القيم بقيمك من AdMob
static const String _bannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String _rewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
```

---

### الخطوة 3: نشر Cloud Functions

#### 3.1 تسجيل الدخول إلى Firebase CLI

```bash
firebase login
```

#### 3.2 ربط المشروع

```bash
cd alsana_alharfiyin
firebase use --add
# اختر مشروعك من القائمة
# أدخل alias: default
```

#### 3.3 تثبيت التبعيات

```bash
cd functions
npm install
```

#### 3.4 نشر Functions

```bash
firebase deploy --only functions
```

---

### الخطوة 4: تشغيل التطبيق

#### 4.1 تثبيت تبعيات Flutter

```bash
cd alsana_alharfiyin
flutter pub get
```

#### 4.2 تشغيل على المحاكي/الجهاز

```bash
flutter run
```

---

## 📦 البناء للإنتاج

### بناء APK

```bash
flutter build apk --release
```

الملف سيكون في: `build/app/outputs/flutter-apk/app-release.apk`

### بناء App Bundle (للنشر على Google Play)

```bash
flutter build appbundle --release
```

الملف سيكون في: `build/app/outputs/bundle/release/app-release.aab`

---

## 🔐 التوقيع (Signing)

### إنشاء Keystore

```bash
keytool -genkey -v -keystore ~/alsana-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias alsana
```

### إعداد ملف key.properties

أنشئ ملف `android/key.properties`:

```properties
storePassword=<كلمة المرور>
keyPassword=<كلمة المرور>
keyAlias=alsana
storeFile=<المسار الكامل للـ keystore>
```

**ملاحظة:** لا ترفع هذا الملف على Git!

---

## 🌐 GitHub Actions (CI/CD)

الملف `.github/workflows/main.yml` موجود بالفعل ويقوم بـ:

1. بناء APK تلقائياً عند كل Push
2. توقيع APK
3. رفع APK كـ Artifact

### إعداد Secrets

في GitHub Repository، اذهب إلى Settings > Secrets and variables > Actions:

1. `KEYSTORE_BASE64`: الـ keystore مشفر بـ base64
2. `KEYSTORE_PASSWORD`: كلمة مرور الـ keystore
3. `KEY_ALIAS`: اسم الـ alias
4. `KEY_PASSWORD`: كلمة مرور الـ key

---

## 💰 تقليل التكاليف

التطبيق مصمم لتقليل تكاليف Firebase:

### Firestore
- ✅ استخدام `get()` بدلاً من `snapshots()` حيثما أمكن
- ✅ Cache للبيانات المكررة
- ✅ حذف الطلبات القديمة (48 ساعة) تلقائياً
- ✅ استخدام Indexes للاستعلامات المعقدة

### Storage
- ✅ ضغط الملفات الصوتية (AAC-LC, 128kbps)
- ✅ حذف الملفات القديمة تلقائياً
- ✅ استخدام Cloud Functions لإدارة التخزين

### Authentication
- ✅ استخدام Email/Password (مجاني)
- ✅ تجنب Phone Auth (مكلف)

### Cloud Functions
- ✅ استخدام Functions فقط للعمليات الضرورية
- ✅ تحسين الكود لتقليل وقت التنفيذ

---

## 🐛 حل المشاكل الشائعة

### خطأ: "google-services.json not found"

**الحل:** تأكد من وضع الملف في `android/app/google-services.json`

### خطأ: "Execution failed for task ':app:processDebugGoogleServices'"

**الحل:** تأكد من أن اسم الحزمة في `google-services.json` يطابق `com.elsane3.app`

### خطأ: "MissingPluginException"

**الحل:**
```bash
flutter clean
flutter pub get
flutter run
```

### التطبيق يتوقف عند التشغيل

**الحل:** تحقق من Logcat:
```bash
flutter run --verbose
```

---

## 📊 المراقبة والتحليلات

### Firebase Console

راقب التطبيق من خلال:
- **Analytics**: تتبع المستخدمين والأحداث
- **Crashlytics**: تقارير الأخطاء
- **Performance**: أداء التطبيق
- **Usage**: استخدام Firestore و Storage

### AdMob Reports

راقب الإعلانات من:
- **Revenue**: الأرباح
- **Impressions**: مرات الظهور
- **eCPM**: الربح لكل 1000 ظهور

---

## 📞 الدعم

للمساعدة:
- راجع [Flutter Documentation](https://docs.flutter.dev/)
- راجع [Firebase Documentation](https://firebase.google.com/docs)
- راجع [AdMob Help](https://support.google.com/admob)

---

## ✅ قائمة التحقق النهائية

قبل النشر، تأكد من:

- [ ] تحديث `google-services.json`
- [ ] تحديث AdMob IDs
- [ ] نشر Cloud Functions
- [ ] تعيين Security Rules
- [ ] إنشاء Keystore للتوقيع
- [ ] اختبار التطبيق على أجهزة حقيقية
- [ ] مراجعة Privacy Policy
- [ ] تحضير Screenshots للمتجر
- [ ] كتابة وصف التطبيق

---

**تم إعداد هذا الدليل بواسطة Manus AI**
**آخر تحديث: أكتوبر 2024**

