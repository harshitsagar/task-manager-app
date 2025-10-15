# Firebase Setup Guide

## Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project: "Task Manager App"
3. Register your app

## Step 2: Android Setup
1. In Firebase Console, add Android app
2. Package name: `com.example.taskmanager` (update with your package name)
3. Download `google-services.json`
4. Place in: `android/app/google-services.json`

## Step 3: iOS Setup
1. In Firebase Console, add iOS app
2. Bundle ID: `com.example.taskmanager` (update with your bundle ID)
3. Download `GoogleService-Info.plist`
4. Place in: `ios/Runner/GoogleService-Info.plist`

## Step 4: Enable Services
1. **Authentication** → Sign-in method → Enable Email/Password
2. **Firestore Database** → Create database in test mode

## Step 5: Update Firebase Rules

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /tasks/{taskId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}