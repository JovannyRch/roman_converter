import 'package:flutter_test/flutter_test.dart';
import 'package:roman_converter/core/models/conversion_entry.dart';
import 'package:roman_converter/features/converter/converter_service.dart';
import 'package:roman_converter/features/history/history_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalHistoryRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = LocalHistoryRepository();
  });

  test('guarda y carga conversiones', () async {
    final now = DateTime.now();
    final entry = ConversionEntry(
      id: '1',
      input: 'X',
      output: '10',
      direction: Direction.romanToArabic,
      timestamp: now,
      isFavorite: false,
    );

    await repository.add(entry);
    final all = await repository.loadAll();

    expect(all.length, 1);
    expect(all.first.input, 'X');
  });

  test('deduplica duplicado consecutivo', () async {
    final now = DateTime.now();
    final first = ConversionEntry(
      id: '1',
      input: 'X',
      output: '10',
      direction: Direction.romanToArabic,
      timestamp: now,
      isFavorite: false,
    );

    final second = ConversionEntry(
      id: '2',
      input: 'X',
      output: '10',
      direction: Direction.romanToArabic,
      timestamp: now.add(const Duration(seconds: 1)),
      isFavorite: false,
    );

    await repository.add(first);
    await repository.add(second);
    final all = await repository.loadAll();

    expect(all.length, 1);
  });

  test('toggle favorite cambia estado', () async {
    final entry = ConversionEntry(
      id: '1',
      input: '10',
      output: 'X',
      direction: Direction.arabicToRoman,
      timestamp: DateTime.now(),
      isFavorite: false,
    );

    await repository.add(entry);
    await repository.toggleFavorite('1');

    final all = await repository.loadAll();
    expect(all.first.isFavorite, true);
  });
}
