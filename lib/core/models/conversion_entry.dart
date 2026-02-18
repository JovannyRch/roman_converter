import '../../features/converter/converter_service.dart';

class ConversionEntry {
  final String id;
  final String input;
  final String output;
  final Direction direction;
  final DateTime timestamp;
  final bool isFavorite;

  const ConversionEntry({
    required this.id,
    required this.input,
    required this.output,
    required this.direction,
    required this.timestamp,
    required this.isFavorite,
  });

  ConversionEntry copyWith({
    String? id,
    String? input,
    String? output,
    Direction? direction,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return ConversionEntry(
      id: id ?? this.id,
      input: input ?? this.input,
      output: output ?? this.output,
      direction: direction ?? this.direction,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'input': input,
      'output': output,
      'direction': direction.name,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory ConversionEntry.fromJson(Map<String, dynamic> json) {
    return ConversionEntry(
      id: json['id'] as String,
      input: json['input'] as String,
      output: json['output'] as String,
      direction: Direction.values.firstWhere(
        (value) => value.name == json['direction'],
        orElse: () => Direction.romanToArabic,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
