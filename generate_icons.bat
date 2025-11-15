@echo off
echo Generating app icons for FPL Assistant...
echo.

REM Check if app_icon.png exists
if not exist "assets\icons\app_icon.png" (
    echo ERROR: app_icon.png not found in assets\icons\
    echo Please place your 1024x1024 PNG icon file as "app_icon.png" in the assets\icons\ directory
    echo.
    pause
    exit /b 1
)

echo Found app_icon.png, generating launcher icons...
echo.

REM Get dependencies
flutter pub get

REM Generate icons
flutter pub run flutter_launcher_icons:main

echo.
echo Icon generation complete!
echo.
echo Generated icons for:
echo - Android (all densities)
echo - iOS (all sizes)  
echo - Web (favicon and PWA)
echo - Windows (desktop)
echo.
pause
