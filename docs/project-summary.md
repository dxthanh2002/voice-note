# RecapIt - Project Summary

> Last updated: January 2025

## 1. Project Overview

**RecapIt** is a Flutter mobile app for recording meetings, lectures, and conversations with AI-powered analysis capabilities (transcription, summarization).

| Property | Value |
|----------|-------|
| **Package Name** | aimateflutter |
| **Version** | 1.0.0+1 |
| **Platforms** | Android, iOS |
| **Framework** | Flutter 3.9+ |
| **Language** | Dart |

---

## 2. Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter |
| State Management | Provider (ChangeNotifier) |
| HTTP Client | Dio |
| Local Storage | SharedPreferences |
| Audio Recording | record ^6.1.2 |
| Audio Playback | just_audio ^0.9.40 |
| Permissions | permission_handler |
| Device Info | device_info_plus |

---

## 3. Current Features

### ✅ Implemented
- **Onboarding Flow** - Welcome screens for new users
- **Authentication** - Login screen (Google, Apple placeholders)
- **Audio Recording** - Real-time recording with pause/resume/stop
- **Recording Storage** - Files saved to `/Recordings/Recapit/` (.m4a format)
- **Recordings List** - Display all recordings with pull-to-refresh
- **Recording Detail** - 3-tab view (Phiên âm, Tóm tắt, Chat AI)
- **Delete Recording** - Swipe or menu to delete
- **Settings** - User preferences, upgrade subscription
- **Dark Theme** - Consistent dark UI throughout

### 🔜 Planned
- AI Transcription (Speech-to-text)
- AI Summarization
- Cloud sync
- Search recordings

---

## 4. Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│  screens/ (auth, main, onboarding, recording, subscription)  │
│  components/ widgets/                                        │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                  State Management                            │
│  contexts/app_context.dart (AppState - ChangeNotifier)       │
│  data/recordings_repository.dart (RecordingsRepository)      │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                  Business Logic                              │
│  services/audio_recorder_service.dart                        │
│  services/api_client.dart                                    │
│  services/storage.dart                                       │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                  Data Layer                                  │
│  Local: SharedPreferences, File System                       │
│  Remote: Backend API (Dio)                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Directory Structure

```
lib/
├── main.dart                 # App entry point, MultiProvider setup
├── components/               # Reusable UI components
├── constants/                # URLs, constants
├── contexts/                 # AppState (global state)
├── data/                     # RecordingsRepository, models
├── navigation/               # Routes, navigator
├── screens/
│   ├── auth/                 # Login
│   ├── main/                 # MainTabsScreen, RecordingsTab, SettingsTab
│   ├── onboarding/           # Onboarding flow
│   ├── recording/            # RecordDetail, CreateRecordSheet, widgets
│   └── subscription/         # Upgrade screen
├── services/                 # AudioRecorderService, ApiClient, Storage
├── theme/                    # Colors, Typography, Spacing
└── widgets/                  # Shared widgets
```

---

## 6. Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry, Provider setup |
| `lib/services/audio_recorder_service.dart` | Audio recording logic, permissions |
| `lib/data/recordings_repository.dart` | Recording model, file storage |
| `lib/screens/main/recordings_tab.dart` | Recordings list UI |
| `lib/screens/recording/record_detail_screen.dart` | Recording playback, tabs |
| `lib/contexts/app_context.dart` | Global app state |
| `android/app/src/main/AndroidManifest.xml` | Android permissions |

---

## 7. Recent Updates (Jan 2025)

### Recording Feature Fixes
- ✅ Added `RECORD_AUDIO` permission to AndroidManifest
- ✅ Added `READ_MEDIA_AUDIO` for Android 13+
- ✅ Changed storage path to `/Recordings/Recapit/` (public, visible)
- ✅ Changed audio format to M4A (AAC encoder, ~1MB/min)
- ✅ Fixed recordings list not displaying files
- ✅ Added pull-to-refresh for recordings list
- ✅ Added delete recording functionality

### UI Improvements
- ✅ RecordDetailScreen with 3 tabs (Phiên âm, Tóm tắt, Chat AI)
- ✅ Recording mode with placeholder content
- ✅ RecordingControlsBar with timer and waveform
- ✅ PillTabBar component

---

## 8. Android Permissions

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />
```

---

## 9. File Storage

| Platform | Path |
|----------|------|
| Android | `/storage/emulated/0/Recordings/Recapit/` |
| iOS | `Documents/Recordings/` |

**File naming**: `recording_[timestamp].m4a`

---

## 10. Dependencies

```yaml
dependencies:
  flutter: sdk
  dio: ^5.7.0
  provider: ^6.1.2
  shared_preferences: ^2.3.2
  record: ^6.1.2
  just_audio: ^0.9.40
  path: ^1.9.0
  path_provider: ^2.1.4
  permission_handler: ^11.3.1
  device_info_plus: ^11.2.0
  intl: ^0.19.0
  uuid: ^4.5.1
```

---

## 11. Related Documentation

- [Project Overview PDR](project-overview-pdr.md) - Detailed requirements
- [System Architecture](system-architecture.md) - Architecture deep dive
- [Code Standards](code-standards.md) - Coding guidelines
- [Project Roadmap](project-roadmap.md) - Future plans
