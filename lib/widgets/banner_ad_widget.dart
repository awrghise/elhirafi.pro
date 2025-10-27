import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_colors.dart';

class BannerAdWidget extends StatefulWidget {
  final String? screenName;
  
  const BannerAdWidget({super.key, this.screenName});

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
    // Each screen gets its own banner ad instance for more impressions
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: _getAdUnitId(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('BannerAd loaded for screen: ${widget.screenName ?? "unknown"}');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load for screen ${widget.screenName ?? "unknown"}: $error');
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    );

    _bannerAd?.load();
  }

  String _getAdUnitId() {
    // Test ID - Replace with your actual AdMob ID in production
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
