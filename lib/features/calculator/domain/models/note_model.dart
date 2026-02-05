import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NoteModel {
  final String id;
  final String title;
  final String description;
  final int updatedAt; // epoch ms

  const NoteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.updatedAt,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? description,
    int? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'updatedAt': updatedAt,
      };

  factory NoteModel.fromMap(Map<String, dynamic> map) => NoteModel(
        id: map['id'] as String,
        title: (map['title'] as String?) ?? '',
        description: (map['description'] as String?) ?? '',
        updatedAt: (map['updatedAt'] as int?) ?? 0,
      );
}

class NotesStorage {
  static const String _key = 'calcNova_notes_v1';

  static Future<List<NoteModel>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((e) => NoteModel.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static Future<void> saveNotes(List<NoteModel> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final list = notes.map((n) => n.toMap()).toList();
    await prefs.setString(_key, jsonEncode(list));
  }
}
