# Deployment Guide

## 1. Prerequisites

- **Flutter SDK**: 3.9.2
- **Java**: JDK 11 (required for Gradle 8+)
- **CocoaPods**: Latest version (for iOS)
- **Git**: For version control

## 2. Initial Setup

1.  **Clone the Repository**:
    ```bash
    git clone <repository-url>
    cd voicenote-flutter
    ```
2.  **Fetch Dependencies**:
    ```bash
    flutter pub get
    ```

## 3. Platform-Specific Setup

### 3.1. Android
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)
- **Compile SDK**: 34
- **Permissions**:
    - `android.permission.INTERNET`
    - `android.permission.RECORD_AUDIO`
    - `android.permission.READ_MEDIA_AUDIO` (for Android 13+)
    - `android.permission.WRITE_EXTERNAL_STORAGE` (for Android < 10)

### 3.2. iOS
- **Deployment Target**: 13.0
- **Permissions (Info.plist)**:
    - `NSMicrophoneUsageDescription`: Required for meeting recording.
    - `NSPhotoLibraryUsageDescription`: Required for user profile pictures.

## 4. Build Configurations

### 4.1. Android Build
```bash
# Debug APK
flutter build apk --debug

# Release APK (Split per ABI)
flutter build apk --release --split-per-abi

# App Bundle (For Play Store)
flutter build appbundle
```

### 4.2. iOS Build
```bash
# IPA for testing/distribution
flutter build ipa --release
```

## 5. Known Build Issues & Workarounds

### 5.1. TopOn SDK Incompatibility
The `anythink_sdk` (TopOn) currently causes a `NoClassDefFoundError` on some environments due to Flutter embedding conflicts.
- **Status**: Currently disabled in `Bootstrap.init()`.
- **Workaround**: Do not re-enable until migrating to a newer SDK version or alternative provider.

### 5.2. Android 13+ Permissions
Starting with API 33, `READ_EXTERNAL_STORAGE` is replaced by `READ_MEDIA_AUDIO`. The `AudioService` handles this check, but ensure the `AndroidManifest.xml` includes the new media permissions.

## 6. Deployment Checklist

- [ ] Version and build number updated in `pubspec.yaml`.
- [ ] Debug banners disabled (`debugShowCheckedModeBanner: false`).
- [ ] Appropriate icons generated and placed in `assets/images` and native folders.
- [ ] API base URL in `lib/constants/urls.dart` set to production.
- [ ] Proguard/R8 rules verified for release builds.
