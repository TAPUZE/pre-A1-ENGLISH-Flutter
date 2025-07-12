import 'package:flutter/material.dart';

const String baseUrl = 'http://localhost:5000/api';
const String logEventUrl = '$baseUrl/log-event';
const String analyticsUrl = '$baseUrl/analytics/';

// App Colors
class AppColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color secondary = Color(0xFFFFB74D);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFC107);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}

// App Constants (for backward compatibility)
class AppConstants {
  static const Color primaryColor = AppColors.primary;
  static const Color secondaryColor = AppColors.secondary;
  static const Color textColor = AppColors.textPrimary;
  static const Color backgroundColor = AppColors.background;
}

// App Strings
class AppStrings {
  static const String appName = 'PRE A1 English Trip';
  static const String splashTitle = 'Welcome to Your English Adventure!';
  static const String homeTitle = 'David\'s Trip to New York';
  static const String dashboardTitle = 'Progress Dashboard';
  static const String mistakeLogTitle = 'Mistake Log';
  static const String congratulations = 'Congratulations! 🎉';
  static const String sectionComplete = 'Section Complete!';
  static const String tryAgain = 'Try Again';
  static const String nextSection = 'Next Section';
  static const String playAgain = 'Play Again';
  static const String submit = 'Submit';
  static const String correct = 'Correct! ✅';
  static const String incorrect = 'Incorrect! ❌';
}
