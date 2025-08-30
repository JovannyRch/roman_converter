import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const RomanApp());

class RomanApp extends StatelessWidget {
  const RomanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4A90E2), // azul elegante
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Conversor Romano ⇄ Arábigo',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        brightness: Brightness.dark,
      ).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surfaceContainerHighest.withOpacity(0.25),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: scheme.primary, width: 1.6),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: scheme.surfaceContainerHighest.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      home: const _Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _Home extends StatefulWidget {
  const _Home({super.key});
  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [const ConvertScreen(), const StepByStepScreen()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor Romano ⇄ Arábigo'),
        centerTitle: true,
      ),
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'Conversión',
          ),
          NavigationDestination(
            icon: Icon(Icons.stacked_line_chart),
            label: 'Paso a paso',
          ),
        ],
      ),
    );
  }
}

enum Direction { romanToArabic, arabicToRoman }

class ConvertScreen extends StatefulWidget {
  const ConvertScreen({super.key});

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  Direction dir = Direction.romanToArabic;
  final controller = TextEditingController();
  String? output;
  String? error;

  @override
  void initState() {
    super.initState();
    controller.addListener(_recompute);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _recompute() {
    final text = controller.text.trim();
    setState(() {
      if (text.isEmpty) {
        output = null;
        error = null;
        return;
      }
      try {
        if (dir == Direction.romanToArabic) {
          final value = RomanConverter.romanToInt(text);
          output = value.toString();
        } else {
          final n = int.tryParse(text);
          if (n == null)
            throw const FormatException('Introduce un número entero.');
          output = RomanConverter.intToRoman(n);
        }
        error = null;
      } catch (e) {
        output = null;
        error = e.toString().replaceFirst('FormatException: ', '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _DirectionSegmented(
          value: dir,
          onChanged: (d) {
            setState(() {
              dir = d;
              controller.clear();
              output = null;
              error = null;
            });
          },
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dir == Direction.romanToArabic
                      ? 'Romano → Arábigo'
                      : 'Arábigo → Romano',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType:
                      dir == Direction.romanToArabic
                          ? TextInputType.text
                          : const TextInputType.numberWithOptions(
                            signed: false,
                            decimal: false,
                          ),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText:
                        dir == Direction.romanToArabic
                            ? 'Ej.: MCMLXXXIV'
                            : 'Ej.: 1984',
                    prefixIcon: const Icon(Icons.input),
                  ),
                ),
                const SizedBox(height: 12),
                if (output != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SelectableText(
                            output!,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Copiar',
                          onPressed: () {
                            final data = ClipboardData(text: output!);
                            Clipboard.setData(data);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Resultado copiado.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_outlined),
                        ),
                      ],
                    ),
                  ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(error!, style: TextStyle(color: scheme.error)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Consejos', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _TipsCard(dir: dir),
      ],
    );
  }
}

class StepByStepScreen extends StatefulWidget {
  const StepByStepScreen({super.key});
  @override
  State<StepByStepScreen> createState() => _StepByStepScreenState();
}

class _StepByStepScreenState extends State<StepByStepScreen> {
  Direction dir = Direction.romanToArabic;
  final controller = TextEditingController();
  List<StepItem> steps = const [];
  String? error;

