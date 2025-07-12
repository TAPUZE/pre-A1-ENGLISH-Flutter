# Flutter Manual Installation Script for Windows

## Option 1: Manual Download and Install (Recommended)

### Step 1: Download Flutter SDK
1. Go to https://flutter.dev/docs/get-started/install/windows
2. Download the latest stable release ZIP file
3. Extract to `C:\flutter` (or another location of your choice)

### Step 2: Add Flutter to PATH
Run these commands in PowerShell as Administrator:

```powershell
# Add Flutter to PATH for current session
$env:PATH += ";C:\flutter\bin"

# Add Flutter to PATH permanently (requires restart)
[Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";C:\flutter\bin", [EnvironmentVariableTarget]::Machine)
```

### Step 3: Verify Installation
```powershell
flutter --version
flutter doctor
```

## Option 2: Quick PowerShell Installation Script

Copy and paste this script into PowerShell (Run as Administrator):

```powershell
# Create flutter directory
New-Item -ItemType Directory -Force -Path "C:\flutter"

# Download Flutter SDK
$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip"
$output = "C:\flutter\flutter_sdk.zip"
Invoke-WebRequest -Uri $url -OutFile $output

# Extract Flutter SDK
Expand-Archive -Path $output -DestinationPath "C:\" -Force

# Add to PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
if ($currentPath -notlike "*C:\flutter\bin*") {
    [Environment]::SetEnvironmentVariable("PATH", $currentPath + ";C:\flutter\bin", [EnvironmentVariableTarget]::Machine)
}

# Clean up
Remove-Item $output

Write-Host "Flutter installation completed. Please restart your terminal and run 'flutter doctor'"
```

## Option 3: Using Git (Alternative)

```powershell
# Clone Flutter repository
git clone https://github.com/flutter/flutter.git C:\flutter

# Add to PATH
$env:PATH += ";C:\flutter\bin"
[Environment]::SetEnvironmentVariable("PATH", $env:PATH, [EnvironmentVariableTarget]::User)

# Update Flutter
C:\flutter\bin\flutter channel stable
C:\flutter\bin\flutter upgrade
```

## After Installation

1. **Restart your terminal/PowerShell**
2. **Run Flutter Doctor:**
   ```
   flutter doctor
   ```
3. **Accept Android licenses (if you have Android Studio):**
   ```
   flutter doctor --android-licenses
   ```

## Install Android Studio (Optional but Recommended)

1. Download from https://developer.android.com/studio
2. Install Android Studio
3. Open Android Studio and install:
   - Android SDK
   - Flutter plugin
   - Dart plugin

## Quick Test

After installation, test with:
```
flutter create test_app
cd test_app
flutter run
```

## Troubleshooting

- **Path issues**: Make sure `C:\flutter\bin` is in your PATH
- **Permission errors**: Run PowerShell as Administrator
- **Git issues**: Make sure Git is installed and accessible
- **Android issues**: Install Android Studio and accept licenses

Choose the method that works best for you!
