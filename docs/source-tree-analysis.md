# Source Tree Analysis - RecapIt

**Project Type:** Flutter Mobile Application (Monolith)  
**Generated:** 2026-01-08  
**Scan Level:** Exhaustive

---

## Complete Directory Tree

```
recapit/                                    # Project root
├── lib/                                    # ★ Main Dart source code (36 files)
│   ├── main.dart                           # ★ ENTRY POINT - App initialization
│   │
│   ├── components/                         # Base UI components
│   │   └── screen.dart                     # Screen wrapper component
│   │
│   ├── constants/                          # App constants
│   │   └── urls.dart                       # API base URLs
│   │
│   ├── contexts/                           # State management
│   │   └── app_context.dart               # ★ AppState (ChangeNotifier)
│   │                                       #   - booted, onboarded state
│   │                                       #   - boot(), setOnboarded() methods
│   │
│   ├── data/                               # Data layer
│   │   ├── mock_recordings.dart            # Sample recording data
│   │   └── recordings_repository.dart      # ★ Recording CRUD + file management
│   │                                       #   - loadRecordings(), addRecording()
│   │                                       #   - deleteRecording(), refresh()
│   │
│   ├── models/                             # Data models
│   │   ├── base_response.dart              # Generic API response wrapper
│   │   └── profile_user.dart               # User profile model with auth
│   │
│   ├── navigation/                         # Navigation layer
│   │   ├── app_navigator.dart              # ★ Route builder (buildRoute)
│   │   └── app_routes.dart                 # Route name constants
│   │
│   ├── screens/                            # UI screens (16 files)
│   │   │
│   │   ├── auth/                           # Authentication
│   │   │   └── login_screen.dart           # Social login (Google, Apple)
│   │   │
│   │   ├── main/                           # Main app screens
│   │   │   ├── main_tabs_screen.dart       # ★ Bottom tab navigation
│   │   │   ├── recordings_tab.dart         # Recording list with FAB
│   │   │   └── settings_tab.dart           # User settings
│   │   │
│   │   ├── onboarding/                     # First-time user
│   │   │   └── onboarding_screen.dart      # Welcome + Get Started
│   │   │
│   │   ├── recording/                      # Recording feature
│   │   │   ├── active_record_screen.dart   # ★ Live recording UI
│   │   │   ├── create_record_sheet.dart    # New recording bottom sheet
│   │   │   ├── record_detail_screen.dart   # ★ Recording detail + tabs
│   │   │   ├── tabs/                       # Detail screen tabs
│   │   │   │   ├── chat_ai_tab.dart        # AI chat (planned)
│   │   │   │   ├── summary_tab.dart        # Summary view (planned)
│   │   │   │   └── transcript_tab.dart     # Transcript view (planned)
│   │   │   └── widgets/                    # Recording-specific widgets
│   │   │       ├── audio_player_bar.dart   # Playback controls
│   │   │       ├── pill_tab_bar.dart       # Pill-style tabs
│   │   │       ├── recording_controls_bar.dart  # Recording buttons
│   │   │       └── recording_placeholder_tab.dart  # Loading state
│   │   │
│   │   └── subscription/                   # Monetization
│   │       └── upgrade_screen.dart         # Premium upgrade
│   │
│   ├── services/                           # Business logic layer
│   │   ├── api_client.dart                 # ★ Dio HTTP client
│   │   ├── app_bootstrap.dart              # App initialization
│   │   ├── audio_recorder_service.dart     # ★ CORE: Audio recording
│   │   │                                   #   - startRecording(), stopRecording()
│   │   │                                   #   - pauseRecording(), resumeRecording()
│   │   │                                   #   - Permission handling
│   │   │                                   #   - M4A output format
│   │   └── storage.dart                    # SharedPreferences wrapper
│   │
│   ├── theme/                              # Design system
│   │   ├── app_theme.dart                  # ★ ThemeData builder
│   │   ├── colors.dart                     # ★ AppColors (dark theme)
│   │   ├── spacing.dart                    # Spacing constants
│   │   └── typography.dart                 # Font family (Inter)
│   │
│   ├── utils/                              # Utilities
│   │   ├── device.dart                     # Device info helper
│   │   └── file.dart                       # File operations
│   │
│   └── widgets/                            # Shared widgets (empty)
│
├── android/                                # Android platform
│   ├── app/
│   │   └── build.gradle.kts               # Android app config
│   ├── build.gradle.kts                    # Project-level gradle
│   └── settings.gradle.kts                 # Gradle settings
│
├── ios/                                    # iOS platform
│   ├── Runner/                             # iOS app target
│   ├── Podfile                             # CocoaPods dependencies
│   └── Runner.xcworkspace                  # Xcode workspace
│
├── assets/                                 # Static assets
│   ├── fonts/                              # Inter font family (8 files)
│   │   ├── inter_regular.ttf
│   │   ├── inter_medium.ttf
│   │   ├── inter_semi_bold.ttf
│   │   ├── inter_bold.ttf
│   │   ├── inter_extra_bold.ttf
│   │   ├── inter_black.ttf
│   │   └── inter_italic.ttf
│   └── images/                             # App images (empty)
│
├── docs/                                   # Documentation
│   ├── index.md                            # ★ Master documentation index
│   ├── project-overview-pdr.md            # Product requirements
│   ├── system-architecture.md             # Architecture docs
│   ├── codebase-summary.md                # Code analysis
│   ├── code-standards.md                  # Coding conventions
│   ├── project-roadmap.md                 # Development plan
│   ├── project-summary.md                 # Executive summary
│   ├── source-tree-analysis.md            # This file
│   ├── component-inventory.md             # UI components
│   └── project-scan-report.json           # Scan state file
│
├── test/                                   # Test files
│   └── widget_test.dart                    # Widget tests
│
├── pubspec.yaml                            # ★ Dependencies manifest
├── pubspec.lock                            # Locked versions
├── analysis_options.yaml                   # Linter rules
├── README.md                               # Project readme
└── .gitignore                              # Git ignore rules
```

