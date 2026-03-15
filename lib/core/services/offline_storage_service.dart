import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineStorageService {
  static const String _offlineAnswersKey = 'offline_monitoring_answers';

  Future<void> saveAnswersLocally(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existingData = prefs.getStringList(_offlineAnswersKey) ?? [];
    existingData.add(json.encode(data));
    await prefs.setStringList(_offlineAnswersKey, existingData);
  }

  Future<List<Map<String, dynamic>>> getOfflineAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existingData = prefs.getStringList(_offlineAnswersKey) ?? [];
    return existingData.map((e) => json.decode(e) as Map<String, dynamic>).toList();
  }

  Future<void> clearOfflineAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_offlineAnswersKey);
  }
}
