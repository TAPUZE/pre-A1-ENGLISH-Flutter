# English Trip App 🇺🇸✈️🇮🇱

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/TAPUZE/pre-A1-ENGLISH-Flutter)

A comprehensive PRE A1 English Learning Platform built with Flutter, featuring interactive exercises, games, and a progressive learning journey from Tel Aviv to New York.

## 🚀 Live Demo

- **Web App**: Run `flutter run -d web-server --web-port=8080` and visit `http://localhost:8080`
- **Repository**: [GitHub - TAPUZE/pre-A1-ENGLISH-Flutter](https://github.com/TAPUZE/pre-A1-ENGLISH-Flutter)

## Features

### 🎯 Core Learning Features
- **Interactive Lessons**: Teaching widgets with bilingual support (English/Hebrew)
- **Exercise System**: Multiple choice, fill-in-the-blank, and matching exercises
- **Story-Based Learning**: Engaging narratives with comprehension activities
- **Review & Quizzes**: Comprehensive section reviews with immediate feedback
- **Progress Tracking**: Detailed analytics and performance monitoring

### 🎮 Gamification
- **Interactive Games**: Hangman, Bingo, Charades, and more
- **Confetti Celebrations**: Visual feedback for achievements
- **Timer Challenges**: Timed exercises to build fluency
- **Emoji Reactions**: Engaging feedback system
- **Achievement System**: Progress milestones and rewards

### 🌍 Multilingual Support
- **Bilingual Interface**: Switch between English and Hebrew
- **Text-to-Speech**: Audio support for pronunciation
- **Cultural Context**: Travel-themed content connecting two cultures

### 📱 Modern Mobile Experience
- **Responsive Design**: Optimized for all screen sizes
- **Offline Support**: Local storage with Hive database
- **Cross-Platform**: iOS and Android compatibility
- **Beautiful UI**: Material Design with custom animations

## Technical Stack

### Frontend (Flutter)
- **State Management**: Provider pattern
- **Local Storage**: Hive for offline data, SharedPreferences for settings
- **HTTP Client**: RESTful API communication
- **Audio**: Flutter TTS for pronunciation
- **Charts**: FL Chart for analytics visualization
- **Animations**: Lottie animations and confetti effects

### Backend Integration
- **MERN Stack**: MongoDB, Express.js, React, Node.js
- **API Endpoints**: User logging, progress tracking, analytics
- **Real-time Sync**: Progress synchronization across devices

## Project Structure

```
lib/
├── constants/
│   └── app_constants.dart          # Colors, strings, API endpoints
├── models/
│   ├── user_log.dart              # User activity logging model
│   ├── user_log.g.dart            # Hive generated code
│   └── workbook_content.dart      # Content structure and data
├── providers/
│   └── app_provider.dart          # State management and API calls
├── screens/
│   ├── splash_screen.dart         # App initialization
│   ├── home_screen.dart           # Main navigation
│   ├── workbook_section_screen.dart # Section content display
│   └── dashboard_screen.dart      # Analytics and progress
├── utils/
│   └── local_storage.dart         # SharedPreferences utilities
├── widgets/
│   ├── teaching_widget.dart       # Interactive lessons
│   ├── exercise_widget.dart       # Exercise activities
│   ├── game_widget.dart           # Interactive games
│   └── review_widget.dart         # Section reviews and quizzes
└── main.dart                      # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd english_trip_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### VS Code Tasks
Use the pre-configured tasks in VS Code:
- `Flutter: Run Debug` - Run the app in debug mode
- `Flutter: Build APK` - Build release APK
- `Flutter: Run Tests` - Execute test suite
- `Flutter: Clean` - Clean build artifacts
- `Flutter: Get Dependencies` - Install packages
- `Build Runner: Generate Code` - Generate Hive adapters

## Content Structure

### Workbook Sections
1. **Airport & Travel** - Basic travel vocabulary and phrases
2. **Hotel & Accommodation** - Booking and hotel interactions
3. **Food & Restaurants** - Dining experiences and food vocabulary
4. **Shopping** - Retail interactions and transactions
5. **Transportation** - Public transport and navigation
6. **Sightseeing** - Tourist attractions and activities
7. **Culture & People** - Cultural exchanges and social interactions
8. **Emergency Situations** - Safety and emergency phrases

### Exercise Types
- **Multiple Choice**: Vocabulary and grammar comprehension
- **Fill in the Blank**: Sentence completion exercises
- **Matching**: Connect words with meanings or images
- **Drag and Drop**: Interactive word ordering
- **Audio Recognition**: Listen and select exercises

### Game Mechanics
- **Hangman**: Word guessing with visual feedback
- **Bingo**: Vocabulary matching game
- **Charades**: Action-based vocabulary game
- **Memory Cards**: Matching pairs game
- **Word Scramble**: Unscramble vocabulary words

## API Integration

### Backend Endpoints
```
POST /api/users/log - Log user activity
GET /api/users/:userId/progress - Get user progress
POST /api/users/:userId/mistakes - Log mistakes
GET /api/analytics/dashboard - Get analytics data
```

### Data Models
- **User Logs**: Activity tracking and engagement metrics
- **Progress**: Section completion and scores
- **Mistakes**: Error tracking for personalized learning
- **Analytics**: Performance insights and trends

## Customization

### Adding New Content
1. Update `workbook_content.dart` with new sections
2. Add corresponding exercises and games
3. Update language translations
4. Add audio files for pronunciation

### Styling
- Modify colors in `app_constants.dart`
- Update theme in `main.dart`
- Add custom fonts in `pubspec.yaml`

### New Features
- Add new exercise types in `exercise_widget.dart`
- Create new games in `game_widget.dart`
- Extend analytics in `dashboard_screen.dart`

## Assets

### Required Assets
- **Images**: App icons, backgrounds, character illustrations
- **Audio**: Pronunciation files, background music, sound effects
- **Animations**: Lottie files for engaging user experience
- **Fonts**: Roboto family for consistent typography

### Asset Guidelines
- Optimize images for mobile performance
- Use consistent audio quality and volume
- Test animations on different screen sizes
- Ensure accessibility compliance

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

### Widget Tests
- Test individual widgets in isolation
- Verify state management behavior
- Ensure proper error handling

## Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Store Preparation
- Update version in `pubspec.yaml`
- Generate app icons and screenshots
- Prepare store descriptions in multiple languages
- Test on various devices and OS versions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue on GitHub
- Check the documentation
- Review the code examples

## Acknowledgments

- Flutter team for the amazing framework
- Community contributors and packages
- Educational content consultants
- Beta testers and feedback providers

---

**Made with ❤️ for English learners worldwide**
