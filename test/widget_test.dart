import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roman_converter/features/converter/converter_controller.dart';
import 'package:roman_converter/features/home/home_screen.dart';

import 'test_helpers/in_memory_history_repository.dart';

void main() {
  testWidgets('home muestra conversion instantanea', (tester) async {
    final controller = ConverterController(
      historyRepository: InMemoryHistoryRepository(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          controller: controller,
          onLearnOpened: () {},
          showBottomBannerAd: false,
        ),
      ),
    );

    final input = find.byType(TextField);
    expect(input, findsOneWidget);

    await tester.enterText(input, 'X');
    await tester.pumpAndSettle();

    expect(find.text('Resultado'), findsOneWidget);
    expect(find.text('10'), findsWidgets);
  });
}