  void _buildSteps() {
    final text = controller.text.trim();
    setState(() {
      error = null;
      steps = const [];
      if (text.isEmpty) return;
      try {
        if (dir == Direction.romanToArabic) {
          steps = RomanConverter.explainRomanToInt(text);
        } else {
          final n = int.tryParse(text);
          if (n == null)
            throw const FormatException('Introduce un número entero.');
          steps = RomanConverter.explainIntToRoman(n);
        }
      } catch (e) {
        error = e.toString().replaceFirst('FormatException: ', '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: _DirectionSegmented(
            value: dir,
            onChanged: (d) {
              setState(() {
                dir = d;
                controller.clear();
                steps = const [];
                error = null;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  keyboardType:
                      dir == Direction.romanToArabic
                          ? TextInputType.text
                          : const TextInputType.numberWithOptions(),
                  decoration: InputDecoration(
                    hintText:
                        dir == Direction.romanToArabic
                            ? 'Ej.: XLII'
                            : 'Ej.: 42',
                    prefixIcon: const Icon(Icons.calculate_outlined),
                  ),
                  onSubmitted: (_) => _buildSteps(),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _buildSteps,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Ver pasos'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child:
              steps.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: steps.length,
                    itemBuilder: (context, i) {
                      final s = steps[i];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paso ${i + 1}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                s.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (s.detail != null) ...[
                                const SizedBox(height: 8),
                                Text(s.detail!),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book_outlined, size: 48),
          const SizedBox(height: 8),
          Text(
            'Ingresa un valor y toca "Ver pasos".',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _DirectionSegmented extends StatelessWidget {
  final Direction value;
  final ValueChanged<Direction> onChanged;
  const _DirectionSegmented({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Direction>(
      segments: const [
        ButtonSegment(
          value: Direction.romanToArabic,
          icon: Icon(Icons.arrow_right_alt),
          label: Text('Romano → Arábigo'),
        ),
        ButtonSegment(
          value: Direction.arabicToRoman,
          icon: Icon(Icons.arrow_left),
          label: Text('Arábigo → Romano'),
        ),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
      showSelectedIcon: false,
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  final Direction dir;
  const _TipsCard({required this.dir});
  @override
  Widget build(BuildContext context) {
    final tips =
        dir == Direction.romanToArabic
            ? const [
              'Solo se usan letras: I, V, X, L, C, D, M.',
              'No repitas V, L, D. I, X, C y M pueden repetirse hasta 3 veces.',
              'Usa notación sustractiva: IV=4, IX=9, XL=40, XC=90, CD=400, CM=900.',
            ]
            : const [
              'Rango recomendado: 1 a 3999 (usa barras para miles mayores, no incluido).',
              'Elige el símbolo más grande posible en cada paso: M(1000), CM(900), D(500), …',
            ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Guía rápida', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...tips.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [const Text('• '), Expanded(child: Text(t))],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modelo para pasos explicativos
class StepItem {
  final String title;
  final String? detail;
  const StepItem(this.title, [this.detail]);
}

/// Lógica de conversión y explicación
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

  /// Valida un número romano "clásico" (1..3999)
  static void _validateRoman(String s) {
    if (s.isEmpty) throw const FormatException('Ingresa un número romano.');
    final upper = s.toUpperCase();
    if (!RegExp(r'^[IVXLCDM]+$').hasMatch(upper)) {
      throw const FormatException('Solo caracteres I,V,X,L,C,D,M.');
    }
    // Regla de repeticiones y sustracciones válidas (simple, suficiente para 1..3999)
    // No más de 3 repeticiones de I,X,C,M; no repitas V,L,D.
    if (RegExp(r'(I{4}|X{4}|C{4}|M{4})').hasMatch(upper)) {
      throw const FormatException('Demasiadas repeticiones seguidas.');
    }
    if (RegExp(r'(VV|LL|DD)').hasMatch(upper)) {
      throw const FormatException('V, L y D no se repiten.');
    }
    // Sustracciones válidas
    if (RegExp(r'IL|IC|ID|IM|XD|XM|VX|LC|LD|LM|DM').hasMatch(upper)) {
      throw const FormatException('Notación sustractiva inválida.');
    }
  }

  /// Romano → Int
  static int romanToInt(String input) {
    _validateRoman(input);
    final s = input.toUpperCase();
    int total = 0;
    for (int i = 0; i < s.length; i++) {
      final v = _romanMap[s[i]]!;
      if (i + 1 < s.length) {
        final v2 = _romanMap[s[i + 1]]!;
        if (v < v2) {
          total += v2 - v;
          i++; // saltar par
          continue;
        }
      }
      total += v;
    }
    // Validar reconstruyendo
    final rebuilt = intToRoman(total);
    if (rebuilt != s) {
      throw const FormatException('Formato romano no canónico.');
    }
    return total;
  }

  /// Int → Romano (1..3999)
  static String intToRoman(int n) {
    if (n <= 0 || n >= 4000) {
      throw const FormatException('Rango permitido: 1 a 3999.');
    }
    var x = n;
    final buffer = StringBuffer();
    for (final e in _romanPairs) {
      while (x >= e.value) {
        buffer.write(e.key);
        x -= e.value;
      }
    }
    return buffer.toString();
  }

  /// Pasos: Romano → Int
  static List<StepItem> explainRomanToInt(String input) {
    _validateRoman(input);
    final s = input.toUpperCase();
    final steps = <StepItem>[];
    int total = 0;
    int i = 0;
    while (i < s.length) {
      final cur = _romanMap[s[i]]!;
      if (i + 1 < s.length) {
        final next = _romanMap[s[i + 1]]!;
        if (cur < next) {
          final delta = next - cur;
          total += delta;
          steps.add(
            StepItem(
              'Sustracción: ${s[i]}${s[i + 1]} = $delta',
              'Porque ${_nameOf(s[i])} ($cur) < ${_nameOf(s[i + 1])} ($next). Total: $total',
            ),
          );
          i += 2;
          continue;
        }
      }
      total += cur;
      steps.add(StepItem('Suma: ${s[i]} = $cur', 'Total: $total'));
      i++;
    }
    steps.add(StepItem('Resultado final', '$s = $total'));
    return steps;
  }

  /// Pasos: Int → Romano
  static List<StepItem> explainIntToRoman(int n) {
    if (n <= 0 || n >= 4000) {
      throw const FormatException('Rango permitido: 1 a 3999.');
    }
    var x = n;
    final steps = <StepItem>[];
    final out = StringBuffer();
    for (final e in _romanPairs) {
      int count = 0;
      while (x >= e.value) {
        out.write(e.key);
        x -= e.value;
        count++;
      }
      if (count > 0) {
        steps.add(
          StepItem(
            'Toma ${e.key} × $count',
            'Resta ${e.value} × $count = ${e.value * count}; restante: $x; acumulado: ${out.toString()}',
          ),
        );
      }
      if (x == 0) break;
    }
    steps.add(StepItem('Resultado final', '$n = ${out.toString()}'));
    return steps;
  }

  static String _nameOf(String r) {
    switch (r) {
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
    }
    return r;
  }
}
