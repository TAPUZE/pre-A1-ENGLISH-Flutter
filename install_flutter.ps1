# Flutter Installation Script for Windows
# Run this script in PowerShell as Administrator

Write-Host "Installing Flutter SDK..." -ForegroundColor Green

# Create flutter directory
$flutterPath = "C:\flutter"
Write-Host "Creating Flutter directory at $flutterPath" -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $flutterPath | Out-Null

# Download Flutter SDK (latest stable)
$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip"
$output = "$flutterPath\flutter_sdk.zip"
Write-Host "Downloading Flutter SDK..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
    Write-Host "Download completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "Download failed: $_" -ForegroundColor Red
    exit 1
}

# Extract Flutter SDK
Write-Host "Extracting Flutter SDK..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $output -DestinationPath "C:\" -Force
    Write-Host "Extraction completed!" -ForegroundColor Green
} catch {
    Write-Host "Extraction failed: $_" -ForegroundColor Red
    exit 1
}

# Add to PATH
Write-Host "Adding Flutter to PATH..." -ForegroundColor Yellow
$currentPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
if ($currentPath -notlike "*C:\flutter\bin*") {
    try {
        [Environment]::SetEnvironmentVariable("PATH", $currentPath + ";C:\flutter\bin", [EnvironmentVariableTarget]::Machine)
        Write-Host "Flutter added to PATH successfully!" -ForegroundColor Green
    } catch {
        Write-Host "Failed to add Flutter to PATH: $_" -ForegroundColor Red
        Write-Host "Please add C:\flutter\bin to your PATH manually" -ForegroundColor Yellow
    }
}

# Clean up
Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
Remove-Item $output -Force

Write-Host ""
Write-Host "Flutter installation completed!" -ForegroundColor Green
Write-Host "Please restart your terminal and run the following commands:" -ForegroundColor Yellow
Write-Host "  flutter --version" -ForegroundColor Cyan
Write-Host "  flutter doctor" -ForegroundColor Cyan
Write-Host ""
Write-Host "Then navigate to your project and run:" -ForegroundColor Yellow
Write-Host "  flutter pub get" -ForegroundColor Cyan
Write-Host "  flutter run" -ForegroundColor Cyan
