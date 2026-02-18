import 'package:flutter_test/flutter_test.dart';
import 'package:roman_converter/features/converter/converter_service.dart';

void main() {
  group('RomanConverter', () {
    test('convierte romano valido a entero', () {
      expect(RomanConverter.romanToInt('I'), 1);
      expect(RomanConverter.romanToInt('IV'), 4);
      expect(RomanConverter.romanToInt('IX'), 9);
      expect(RomanConverter.romanToInt('MMMCMXCIX'), 3999);
    });

    test('convierte entero valido a romano', () {
      expect(RomanConverter.intToRoman(1), 'I');
      expect(RomanConverter.intToRoman(4), 'IV');
      expect(RomanConverter.intToRoman(9), 'IX');
      expect(RomanConverter.intToRoman(3999), 'MMMCMXCIX');
    });

    test('lanza error en rango invalido', () {
      expect(() => RomanConverter.intToRoman(0), throwsFormatException);
      expect(() => RomanConverter.intToRoman(4000), throwsFormatException);
    });

    test('lanza error en formato no canonico', () {
      expect(() => RomanConverter.romanToInt('IIII'), throwsFormatException);
      expect(() => RomanConverter.romanToInt('VX'), throwsFormatException);
    });
  });
}
