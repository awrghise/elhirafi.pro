import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart'; // استيراد خدمة الإعلانات

/// ويدجت متخصص لعرض إعلان بانر قابل لإعادة الاستخدام.
/// يجمع بين أفضل الممارسات: دورة حياة مُدارة، تصميم مدمج، وتتبع الأداء.
class BannerAdWidget extends StatefulWidget {
  final String screenName; // لتتبع أداء الإعلان لكل شاشة

  const BannerAdWidget({super.key, required this.screenName});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      // استخدام المعرف المركزي من خدمة الإعلانات
      adUnitId: AdService.bannerTestUnitId, 
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('BannerAd loaded for screen: ${widget.screenName}');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load for screen ${widget.screenName}: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدام منطق الإخفاء الخاص بك لأنه يوفر تجربة أفضل
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink(); 
    }

    // استخدام تصميم الحاوية الجميل الذي أضفته
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
