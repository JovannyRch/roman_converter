import 'package:flutter_test/flutter_test.dart';
import 'package:roman_converter/features/converter/converter_controller.dart';
import 'package:roman_converter/features/converter/converter_service.dart';
import 'test_helpers/in_memory_history_repository.dart';

void main() {
  late ConverterController controller;

  setUp(() {
    controller = ConverterController(historyRepository: InMemoryHistoryRepository());
  });

  tearDown(() {
    controller.dispose();
  });

  test('auto convierte romano a arabe', () {
    controller.onInputChanged('XIV');
    expect(controller.output, '14');
    expect(controller.error, isNull);
  });

  test('auto convierte arabe a romano', () {
    controller.setDirection(Direction.arabicToRoman);
    controller.onInputChanged('42');
    expect(controller.output, 'XLII');
    expect(controller.error, isNull);
  });

  test('maneja errores sin romper estado', () {
    controller.onInputChanged('INVALID');
    expect(controller.output, isNull);
    expect(controller.error, isNotNull);
  });

  test('swapDirection reutiliza output como nuevo input', () {
    controller.onInputChanged('10');
    expect(controller.error, isNotNull);

    controller.setDirection(Direction.arabicToRoman);
    controller.onInputChanged('10');
    expect(controller.output, 'X');

    controller.swapDirection();

    expect(controller.direction, Direction.romanToArabic);
    expect(controller.input, 'X');
    expect(controller.output, '10');
  });
}
