class ConversionStep {
  final String title;
  final String? detail;

  const ConversionStep(this.title, [this.detail]);
}

enum Direction { romanToArabic, arabicToRoman }

class RomanConverter {
  static const Map<String, int> _romanMap = {
    'I': 1,
    'V': 5,
    'X': 10,
    'L': 50,
    'C': 100,
    'D': 500,
    'M': 1000,
  };

  static const List<MapEntry<String, int>> _romanPairs = [
    MapEntry('M', 1000),
    MapEntry('CM', 900),
    MapEntry('D', 500),
    MapEntry('CD', 400),
    MapEntry('C', 100),
    MapEntry('XC', 90),
    MapEntry('L', 50),
    MapEntry('XL', 40),
    MapEntry('X', 10),
    MapEntry('IX', 9),
    MapEntry('V', 5),
    MapEntry('IV', 4),
    MapEntry('I', 1),
  ];

  static void _validateRoman(String input) {
    if (input.isEmpty) {
      throw const FormatException('Ingresa un numero romano.');
    }

    final upper = input.toUpperCase();
    if (!RegExp(r'^[IVXLCDM]+$').hasMatch(upper)) {
      throw const FormatException('Solo caracteres I,V,X,L,C,D,M.');
    }

    if (RegExp(r'(I{4}|X{4}|C{4}|M{4})').hasMatch(upper)) {
      throw const FormatException('Demasiadas repeticiones seguidas.');
    }

    if (RegExp(r'(VV|LL|DD)').hasMatch(upper)) {
      throw const FormatException('V, L y D no se repiten.');
    }

    if (RegExp(r'IL|IC|ID|IM|XD|XM|VX|LC|LD|LM|DM').hasMatch(upper)) {
      throw const FormatException('Notacion sustractiva invalida.');
    }
  }

  static int romanToInt(String input) {
    _validateRoman(input);
    final normalized = input.toUpperCase();

    var total = 0;
    for (var i = 0; i < normalized.length; i++) {
      final current = _romanMap[normalized[i]]!;
      if (i + 1 < normalized.length) {
        final next = _romanMap[normalized[i + 1]]!;
        if (current < next) {
          total += next - current;
          i++;
          continue;
        }
      }
      total += current;
    }

    final rebuilt = intToRoman(total);
    if (rebuilt != normalized) {
      throw const FormatException('Formato romano no canonico.');
    }

    return total;
  }

  static String intToRoman(int value) {
    if (value <= 0 || value >= 4000) {
      throw const FormatException('Rango permitido: 1 a 3999.');
    }

    var remaining = value;
    final buffer = StringBuffer();

    for (final pair in _romanPairs) {
      while (remaining >= pair.value) {
        buffer.write(pair.key);
        remaining -= pair.value;
      }
    }

    return buffer.toString();
  }

  static List<ConversionStep> explainRomanToInt(String input) {
    _validateRoman(input);
    final normalized = input.toUpperCase();

    final steps = <ConversionStep>[];
    var total = 0;
    var i = 0;

    while (i < normalized.length) {
      final current = _romanMap[normalized[i]]!;
      if (i + 1 < normalized.length) {
        final next = _romanMap[normalized[i + 1]]!;
        if (current < next) {
          final delta = next - current;
          total += delta;
          steps.add(
            ConversionStep(
              'Sustraccion: ${normalized[i]}${normalized[i + 1]} = $delta',
              'Porque ${_nameOf(normalized[i])} ($current) < ${_nameOf(normalized[i + 1])} ($next). Total: $total',
            ),
          );
          i += 2;
          continue;
        }
      }

      total += current;
      steps.add(ConversionStep('Suma: ${normalized[i]} = $current', 'Total: $total'));
      i++;
    }

    steps.add(ConversionStep('Resultado final', '$normalized = $total'));
    return steps;
  }

  static List<ConversionStep> explainIntToRoman(int value) {
    if (value <= 0 || value >= 4000) {
      throw const FormatException('Rango permitido: 1 a 3999.');
    }

    var remaining = value;
    final output = StringBuffer();
    final steps = <ConversionStep>[];

    for (final pair in _romanPairs) {
      var count = 0;
      while (remaining >= pair.value) {
        output.write(pair.key);
        remaining -= pair.value;
        count++;
      }

      if (count > 0) {
        steps.add(
          ConversionStep(
            'Toma ${pair.key} x $count',
            'Resta ${pair.value} x $count = ${pair.value * count}; restante: $remaining; acumulado: ${output.toString()}',
          ),
        );
      }

      if (remaining == 0) {
        break;
      }
    }

    steps.add(ConversionStep('Resultado final', '$value = ${output.toString()}'));
    return steps;
  }

  static String _nameOf(String roman) {
    switch (roman) {
      case 'I':
        return 'I (1)';
      case 'V':
        return 'V (5)';
      case 'X':
        return 'X (10)';
      case 'L':
        return 'L (50)';
      case 'C':
        return 'C (100)';
      case 'D':
        return 'D (500)';
      case 'M':
        return 'M (1000)';
      default:
        return roman;
    }
  }
}
