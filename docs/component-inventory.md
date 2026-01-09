# Component Inventory - RecapIt

**Project Type:** Flutter Mobile Application  
**Generated:** 2026-01-08  
**Scan Level:** Exhaustive

---

## Overview

| Category | Count |
|----------|-------|
| Screens | 10 |
| Custom Widgets | 8 |
| Theme Components | 4 |
| Services | 4 |
| State Providers | 2 |

---

## Screens

### Main Navigation

| Screen | File | Description |
|--------|------|-------------|
| **MainTabsScreen** | `screens/main/main_tabs_screen.dart` | Bottom navigation with 2 tabs |
| **RecordingsTab** | `screens/main/recordings_tab.dart` | Recording list with FAB |
| **SettingsTab** | `screens/main/settings_tab.dart` | User preferences |

### User Flow

| Screen | File | Description |
|--------|------|-------------|
| **OnboardingScreen** | `screens/onboarding/onboarding_screen.dart` | First-time user welcome |
| **LoginScreen** | `screens/auth/login_screen.dart` | Social authentication |

### Recording Feature

| Screen | File | Description |
|--------|------|-------------|
| **ActiveRecordScreen** | `screens/recording/active_record_screen.dart` | Live recording with timer |
| **RecordDetailScreen** | `screens/recording/record_detail_screen.dart` | Recording view with tabs |
| **CreateRecordSheet** | `screens/recording/create_record_sheet.dart` | New recording bottom sheet |

### Subscription

| Screen | File | Description |
|--------|------|-------------|
| **UpgradeScreen** | `screens/subscription/upgrade_screen.dart` | Premium upgrade |

---

## Tab Views (RecordDetailScreen)

| Tab | File | Status | Description |
|-----|------|--------|-------------|
| **TranscriptTab** | `tabs/transcript_tab.dart` | Placeholder | AI transcription view |
| **SummaryTab** | `tabs/summary_tab.dart` | Placeholder | AI summary view |
| **ChatAITab** | `tabs/chat_ai_tab.dart` | Placeholder | AI chat interface |

---

## Custom Widgets

### Recording Widgets

| Widget | File | Purpose |
|--------|------|---------|
| **AudioPlayerBar** | `widgets/audio_player_bar.dart` | Playback controls with progress |
| **PillTabBar** | `widgets/pill_tab_bar.dart` | Pill-style tab selector |
| **RecordingControlsBar** | `widgets/recording_controls_bar.dart` | Stop/Pause buttons |
| **RecordingPlaceholderTab** | `widgets/recording_placeholder_tab.dart` | Loading state during recording |

### Recording List Widgets (Inline)

| Widget | Location | Purpose |
|--------|----------|---------|
| **_RecordingCard** | `recordings_tab.dart` | Recording list item card |
| **_StatusBadge** | `recordings_tab.dart` | Summary status indicator |
| **_PlayButton** | `recordings_tab.dart` | Quick play button |

### Recording Screen Widgets (Inline)

| Widget | Location | Purpose |
|--------|----------|---------|
| **_ControlButton** | `active_record_screen.dart` | Circular control button |

---

## Theme Components

### Color System (`lib/theme/colors.dart`)

```dart
class AppColors {
  // Primary
  static const Color primary = Color(0xFF137FEC);
  
  // Backgrounds (Dark Theme)
  static const Color backgroundDark = Color(0xFF101922);
  static const Color cardDark = Color(0xFF1A2632);
  
  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF92ADC9);
  static const Color textMuted = Color(0xFF64748B);
  
  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFEF4444);
}
```

### Typography (`lib/theme/typography.dart`)

- **Font Family:** Inter
- **Weights:** 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold), 800 (ExtraBold), 900 (Black)

### Theme Configuration (`lib/theme/app_theme.dart`)

| Component | Configuration |
|-----------|---------------|
| **Brightness** | Dark |
| **Primary Color** | `#137FEC` |
| **Background** | `#101922` |
| **Card** | `#1A2632` with 12px radius |
| **Button** | Primary color, 12px radius, 48px height |

---

## State Management

### Providers

| Provider | Class | Responsibility |
|----------|-------|----------------|
| **AppState** | `ChangeNotifier` | Boot status, onboarding state |
| **RecordingsRepository** | `ChangeNotifier` | Recording list, CRUD operations |

### AppState Properties

```dart
bool booted      // App initialization complete
bool onboarded   // User has seen onboarding
```

### RecordingsRepository Properties

```dart
List<Recording> recordings  // All recordings
bool isLoading              // Loading state
```

---

## Services

| Service | File | Responsibility |
|---------|------|----------------|
| **AudioRecorderService** | `services/audio_recorder_service.dart` | Audio recording core |
| **StorageService** | `services/storage.dart` | SharedPreferences wrapper |
| **ApiClient** | `services/api_client.dart` | Dio HTTP client |
| **AppBootstrap** | `services/app_bootstrap.dart` | Initialization |

### AudioRecorderService API

```dart
// Properties
RecordingState state        // idle, recording, paused, stopped
String? currentFilePath     // Active recording path
Duration recordedDuration   // Current duration
Stream<Duration> durationStream
Stream<RecordingState> stateStream

// Methods
Future<bool> startRecording()
Future<void> pauseRecording()
Future<void> resumeRecording()
Future<String?> stopRecording()
Future<void> cancelRecording()
Future<void> togglePause()
```

---

## Data Models

### Recording

```dart
class Recording {
  final String id;
  final String title;
  final String filePath;
  final DateTime date;
  final Duration duration;
  final bool hasSummary;
}
```

### ProfileUserInfo

```dart
class ProfileUserInfo {
  final String? token;
  final String? id;
  final String? name;
  final String? email;
  final String? avatar;
  // ... additional fields
}
```

---

## Navigation

### Routes (`lib/navigation/app_routes.dart`)

| Route | Screen |
|-------|--------|
| `/onboarding` | OnboardingScreen |
| `/login` | LoginScreen |
| `/home` | MainTabsScreen |
| `/activeRecord` | ActiveRecordScreen |
| `/recordDetail` | RecordDetailScreen |
| `/upgrade` | UpgradeScreen |

---

## Design Patterns in Use

1. **Provider Pattern** - State management with ChangeNotifier
2. **Repository Pattern** - RecordingsRepository for data abstraction
3. **Service Layer** - Business logic in dedicated service classes
4. **Composition** - Screens composed of focused widget components
5. **Stateful/Stateless Split** - Stateless for pure UI, Stateful for screen logic

---

*Generated by BMAD Document Project Workflow v1.2.0*
