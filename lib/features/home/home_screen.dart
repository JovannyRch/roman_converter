import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../converter/converter_controller.dart';
import '../converter/converter_service.dart';
import '../favorites/favorites_section.dart';
import '../history/history_section.dart';
import '../learn/step_by_step_screen.dart';
import '../../widgets/ad_banner_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    required this.onLearnOpened,
    this.showBottomBannerAd = true,
  });

  final ConverterController controller;
  final VoidCallback onLearnOpened;
  final bool showBottomBannerAd;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _textController;
  StreamSubscription<int>? _stateSubscription;
  Timer? _typingSaveDebounce;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(_onTextChanged);
    _stateSubscription = widget.controller.changes.listen((_) {
      if (!mounted) {
        return;
      }

      if (_textController.text != widget.controller.input) {
        _textController.value = TextEditingValue(
          text: widget.controller.input,
          selection: TextSelection.collapsed(
            offset: widget.controller.input.length,
          ),
        );
      }

      setState(() {});
    });
    unawaited(widget.controller.initialize());
  }

  @override
  void dispose() {
    _typingSaveDebounce?.cancel();
    _stateSubscription?.cancel();
    _textController
      ..removeListener(_onTextChanged)
      ..dispose();
    widget.controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_textController.text != widget.controller.input) {
      widget.controller.onInputChanged(_textController.text);
      _typingSaveDebounce?.cancel();
      if (_textController.text.trim().isEmpty) {
        return;
      }
      _typingSaveDebounce = Timer(const Duration(milliseconds: 900), () {
        unawaited(widget.controller.saveCurrent());
      });
    }
  }

  Future<void> _showMessage(String message) async {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roma Flash'),
        actions: [
          IconButton(
            tooltip: 'Limpiar historial',
            onPressed:
                controller.history.isEmpty
                    ? null
                    : () => controller.clearHistory(),
            icon: const Icon(Icons.cleaning_services_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Text(
              'Convierte en segundos',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Entrada rapida, resultado inmediato y repite con un toque.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTokens.deepInk.withOpacity(0.75),
              ),
            ),
            const SizedBox(height: AppTokens.space3),
            _ConversionPath(
              hasInput: controller.input.isNotEmpty,
              hasResult: controller.output != null,
              hasSaved:
                  controller.history.isNotEmpty && controller.input.isNotEmpty,
            ),
            const SizedBox(height: AppTokens.space3),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SegmentedButton<Direction>(
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
                      selected: {controller.direction},
                      onSelectionChanged:
                          (selection) =>
                              controller.setDirection(selection.first),
                    ),
                    const SizedBox(height: AppTokens.space3),
                    TextField(
                      controller: _textController,
                      keyboardType:
                          controller.direction == Direction.romanToArabic
                              ? TextInputType.text
                              : const TextInputType.numberWithOptions(),
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText:
                            controller.direction == Direction.romanToArabic
                                ? 'Ej: MCMLXXXIV'
                                : 'Ej: 1984',
                        prefixIcon: const Icon(Icons.bolt_rounded),
                      ),
                    ),
                    const SizedBox(height: AppTokens.space2),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final ok = await controller.pasteFromClipboard();
                            if (ok) {
                              await _showMessage('Texto pegado.');
                            }
                          },
                          icon: const Icon(Icons.content_paste_rounded),
                          label: const Text('Pegar'),
                        ),
                        OutlinedButton.icon(
                          onPressed: controller.clear,
                          icon: const Icon(Icons.clear_rounded),
                          label: const Text('Limpiar'),
                        ),
                        OutlinedButton.icon(
                          onPressed: controller.swapDirection,
                          icon: const Icon(Icons.swap_horiz_rounded),
                          label: const Text('Invertir'),
                        ),
                        FilledButton.icon(
                          onPressed:
                              controller.output == null
                                  ? null
                                  : () async {
                                    final copied =
                                        await controller.copyOutput();
                                    if (copied) {
                                      await _showMessage('Resultado copiado.');
                                    }
                                  },
                          icon: const Icon(Icons.copy_rounded),
                          label: const Text('Copiar resultado'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.space3),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child:
                          controller.error != null
                              ? _ResultBox(
                                key: const ValueKey('error_box'),
                                label: 'Error',
                                value: controller.error!,
                                color: Colors.red.shade100,
                                textColor: Colors.red.shade800,
                              )
                              : controller.output != null
                              ? _ResultBox(
                                key: const ValueKey('result_box'),
                                label: 'Resultado',
                                value: controller.output!,
                                color: AppTokens.laurel.withOpacity(0.2),
                                textColor: AppTokens.deepInk,
                              )
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTokens.space3),
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => StepByStepScreen(
                          initialDirection: controller.direction,
                          initialInput:
                              controller.input.isNotEmpty
                                  ? controller.input
                                  : null,
                          onShowed: widget.onLearnOpened,
                        ),
                  ),
                );
              },
              icon: const Icon(Icons.school_rounded),
              label: const Text('Ver explicacion paso a paso'),
            ),
            const SizedBox(height: AppTokens.space4),
            FavoritesSection(
              items: controller.favorites,
              onTapItem: (item) async {
                await controller.useHistoryItem(item);
                await _showMessage('Favorito cargado.');
              },
              onToggleFavorite: (id) => controller.toggleFavorite(id),
            ),
            if (controller.favorites.isNotEmpty) const SizedBox(height: 20),
            HistorySection(
              items: controller.history,
              onTapItem: (item) async {
                await controller.useHistoryItem(item);
                await _showMessage('Conversion recuperada.');
              },
              onToggleFavorite: (id) => controller.toggleFavorite(id),
              onDelete: (id) => controller.deleteHistoryItem(id),
              onClear: controller.clearHistory,
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          widget.showBottomBannerAd
              ? const SizedBox(
                height: 66,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Align(
                      alignment: Alignment.center,
                      child: AdBannerWidget(),
                    ),
                  ),
                ),
              )
              : null,
    );
  }
}

class _ResultBox extends StatelessWidget {
  const _ResultBox({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
  });

  final String label;
  final String value;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTokens.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

class _ConversionPath extends StatelessWidget {
  const _ConversionPath({
    required this.hasInput,
    required this.hasResult,
    required this.hasSaved,
  });

  final bool hasInput;
  final bool hasResult;
  final bool hasSaved;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTokens.warmMarble,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTokens.borderSoft),
      ),
      child: Row(
        children: [
          _PathNode(label: 'Entrada', active: hasInput),
          _PathConnector(active: hasResult),
          _PathNode(label: 'Resultado', active: hasResult),
          _PathConnector(active: hasSaved),
          _PathNode(label: 'Guardado', active: hasSaved),
        ],
      ),
    );
  }
}

class _PathNode extends StatelessWidget {
  const _PathNode({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 22,
            width: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppTokens.laurel : Colors.white,
              border: Border.all(color: AppTokens.borderStrong),
            ),
            child:
                active
                    ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                    : null,
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _PathConnector extends StatelessWidget {
  const _PathConnector({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 18,
      height: 4,
      decoration: BoxDecoration(
        color: active ? AppTokens.laurel : AppTokens.borderStrong,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
