// lib/features/search/data/local/search_history_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryStorage {
  static const String _key = 'search_history';
  static const int _maxHistory = 20;

  static Future<List<String>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_key) ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveHistory(List<String> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, history.take(_maxHistory).toList());
    } catch (e) {
      // Silent fail
    }
  }

  static Future<void> clearHistory() async {
    await saveHistory([]);
  }
}