---

## Critical Folders Explained

### `lib/` - Main Source Code
The heart of the application containing all Dart code organized by responsibility.

### `lib/screens/recording/` - Core Feature
Contains the primary user-facing functionality:
- Recording creation and management
- Playback interface
- AI analysis tabs (planned)

### `lib/services/` - Business Logic
Contains services that encapsulate business logic:
- **audio_recorder_service.dart** - Most critical file for recording functionality
- **api_client.dart** - All network communications

### `lib/contexts/` - State Management
Single source of truth for app-wide state using Provider pattern.

### `lib/theme/` - Design System
Centralized styling ensures consistent UI across the app.

---

## Key File Relationships

```
main.dart
    └── MeetingRecorderApp (MaterialApp)
            ├── Provider: AppState (contexts/app_context.dart)
            ├── Provider: RecordingsRepository (data/recordings_repository.dart)
            │
            └── AppRoot (Consumer<AppState>)
                    ├── if !booted → Loading
                    ├── if !onboarded → OnboardingScreen
                    └── else → MainTabsScreen
                                    ├── Tab 0: RecordingsTab
                                    │           └── uses RecordingsRepository
                                    │           └── opens CreateRecordSheet
                                    │           └── navigates to RecordDetailScreen
                                    └── Tab 1: SettingsTab

RecordDetailScreen
    ├── uses AudioRecorderService (if new recording)
    ├── uses Recording model
    └── shows tabs:
            ├── TranscriptTab
            ├── SummaryTab
            └── ChatAITab
```

---

## Entry Points

| Entry Point | File | Purpose |
|-------------|------|---------|
| **App Launch** | `lib/main.dart` | Initialize Flutter, Providers, run app |
| **Routes** | `lib/navigation/app_navigator.dart` | Handle named route navigation |
| **State Init** | `lib/contexts/app_context.dart` | Boot app state, check onboarding |
| **Recording** | `lib/services/audio_recorder_service.dart` | Start/stop recording operations |

---

## Asset Locations

| Asset Type | Location | Notes |
|------------|----------|-------|
| **Fonts** | `assets/fonts/` | Inter font family (8 weights) |
| **Images** | `assets/images/` | Currently empty |
| **Audio Files** | Device storage | `/storage/emulated/0/Recordings/Recapit/` (Android) |

---

*Generated by BMAD Document Project Workflow v1.2.0*
