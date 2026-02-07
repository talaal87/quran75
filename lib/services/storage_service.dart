import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';

class StorageService {
  static const String _wordsKey = 'quran_words';
  static const String _progressKey = 'user_progress';

  // Save words list
  Future<void> saveWords(List<Word> words) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(words.map((w) => w.toJson()).toList());
    await prefs.setString(_wordsKey, jsonString);
  }

  // Load words list
  Future<List<Word>> loadWords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_wordsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Word.fromJson(json)).toList();
  }

  // Save specific key-value
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // Load specific key-value
  Future<String?> loadString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // Clear all data (for testing/reset)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
