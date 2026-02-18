import 'package:roman_converter/core/models/conversion_entry.dart';
import 'package:roman_converter/features/history/history_repository.dart';

class InMemoryHistoryRepository implements HistoryRepository {
  final List<ConversionEntry> _items = <ConversionEntry>[];

  @override
  Future<void> add(ConversionEntry entry) async {
    if (_items.isNotEmpty) {
      final top = _items.first;
      if (top.input == entry.input &&
          top.output == entry.output &&
          top.direction == entry.direction) {
        return;
      }
    }
    _items.insert(0, entry);
  }

  @override
  Future<void> clearAll() async => _items.clear();

  @override
  Future<void> delete(String id) async => _items.removeWhere((e) => e.id == id);

  @override
  Future<List<ConversionEntry>> loadAll() async => List<ConversionEntry>.from(_items);

  @override
  Future<void> toggleFavorite(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(isFavorite: !_items[index].isFavorite);
  }
}
