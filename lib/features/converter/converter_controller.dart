import 'dart:async';

import 'package:flutter/services.dart';

import '../../core/models/conversion_entry.dart';
import '../history/history_repository.dart';
import 'converter_service.dart';

class ConverterController {
  ConverterController({required HistoryRepository historyRepository})
      : _historyRepository = historyRepository;

  final HistoryRepository _historyRepository;

  final StreamController<int> _changes = StreamController<int>.broadcast();

  Direction direction = Direction.romanToArabic;
  String input = '';
  String? output;
  String? error;
  bool isSaving = false;

  List<ConversionEntry> history = const <ConversionEntry>[];

  List<ConversionEntry> get favorites =>
      history.where((item) => item.isFavorite).toList(growable: false);

  Stream<int> get changes => _changes.stream;

  Timer? _saveDebounce;

  Future<void> initialize() async {
    history = await _historyRepository.loadAll();
    _emit();
  }

  void onInputChanged(String value) {
    input = value.trim();
    _recompute();
    _emit();
  }

  void setDirection(Direction value) {
    direction = value;
    input = '';
    output = null;
    error = null;
    _saveDebounce?.cancel();
    _emit();
  }

  void swapDirection() {
    direction = direction == Direction.romanToArabic
        ? Direction.arabicToRoman
        : Direction.romanToArabic;

    if (output != null) {
      input = output!;
    } else {
      input = '';
    }

    _recompute();
    _scheduleSave();
    _emit();
  }

  Future<bool> pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      return false;
    }

    input = text;
    _recompute();
    _scheduleSave();
    _emit();
    return true;
  }

  Future<bool> copyOutput() async {
    if (output == null) {
      return false;
    }

    await Clipboard.setData(ClipboardData(text: output!));
    return true;
  }

  void clear() {
    input = '';
    output = null;
    error = null;
    _saveDebounce?.cancel();
    _emit();
  }

  Future<void> saveCurrent() async {
    if (input.isEmpty || output == null || error != null || isSaving) {
      return;
    }

    isSaving = true;
    _emit();

    final now = DateTime.now();
    final entry = ConversionEntry(
      id: '${now.microsecondsSinceEpoch}_${direction.name}_$input',
      input: input,
      output: output!,
      direction: direction,
      timestamp: now,
      isFavorite: false,
    );

    await _historyRepository.add(entry);
    history = await _historyRepository.loadAll();

    isSaving = false;
    _emit();
  }

  Future<void> toggleFavorite(String id) async {
    await _historyRepository.toggleFavorite(id);
    history = await _historyRepository.loadAll();
    _emit();
  }

  Future<void> useHistoryItem(ConversionEntry entry) async {
    direction = entry.direction;
    input = entry.input;
    _recompute();
    _emit();
  }

  Future<void> deleteHistoryItem(String id) async {
    await _historyRepository.delete(id);
    history = await _historyRepository.loadAll();
    _emit();
  }

  Future<void> clearHistory() async {
    await _historyRepository.clearAll();
    history = const <ConversionEntry>[];
    _emit();
  }

  void dispose() {
    _saveDebounce?.cancel();
    _changes.close();
  }

  void _recompute() {
    if (input.isEmpty) {
      output = null;
      error = null;
      return;
    }

    try {
      if (direction == Direction.romanToArabic) {
        output = RomanConverter.romanToInt(input).toString();
      } else {
        final number = int.tryParse(input);
        if (number == null) {
          throw const FormatException('Introduce un numero entero.');
        }
        output = RomanConverter.intToRoman(number);
      }
      error = null;
    } on FormatException catch (exception) {
      output = null;
      error = exception.message;
    } catch (_) {
      output = null;
      error = 'No se pudo convertir el valor.';
    }
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(saveCurrent());
    });
  }

  void _emit() {
    if (_changes.isClosed) {
      return;
    }
    _changes.add(DateTime.now().microsecondsSinceEpoch);
  }
}
