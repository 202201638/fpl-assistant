# Firebase Setup Instructions for FPL Assistant

## Prerequisites
Before you can use Firebase Authentication in your FPL Assistant app, you need to set up Firebase for your project.

## Step-by-Step Setup

### 1. Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard to create your project

### 2. Register Your Android App
1. In the Firebase Console, click on the Android icon to add an Android app
2. Enter your Android package name: `com.example.fpl_assistant` (or your actual package name from `android/app/build.gradle.kts`)
3. Download the `google-services.json` file
4. Place the downloaded file in the `android/app/` directory of your project

### 3. Register Your iOS App (if building for iOS)
1. In the Firebase Console, click on the iOS icon to add an iOS app
2. Enter your iOS bundle ID (found in `ios/Runner.xcodeproj`)
3. Download the `GoogleService-Info.plist` file
4. Place the downloaded file in the `ios/Runner/` directory

### 4. Enable Firebase Authentication
1. In the Firebase Console, go to "Authentication" in the left sidebar
2. Click "Get Started" if you haven't enabled Authentication
3. Go to the "Sign-in method" tab
4. Enable "Email/Password" authentication
5. Click "Save"

### 5. Configure Firestore (for storing user data)
1. In the Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" for development (remember to update security rules for production!)
4. Select a location for your database
5. Click "Enable"

### 6. Update Android Configuration
The Firebase dependencies are already added to your `pubspec.yaml`. Make sure your `android/build.gradle.kts` includes the Google Services plugin:

```kotlin
// In android/build.gradle.kts
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

And in `android/app/build.gradle.kts`:
```kotlin
// At the top of the file
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Add this line
}
```

### 7. iOS Configuration (if applicable)
No additional configuration needed beyond adding the `GoogleService-Info.plist` file.

### 8. Test Your Setup
1. Run `flutter clean`
2. Run `flutter pub get`
3. Run your app on a device or emulator
4. Try signing up with a new email and password

## Security Rules (Important for Production!)

### Firestore Security Rules
Update your Firestore security rules before going to production:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Starred matches subcollection
      match /starred_matches/{matchId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## Troubleshooting

### "Default FirebaseApp is not initialized"
- Make sure you've added the `google-services.json` file to `android/app/`
- Rebuild your app after adding the configuration files

### "No Firebase App '[DEFAULT]' has been created"
- Ensure `Firebase.initializeApp()` is called in `main.dart` before running the app
- This is already set up in your project

### Build errors on Android
- Make sure you've added the Google Services plugin to your gradle files
- Run `flutter clean` and rebuild

### iOS build errors
- Make sure the `GoogleService-Info.plist` is added to the project in Xcode
- Clean and rebuild the iOS project

## Next Steps
1. Download and add your Firebase configuration files (`google-services.json` and `GoogleService-Info.plist`)
2. Run the app and test the authentication flow
3. Update Firestore security rules for production
4. Consider adding additional authentication methods (Google Sign-In, Apple Sign-In, etc.)

## Current Implementation Features
✅ Email/Password authentication
✅ Sign up functionality
✅ Sign in functionality
✅ Sign out functionality
✅ User profile management
✅ Firestore integration for user data
✅ Auth state persistence
✅ Starred matches sync with Firebase
✅ User preferences storage

Your FPL Assistant app is now ready to use Firebase Authentication!
