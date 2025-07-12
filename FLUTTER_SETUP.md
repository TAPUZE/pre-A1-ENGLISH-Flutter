# Flutter Installation Guide for Windows

## Step 1: Download Flutter SDK

1. Go to https://flutter.dev/docs/get-started/install/windows
2. Download the latest stable release (Flutter SDK)
3. Extract the zip file to a location like `C:\flutter`

## Step 2: Update Your PATH

1. Open System Properties (Windows key + R, type `sysdm.cpl`)
2. Click "Environment Variables"
3. Under "User variables", find "Path" and click "Edit"
4. Click "New" and add the path to Flutter's bin folder: `C:\flutter\bin`
5. Click "OK" to save

## Step 3: Install Git (if not already installed)

1. Download Git from https://git-scm.com/download/win
2. Install with default settings

## Step 4: Run Flutter Doctor

Open a new PowerShell/Command Prompt window and run:
```
flutter doctor
```

This will check for any missing dependencies.

## Step 5: Install Android Studio (for Android development)

1. Download Android Studio from https://developer.android.com/studio
2. Install Android Studio
3. Open Android Studio and install the Android SDK
4. Install the Flutter and Dart plugins in Android Studio

## Step 6: Accept Android Licenses

Run this command to accept Android licenses:
```
flutter doctor --android-licenses
```

## Alternative: Quick Setup with Chocolatey

If you have Chocolatey installed:
```
choco install flutter
```

## After Installation

1. Restart your terminal/PowerShell
2. Run `flutter doctor` to verify installation
3. Navigate to the project directory
4. Run `flutter pub get` to install dependencies
5. Run `flutter run` to start the app

## Troubleshooting

- Make sure PATH is correctly set
- Restart your terminal after adding to PATH
- Run `flutter doctor` to diagnose issues
- Check that Android SDK is properly installed
