import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// كلاس مركزي لإدارة جميع خدمات إعلانات Google AdMob.
class AdService {
  // --- معرفات الوحدات الإعلانية الاختبارية ---
  static final String bannerTestUnitId = Platform.isAndroid 
      ? 'ca-app-pub-3940256099942544/6300978111' 
      : 'ca-app-pub-3940256099942544/2934735716';

  static final String interstitialTestUnitId = Platform.isAndroid 
      ? 'ca-app-pub-3940256099942544/1033173712' 
      : 'ca-app-pub-3940256099942544/4411468910';

  // --- متغيرات الإعلان البيني ---
  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialReady = false;
  
  // --- بداية التعديل: إضافة الحارس لمنع تكرار الإعلان ---
  /// هذا المتغير يضمن عرض الإعلان البيني مرة واحدة فقط في كل جلسة.
  static bool _interstitialAdShownInSession = false;
  // --- نهاية التعديل ---

  static const int maxFailedLoadAttempts = 3;
  static int _interstitialLoadAttempts = 0;

  /// تهيئة حزمة إعلانات جوجل عند بدء تشغيل التطبيق.
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await _loadInterstitialAd();
  }

  /// تحميل إعلان بيني بشكل مسبق.
  static Future<void> _loadInterstitialAd() async {
    if (_interstitialLoadAttempts >= maxFailedLoadAttempts) return;

    await InterstitialAd.load(
      adUnitId: interstitialTestUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          _interstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          _interstitialLoadAttempts++;
          _interstitialAd = null;
          _isInterstitialReady = false;
        },
      ),
    );
  }

  /// **الدالة الحارسة:** تعرض الإعلان البيني عند الخروج (مرة واحدة فقط لكل جلسة).
  static void showInterstitialAdOnExit() {
    // 1. التحقق من الحارس: إذا تم عرض الإعلان بالفعل، اخرج فورًا.
    if (_interstitialAdShownInSession) {
      print("Ad guard: Interstitial ad has already been shown in this session.");
      return;
    }

    // 2. التحقق من الجاهزية: إذا لم يكن الإعلان جاهزًا، اخرج.
    if (!_isInterstitialReady || _interstitialAd == null) {
      print("Ad guard: Interstitial ad not ready yet.");
      _loadInterstitialAd(); // نحاول تحميله للمرة القادمة
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        // 3. تفعيل الحارس: بمجرد بدء عرض الإعلان، نرفع العلم.
        print("Ad guard: Showing ad and activating session guard.");
        _interstitialAdShownInSession = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitialAd(); // إعادة تحميل إعلان جديد لجلسة مستقبلية
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitialAd();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
    _isInterstitialReady = false;
  }
}
