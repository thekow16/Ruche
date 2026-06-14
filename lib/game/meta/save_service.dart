/// Local persistence for meta-progression.
///
/// Uses `shared_preferences` rather than hive/isar: the saved data is a handful
/// of scalar values and small id sets (banked Honey, unlocked card ids, a few
/// stats). A key/value store with no schema, migrations, or query layer is the
/// right-sized tool here — a full embedded database would be overkill.
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'meta_state.dart';

class SaveService {
  static const String _key = 'hive_meta_v1';

  Future<MetaState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return MetaState();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return MetaState.fromJson(json);
    } catch (_) {
      return MetaState();
    }
  }

  Future<void> save(MetaState meta) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(meta.toJson()));
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
