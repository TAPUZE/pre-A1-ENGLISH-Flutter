import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorage {
  static const String _userIdKey = 'user_id';
  static const String _currentSectionKey = 'current_section';
  static const String _completedSectionsKey = 'completed_sections';
  static const String _userProgressKey = 'user_progress';
  static const String _mistakeLogKey = 'mistake_log';
  static const String _settingsKey = 'settings';

  // User ID management
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> setUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // Current section progress
  static Future<int> getCurrentSection() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentSectionKey) ?? 1;
  }

  static Future<void> setCurrentSection(int section) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentSectionKey, section);
  }

  // Completed sections
  static Future<List<int>> getCompletedSections() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedSectionsKey) ?? [];
    return completed.map((e) => int.parse(e)).toList();
  }

  static Future<void> addCompletedSection(int section) async {
    final prefs = await SharedPreferences.getInstance();
    List<int> completed = await getCompletedSections();
    if (!completed.contains(section)) {
      completed.add(section);
      await prefs.setStringList(_completedSectionsKey, completed.map((e) => e.toString()).toList());
    }
  }

  // User progress for specific activities
  static Future<Map<String, dynamic>> getUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressString = prefs.getString(_userProgressKey) ?? '{}';
    return jsonDecode(progressString);
  }

  static Future<void> setUserProgress(Map<String, dynamic> progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProgressKey, jsonEncode(progress));
  }

  static Future<void> updateActivityProgress(String activityId, Map<String, dynamic> data) async {
    Map<String, dynamic> progress = await getUserProgress();
    progress[activityId] = data;
    await setUserProgress(progress);
  }

  // Mistake log
  static Future<List<Map<String, dynamic>>> getMistakeLog() async {
    final prefs = await SharedPreferences.getInstance();
    final logString = prefs.getString(_mistakeLogKey) ?? '[]';
    final logList = jsonDecode(logString) as List;
    return logList.cast<Map<String, dynamic>>();
  }

  static Future<void> addMistake(Map<String, dynamic> mistake) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> log = await getMistakeLog();
    mistake['timestamp'] = DateTime.now().toIso8601String();
    log.add(mistake);
    await prefs.setString(_mistakeLogKey, jsonEncode(log));
  }

  // Settings
  static Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(_settingsKey) ?? '{}';
    return jsonDecode(settingsString);
  }

  static Future<void> setSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings));
  }

  static Future<void> setSetting(String key, dynamic value) async {
    Map<String, dynamic> settings = await getSettings();
    settings[key] = value;
    await setSettings(settings);
  }

  static Future<T?> getSetting<T>(String key) async {
    Map<String, dynamic> settings = await getSettings();
    return settings[key] as T?;
  }

  // Clear all data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Initialize default settings
  static Future<void> initializeDefaults() async {
    final settings = await getSettings();
    if (settings.isEmpty) {
      await setSettings({
        'sound_enabled': true,
        'haptic_feedback': true,
        'language': 'en',
        'show_hebrew': true,
        'auto_play_audio': true,
        'difficulty_level': 'beginner',
        'notifications_enabled': true,
        'dark_mode': false,
      });
    }
  }
}
