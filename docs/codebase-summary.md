# Codebase Summary

## 1. Directory Structure

```text
lib/
├── main.dart                 # Entry point, Provider configuration
├── components/               # Shared UI components (Button, Screen wrapper)
├── config/                   # Configuration (Environment, Features)
├── constants/                # App constants (Colors, URLs)
├── contexts/                 # State management
│   └── app_context.dart      # AppState (boot, onboarded status)
├── models/                   # Data models
│   ├── audio.dart            # Audio recording models
│   ├── login.dart            # Auth models
│   ├── meeting.dart          # Meeting response & details
│   ├── transcript.dart       # Transcript & AI analysis
│   └── user.dart             # User profile
├── navigation/               # Routing & Navigation
│   ├── app_navigator.dart    # Navigation helper
│   └── app_routes.dart       # Route definitions
├── screens/                  # UI Screens (Feature-based)
│   ├── auth/                 # Social login
│   ├── main/                 # Navigation tabs (Recordings, Settings)
│   ├── onboarding/           # Walkthrough flow
│   └── recording/            # Active recording, Details, AI Tabs
│       └── tabs/             # Transcript, Summary, AI Chat tabs
├── services/                 # Business logic & APIs
│   ├── audio.dart            # Audio recording service
│   ├── bootstrap.dart        # App initialization
│   ├── meeting.dart          # Meeting data service
│   ├── repository.dart       # API repository (Dio)
│   └── storage.dart          # Local storage (SharedPrefs)
├── theme/                    # Styling
│   ├── app_theme.dart        # Consolidated theme data
│   ├── colors.dart           # App color palette
│   ├── spacing.dart          # Spacing constants
│   └── typography.dart       # Font & Text styles
└── utils/                    # Utility functions
```

## 2. Key Files & Responsibilities

- **`lib/main.dart`**: Sets up `MultiProvider` for global services (`AppState`, `MeetingService`) and initializes the `MaterialApp` with the custom theme.
- **`lib/services/audio.dart`**: Core logic for audio capture using the `record` package. Manages recording states, duration timing, and file path generation (Android public directory support).
- **`lib/services/repository.dart`**: Uses `Dio` for API calls. Centralizes network logic for fetching meetings and AI analysis data.
- **`lib/contexts/app_context.dart`**: Manages the high-level application lifecycle (is the app booted? has the user seen onboarding?).
- **`lib/screens/recording/record_detail_screen.dart`**: A complex screen using a `TabController` to switch between Transcript, Summary, and AI Chat views of a recording.

## 3. Architecture Patterns

### 3.1. Service-Provider Pattern
The app uses a service-oriented architecture where:
1.  **Services** (`lib/services/`) handle low-level operations (API, Audio, Storage).
2.  **Providers** (`AppState`, `MeetingService`) wrap these services or maintain state, notifying the UI when changes occur.
3.  **UI** (`lib/screens/`) consumes state via `Consumer` or `context.watch/select`.

### 3.2. Clean UI/Logic Separation
- Business logic is kept out of `build` methods.
- Long-running tasks (recording timer, API calls) are managed in services/providers.
- Themes and styles are centralized in `lib/theme/` to keep widget code clean.

## 4. State Management Flow

1.  **Boot**: `Bootstrap.init()` runs → `AppState.boot()` reads local storage for onboarding status.
2.  **Auth**: Social login → Token stored → User navigated to `MainTabs`.
3.  **Recording**: User starts recording → `AudioService` manages the stream → `active_record_screen` updates duration and state visually.
4.  **Meeting Data**: `MeetingService.loadMeetings()` → `Repository.getMeetings()` → UI rebuilds with the latest list.

## 5. Recent Changes

- **TopOn SDK Removal**: All references to TopOn advertising SDK were disabled in `lib/services/bootstrap.dart` and Gradle configs to resolve a critical `NoClassDefFoundError` caused by Flutter embedding version mismatches.
- **AI Chat Tab**: Added `lib/screens/recording/tabs/chat_ai_tab.dart` to support interactive querying of meeting content.
