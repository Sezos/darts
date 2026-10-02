import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages all ad logic.
class AdService {
  AdService._();

  // ── Ad Unit IDs ────────────────────────────────────────────────────────────
  // Debug builds always use Google's test units: clicking real ads while
  // developing is an AdMob policy violation.

  static String get _bannerUnitId {
    if (kDebugMode) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/2934735716' // TEST (iOS)
          : 'ca-app-pub-3940256099942544/6300978111'; // TEST (Android)
    }
    if (Platform.isIOS) {
      return 'ca-app-pub-3416970123149038/9771487696'; // Дарцны оноо · Home banner
    }
    // TODO: no Android app in AdMob yet; create one and put its banner ID here.
    return 'ca-app-pub-3940256099942544/6300978111'; // TEST (Android)
  }

  // ── Initialization ─────────────────────────────────────────────────────────

  static bool _ready = false;
  static bool get isReady => _ready;

  /// Safe to call when AdMob isn't set up: failure leaves ads switched off.
  static Future<void> initialize() async {
    if (!(Platform.isIOS || Platform.isAndroid)) return;
    try {
      await MobileAds.instance.initialize();
      _ready = true;
    } catch (e) {
      debugPrint('AdService: initialize failed: $e');
    }
  }

  // ── Banner ─────────────────────────────────────────────────────────────────

  static Future<BannerAd?> loadBanner({
    required AdSize size,
    required Function(BannerAd) onLoaded,
  }) async {
    BannerAd? ad;
    ad = BannerAd(
      adUnitId: _bannerUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onLoaded(ad as BannerAd),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    await ad.load();
    return ad;
  }
}

// ── Banner widget ──────────────────────────────────────────────────────────────

/// A non-intrusive banner that sits at the bottom of a screen.
/// Only renders once loaded — no layout jump.
class HomeBannerAd extends StatefulWidget {
  const HomeBannerAd({super.key});

  @override
  State<HomeBannerAd> createState() => _HomeBannerAdState();
}

class _HomeBannerAdState extends State<HomeBannerAd> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (!AdService.isReady) return;
    AdService.loadBanner(
      size: AdSize.banner,
      onLoaded: (ad) {
        if (mounted) {
          setState(() {
            _ad = ad;
            _loaded = true;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
