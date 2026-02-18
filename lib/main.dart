import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'services/ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.initialize();
  AdService().preloadInterstitialAd();
  runApp(const RomanApp());
}
