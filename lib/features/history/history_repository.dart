import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/conversion_entry.dart';

abstract class HistoryRepository {
  Future<List<ConversionEntry>> loadAll();
  Future<void> add(ConversionEntry entry);
  Future<void> toggleFavorite(String id);
  Future<void> delete(String id);
  Future<void> clearAll();
}

class LocalHistoryRepository implements HistoryRepository {
  static const _storageKey = 'conversion_history';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<List<ConversionEntry>> loadAll() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <ConversionEntry>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => ConversionEntry.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<void> add(ConversionEntry entry) async {
    final all = await loadAll();
    if (all.isNotEmpty) {
      final top = all.first;
      final isConsecutiveDuplicate =
          top.input == entry.input &&
          top.output == entry.output &&
          top.direction == entry.direction;
      if (isConsecutiveDuplicate) {
        return;
      }
    }

    final updated = [entry, ...all];
    await _save(updated);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final all = await loadAll();
    final updated = all
        .map(
          (item) => item.id == id
              ? item.copyWith(isFavorite: !item.isFavorite)
              : item,
        )
        .toList();
    await _save(updated);
  }

  @override
  Future<void> delete(String id) async {
    final all = await loadAll();
    all.removeWhere((item) => item.id == id);
    await _save(all);
  }

  @override
  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(_storageKey);
  }

  Future<void> _save(List<ConversionEntry> entries) async {
    final prefs = await _prefs;
    final serialized = jsonEncode(entries.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, serialized);
  }
}
