import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/converter/converter_controller.dart';
import '../features/history/history_repository.dart';
import '../features/home/home_screen.dart';
import '../services/ad_service.dart';

class RomanApp extends StatelessWidget {
  const RomanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roma Flash',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.light(),
      home: HomeScreen(
        controller: ConverterController(
          historyRepository: LocalHistoryRepository(),
        ),
        onLearnOpened: () => AdService().registerLearnOpen(),
      ),
    );
  }
}
