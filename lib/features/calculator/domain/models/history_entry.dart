import 'dart:convert';

class HistoryEntry {
  final String id;
  final String expression;
  final String result;
  final DateTime createdAt;

  const HistoryEntry({
    required this.id,
    required this.expression,
    required this.result,
    required this.createdAt,
  });

  String get pretty => '$expression = $result';

  Map<String, dynamic> toMap() => {
        'id': id,
        'expression': expression,
        'result': result,
        'createdAt': createdAt.toIso8601String(),
      };

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      id: map['id'] as String,
      expression: map['expression'] as String,
      result: map['result'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory HistoryEntry.fromJson(String source) => HistoryEntry.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
