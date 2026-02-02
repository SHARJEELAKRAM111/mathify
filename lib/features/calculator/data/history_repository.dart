import '../../../core/persistence/prefs_keys.dart';
import '../../../core/persistence/prefs_service.dart';
import '../domain/models/history_entry.dart';

class HistoryRepository {
  HistoryRepository(this._prefs);

  final PrefsService _prefs;

  List<HistoryEntry> load() {
    final raw = _prefs.getStringList(PrefKeys.history);
    return raw.map(HistoryEntry.fromJson).toList(growable: true);
  }

  Future<void> save(List<HistoryEntry> entries) {
    final raw = entries.map((e) => e.toJson()).toList(growable: false);
    return _prefs.setStringList(PrefKeys.history, raw);
  }

  Future<void> clear() => _prefs.remove(PrefKeys.history);
}
