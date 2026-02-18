import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../widgets/ad_banner_widget.dart';
import '../converter/converter_service.dart';

class StepByStepScreen extends StatefulWidget {
  const StepByStepScreen({
    super.key,
    required this.initialDirection,
    required this.onShowed,
    this.initialInput,
  });

  final Direction initialDirection;
  final VoidCallback onShowed;
  final String? initialInput;

  @override
  State<StepByStepScreen> createState() => _StepByStepScreenState();
}

class _StepByStepScreenState extends State<StepByStepScreen> {
  late Direction _direction;
  final TextEditingController _controller = TextEditingController();
  List<ConversionStep> _steps = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _direction = widget.initialDirection;
    final initialInput = widget.initialInput?.trim();
    if (initialInput != null && initialInput.isNotEmpty) {
      _controller.text = initialInput;
      _controller.selection = TextSelection.collapsed(
        offset: initialInput.length,
      );
    }
    widget.onShowed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _buildSteps() {
    final text = _controller.text.trim();
    setState(() {
      _error = null;
      _steps = const [];

      if (text.isEmpty) {
        return;
      }

      try {
        if (_direction == Direction.romanToArabic) {
          _steps = RomanConverter.explainRomanToInt(text);
        } else {
          final number = int.tryParse(text);
          if (number == null) {
            throw const FormatException('Introduce un numero entero.');
          }
          _steps = RomanConverter.explainIntToRoman(number);
        }
      } on FormatException catch (exception) {
        _error = exception.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explicacion paso a paso')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<Direction>(
              segments: const [
                ButtonSegment(
                  value: Direction.romanToArabic,
                  icon: Icon(Icons.arrow_right_alt),
                  label: Text('Romano -> Arabe'),
                ),
                ButtonSegment(
                  value: Direction.arabicToRoman,
                  icon: Icon(Icons.arrow_left),
                  label: Text('Arabe -> Romano'),
                ),
              ],
              selected: {_direction},
              onSelectionChanged: (selected) {
                setState(() {
                  _direction = selected.first;
                  _steps = const [];
                  _error = null;
                  _controller.clear();
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
                    controller: _controller,
                    keyboardType: _direction == Direction.romanToArabic
                        ? TextInputType.text
                        : const TextInputType.numberWithOptions(),
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: _direction == Direction.romanToArabic
                          ? 'Ej.: XLII'
                          : 'Ej.: 42',
                      prefixIcon: const Icon(Icons.auto_stories_rounded),
                    ),
                    onSubmitted: (_) => _buildSteps(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _buildSteps,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Ver pasos'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _steps.isEmpty
                ? const _LearnEmptyState()
                : ListView.builder(
                    itemCount: _steps.length,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Paso ${index + 1}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: AppTokens.terracotta)),
                              const SizedBox(height: 6),
                              Text(step.title,
                                  style: Theme.of(context).textTheme.titleLarge),
                              if (step.detail != null) ...[
                                const SizedBox(height: 6),
                                Text(step.detail!),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: AdBannerWidget(),
          ),
        ],
      ),
    );
  }
}

class _LearnEmptyState extends StatelessWidget {
  const _LearnEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined, size: 56, color: AppTokens.deepInk),
          SizedBox(height: 8),
          Text('Ingresa un valor y toca "Ver pasos".'),
        ],
      ),
    );
  }
}
