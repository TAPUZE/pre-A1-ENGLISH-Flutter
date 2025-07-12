# GitHub Copilot Instructions for English Trip App

## Project Overview
This is a Flutter-based PRE A1 English learning mobile app with bilingual support (English/Hebrew). The app provides interactive lessons, exercises, games, and progress tracking for English language learners.

## Architecture Guidelines

### State Management
- Use Provider pattern for state management
- AppProvider handles all global state including user progress, settings, and API calls
- Local state for widget-specific data using StatefulWidget

### Data Flow
- Models define data structures (UserLog, WorkbookContent)
- Providers manage state and business logic
- Widgets consume state through Consumer/Provider.of
- API calls handled through AppProvider methods

### File Organization
```
lib/
├── constants/     # App-wide constants (colors, strings, APIs)
├── models/        # Data models and Hive entities
├── providers/     # State management (Provider pattern)
├── screens/       # Full-screen pages
├── utils/         # Utility functions and helpers
├── widgets/       # Reusable UI components
└── main.dart      # App entry point
```

## Code Style Guidelines

### Naming Conventions
- Files: snake_case (e.g., `user_log.dart`)
- Classes: PascalCase (e.g., `UserLog`)
- Variables/Methods: camelCase (e.g., `currentSection`)
- Constants: UPPER_CASE (e.g., `PRIMARY_COLOR`)

### Widget Structure
- Always use const constructors when possible
- Include required parameters first, then optional
- Use meaningful widget names that describe their purpose
- Include key parameter for stateful widgets

### Error Handling
- Use try-catch blocks for API calls
- Provide user-friendly error messages
- Log errors for debugging
- Handle offline scenarios gracefully

## Flutter-Specific Guidelines

### Performance
- Use const constructors for static widgets
- Implement proper dispose methods for controllers
- Use ListView.builder for dynamic lists
- Optimize image loading and caching

### Responsiveness
- Use MediaQuery for screen size detection
- Implement responsive layouts with Flexible/Expanded
- Test on various screen sizes and orientations
- Consider different pixel densities

### Accessibility
- Add semantic labels to interactive elements
- Use proper contrast ratios
- Support screen readers
- Implement focus management

## App-Specific Guidelines

### Bilingual Support
- All user-facing text should support Hebrew and English
- Use AppProvider.isHebrew to determine current language
- Implement RTL layout support for Hebrew
- Provide translations for all UI elements

### Audio Integration
- Use Flutter TTS for pronunciation
- Implement audio feedback for interactions
- Handle audio permissions properly
- Provide audio controls for user preference

### Learning Features
- Track user progress through AppProvider
- Log mistakes for personalized learning
- Implement celebration animations for achievements
- Provide immediate feedback on exercises

### Games and Interactions
- Use timers for timed challenges
- Implement confetti animations for success
- Provide multiple difficulty levels
- Include skip options for accessibility

## API Integration

### Backend Communication
- Use HTTP package for API calls
- Implement proper error handling for network requests
- Cache responses locally when appropriate
- Handle authentication tokens if implemented

### Data Synchronization
- Sync progress data with backend
- Handle offline scenarios with local storage
- Implement conflict resolution for data sync
- Provide sync status indicators

## Testing Guidelines

### Unit Tests
- Test business logic in providers
- Mock API calls for consistent testing
- Test edge cases and error scenarios
- Maintain good test coverage

### Widget Tests
- Test widget rendering and interactions
- Verify state changes and updates
- Test navigation and routing
- Include accessibility testing

### Integration Tests
- Test complete user flows
- Verify API integration
- Test offline functionality
- Validate cross-platform compatibility

## Deployment Considerations

### Build Configuration
- Use different build variants for development/production
- Configure proper app signing for releases
- Optimize build size and performance
- Include proper metadata and descriptions

### Platform-Specific
- Handle iOS and Android differences
- Test on actual devices, not just simulators
- Implement platform-specific features when needed
- Consider platform-specific UI guidelines

## Common Patterns

### Provider Usage
```dart
// Consuming state
final appProvider = context.watch<AppProvider>();

// Calling methods
context.read<AppProvider>().methodName();

// Listening to specific changes
Consumer<AppProvider>(
  builder: (context, provider, child) {
    return Widget();
  },
)
```

### Navigation
```dart
// Navigate to screen
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => ScreenName()),
);

// Replace current screen
Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (context) => ScreenName()),
);
```

### Error Handling
```dart
try {
  await apiCall();
} catch (e) {
  print('Error: $e');
  // Show user-friendly error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Something went wrong')),
  );
}
```

## Maintenance Guidelines

### Code Reviews
- Check for proper error handling
- Verify bilingual support implementation
- Ensure accessibility compliance
- Review performance implications

### Updates
- Keep dependencies updated
- Test after Flutter SDK updates
- Monitor for deprecated API usage
- Update documentation as needed

### Monitoring
- Track app performance metrics
- Monitor user engagement analytics
- Log and analyze error reports
- Gather user feedback for improvements

## Development Tips

### Debugging
- Use Flutter Inspector for widget tree analysis
- Implement proper logging for debugging
- Use breakpoints effectively
- Test on real devices regularly

### Performance Optimization
- Use Flutter DevTools for performance analysis
- Optimize image and asset loading
- Implement lazy loading for large datasets
- Monitor memory usage and leaks

### Best Practices
- Follow Flutter's official guidelines
- Keep widgets small and focused
- Use composition over inheritance
- Implement proper separation of concerns
- Document complex logic with comments

## Future Enhancements

### Planned Features
- Offline mode improvements
- More interactive games
- Advanced analytics dashboard
- Social features and sharing
- Voice recognition exercises

### Technical Improvements
- Implement automated testing
- Add continuous integration
- Optimize for different screen sizes
- Enhance accessibility features
- Add more languages support

This document should guide development decisions and ensure consistency across the codebase. Update it as the project evolves and new patterns emerge.
