import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages all ad logic.
/// Uses TEST IDs by default — replace with real IDs before releasing.
/// Real IDs: create an AdMob account at admob.google.com
class AdService {
  AdService._();

  // ── Ad Unit IDs ────────────────────────────────────────────────────────────
  // TODO: Replace these with your real AdMob unit IDs before release.

  static String get _bannerUnitId {
    if (Platform.isIOS) {
      // Real iOS banner ID from AdMob console
      return 'ca-app-pub-3940256099942544/2934735716'; // TEST ID
    }
    return 'ca-app-pub-3940256099942544/6300978111'; // TEST ID (Android)
  }

  // ── Initialization ─────────────────────────────────────────────────────────

  static Future<void> initialize() => MobileAds.instance.initialize();

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
