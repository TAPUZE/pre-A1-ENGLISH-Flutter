import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../models/user_log.dart';
import '../models/workbook_content.dart';
import '../utils/local_storage.dart';
import '../constants/app_constants.dart';

class AppProvider extends ChangeNotifier {
  String? _userId;
  List<UserLog> _logs = [];
  int _currentSection = 1;
  Map<String, dynamic> _analytics = {};
  Map<String, dynamic> _userProgress = {};
  List<Map<String, dynamic>> _mistakeLog = [];
  Map<String, dynamic> _settings = {};
  bool _isLoading = false;
  String? _error;
  bool _isHebrew = false;

  // Getters
  String? get userId => _userId;
  List<UserLog> get logs => _logs;
  int get currentSection => _currentSection;
  Map<String, dynamic> get analytics => _analytics;
  Map<String, dynamic> get userProgress => _userProgress;
  List<Map<String, dynamic>> get mistakeLog => _mistakeLog;
  Map<String, dynamic> get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isHebrew => _isHebrew;

  // Initialize the app
  Future<void> initUser() async {
    _setLoading(true);
    try {
      // Get or create user ID
      _userId = await LocalStorage.getUserId();
      if (_userId == null) {
        _userId = 'user_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
        await LocalStorage.setUserId(_userId!);
      }

      // Load user data
      await _loadUserData();

      // Initialize default settings
      await LocalStorage.initializeDefaults();
      _settings = await LocalStorage.getSettings();

      // Fetch analytics from server
      await fetchAnalytics();

      _error = null;
    } catch (e) {
      _error = 'Failed to initialize app: ${e.toString()}';
      print('Init error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load user data from local storage
  Future<void> _loadUserData() async {
    _currentSection = await LocalStorage.getCurrentSection();
    _userProgress = await LocalStorage.getUserProgress();
    _mistakeLog = await LocalStorage.getMistakeLog();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Log events to server and local storage
  Future<void> logEvent(String eventType, Map<String, dynamic> details) async {
    if (_userId == null) return;

    try {
      final userLog = UserLog(
        userId: _userId!,
        eventType: eventType,
        details: details,
      );

      // Add to local logs
      _logs.add(userLog);

      // Log to server
      final response = await http.post(
        Uri.parse(logEventUrl),
        body: jsonEncode(userLog.toJson()),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        print('Event logged successfully: $eventType');
      } else {
        print('Failed to log event: ${response.statusCode}');
      }

      // Handle specific event types
      await _handleEventType(eventType, details);

      notifyListeners();
    } catch (e) {
      print('Error logging event: $e');
    }
  }

  // Handle specific event types
  Future<void> _handleEventType(String eventType, Map<String, dynamic> details) async {
    switch (eventType) {
      case 'progress':
        await _handleProgress(details);
        break;
      case 'mistake':
        await _handleMistake(details);
        break;
      case 'section_complete':
        await _handleSectionComplete(details);
        break;
      case 'engagement':
        await _handleEngagement(details);
        break;
    }
  }

  // Handle progress events
  Future<void> _handleProgress(Map<String, dynamic> details) async {
    final activityId = details['activityId'] as String?;
    if (activityId != null) {
      await LocalStorage.updateActivityProgress(activityId, details);
      _userProgress = await LocalStorage.getUserProgress();
    }
  }

  // Handle mistake events
  Future<void> _handleMistake(Map<String, dynamic> details) async {
    await LocalStorage.addMistake(details);
    _mistakeLog = await LocalStorage.getMistakeLog();
  }

  // Handle section completion
  Future<void> _handleSectionComplete(Map<String, dynamic> details) async {
    final sectionId = details['sectionId'] as int?;
    if (sectionId != null) {
      await LocalStorage.addCompletedSection(sectionId);
      if (sectionId == _currentSection) {
        _currentSection = sectionId + 1;
        await LocalStorage.setCurrentSection(_currentSection);
      }
    }
  }

  // Handle engagement events
  Future<void> _handleEngagement(Map<String, dynamic> details) async {
    // Track engagement metrics
    print('Engagement tracked: ${details['type']}');
  }

  // Fetch analytics from server
  Future<void> fetchAnalytics() async {
    if (_userId == null) return;

    try {
      final response = await http.get(
        Uri.parse('$analyticsUrl$_userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _analytics = jsonDecode(response.body);
        print('Analytics fetched successfully');
      } else {
        print('Failed to fetch analytics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching analytics: $e');
    }
  }

  // Update current section
  void updateSection(int section) {
    if (section != _currentSection) {
      _currentSection = section;
      LocalStorage.setCurrentSection(section);
      notifyListeners();
    }
  }

  // Get section data
  Map<String, dynamic>? getSectionData(int sectionId) {
    try {
      return WorkbookContent.sections.firstWhere(
        (section) => section['id'] == sectionId,
      );
    } catch (e) {
      return null;
    }
  }

  // Get completed sections
  Future<List<int>> getCompletedSections() async {
    return await LocalStorage.getCompletedSections();
  }

  // Check if section is completed
  Future<bool> isSectionCompleted(int sectionId) async {
    final completed = await getCompletedSections();
    return completed.contains(sectionId);
  }

  // Get total sections count
  int get totalSections => WorkbookContent.sections.length;

  // Get progress percentage
  Future<double> getProgressPercentage() async {
    final completed = await getCompletedSections();
    return (completed.length / totalSections) * 100;
  }

  // Update settings
  Future<void> updateSetting(String key, dynamic value) async {
    _settings[key] = value;
    await LocalStorage.setSetting(key, value);
    notifyListeners();
  }

  // Get setting
  T? getSetting<T>(String key) {
    return _settings[key] as T?;
  }

  // Clear all data
  Future<void> clearAllData() async {
    await LocalStorage.clearAll();
    _userId = null;
    _logs.clear();
    _currentSection = 1;
    _analytics.clear();
    _userProgress.clear();
    _mistakeLog.clear();
    _settings.clear();
    notifyListeners();
  }

  // Get mistake statistics
  Map<String, int> getMistakeStats() {
    final stats = <String, int>{};
    for (final mistake in _mistakeLog) {
      final type = mistake['type'] as String? ?? 'unknown';
      stats[type] = (stats[type] ?? 0) + 1;
    }
    return stats;
  }

  // Get recent mistakes
  List<Map<String, dynamic>> getRecentMistakes({int limit = 10}) {
    final sorted = List<Map<String, dynamic>>.from(_mistakeLog)
      ..sort((a, b) {
        final aTime = DateTime.parse(a['timestamp'] as String);
        final bTime = DateTime.parse(b['timestamp'] as String);
        return bTime.compareTo(aTime);
      });
    return sorted.take(limit).toList();
  }

  // Get activity score
  int getActivityScore(String activityId) {
    final progress = _userProgress[activityId] as Map<String, dynamic>?;
    return progress?['score'] as int? ?? 0;
  }

  // Get best scores
  Map<String, int> getBestScores() {
    final scores = <String, int>{};
    for (final entry in _userProgress.entries) {
      final data = entry.value as Map<String, dynamic>;
      final score = data['score'] as int? ?? 0;
      scores[entry.key] = score;
    }
    return scores;
  }

  // Simulate passport stamp reward
  void awardPassportStamp(int sectionId) {
    logEvent('passport_stamp', {
      'sectionId': sectionId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Get user statistics
  Map<String, dynamic> getUserStats() {
    return {
      'totalSections': totalSections,
      'currentSection': _currentSection,
      'totalMistakes': _mistakeLog.length,
      'totalActivities': _userProgress.length,
      'mistakeStats': getMistakeStats(),
      'bestScores': getBestScores(),
    };
  }

  // Missing methods for compatibility
  void logMistake(String type, Map<String, dynamic> details) {
    logEvent('mistake', {
      'type': type,
      'details': details,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void logProgress(String activityId, Map<String, dynamic> progress) {
    logEvent('progress', {
      'activityId': activityId,
      'progress': progress,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Add missing getters for tests
  String? get currentUserId => _userId;
  
  List<Map<String, dynamic>> get userMistakes => _logs
      .where((log) => log.eventType == 'mistake')
      .map((log) => log.details)
      .toList();
  
  void toggleLanguage() {
    _isHebrew = !_isHebrew;
    notifyListeners();
  }
}
