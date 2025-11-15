@echo off
echo Rebuilding FPL Assistant with network permissions...
echo.

echo Step 1: Cleaning previous build...
flutter clean

echo Step 2: Getting dependencies...
flutter pub get

echo Step 3: Generating app icons...
flutter pub run icons_launcher:create

echo Step 4: Building APK with network permissions...
flutter build apk --release

echo.
echo Build complete! 
echo APK location: build\app\outputs\flutter-apk\app-release.apk
echo.
echo The app now includes:
echo - Internet permissions for API calls
echo - Network state access
echo - Retry mechanism for failed connections
echo - Better error messages
echo - Custom app icon
echo.
pause
