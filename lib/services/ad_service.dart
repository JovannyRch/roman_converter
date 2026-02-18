import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static const String _bannerAdUnitId =
      'ca-app-pub-4665787383933447/5456790166';
  static const String _interstitialAdUnitId =
      'ca-app-pub-4665787383933447/4143708492';

  InterstitialAd? _interstitialAd;
  bool _isInterstitialReady = false;
  int _learnOpenCount = 0;
  int interstitialEvery = 3;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  BannerAd createBannerAdForLearn() {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    );
  }

  void preloadInterstitialAd() {
    _loadInterstitialAd();
  }

  void registerLearnOpen() {
    _learnOpenCount++;
    if (_learnOpenCount % interstitialEvery == 0) {
      _showInterstitialAd();
    } else if (!_isInterstitialReady) {
      _loadInterstitialAd();
    }
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          ad.setImmersiveMode(true);
        },
        onAdFailedToLoad: (_) {
          _isInterstitialReady = false;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (!_isInterstitialReady || _interstitialAd == null) {
      _loadInterstitialAd();
      return;
    }

    final ad = _interstitialAd!;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isInterstitialReady = false;
        _interstitialAd = null;
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _isInterstitialReady = false;
        _interstitialAd = null;
        _loadInterstitialAd();
      },
    );

    ad.show();
    _interstitialAd = null;
    _isInterstitialReady = false;
  }
}
