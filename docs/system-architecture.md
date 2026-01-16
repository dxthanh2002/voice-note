# System Architecture

## 1. High-Level Architecture

The application follows a **Service-Oriented Clean Architecture** pattern, optimized for Flutter's reactive framework.

```text
[ UI LAYER (Widgets / Screens) ]
      ↑ ↓ (Streams / ChangeNotifier)
[ PROVIDER LAYER (AppState / MeetingService) ]
      ↑ ↓ (Async Data / Models)
[ SERVICE LAYER (Audio / Repository / Storage) ]
      ↑ ↓ (HTTP / Platform Channels / Filesystem)
[ EXTERNAL (API / Audio HW / SharedPrefs) ]
```

## 2. Layer Responsibilities

### 2.1. UI Layer (`lib/screens/`, `lib/widgets/`)
- **Screens**: Large feature components (e.g., `RecordDetailScreen`).
- **Widgets/Components**: Atomic, reusable UI elements (e.g., `AppButton`).
- **Theme**: Centralized visual identity in `lib/theme/`.

### 2.2. Provider Layer (`lib/contexts/`, `lib/services/meeting.dart`)
- Acts as a bridge between the raw services and the UI.
- Maintains reactive state using `ChangeNotifier`.
- Handles side effects (e.g., loading data when a screen initializes).

### 2.3. Service Layer (`lib/services/`)
- **AudioService**: High-level API for the `record` package. Handles permissions, file paths, and timer logic.
- **Repository**: Static methods for API interaction using `Dio`.
- **StorageService**: Wrapper for `shared_preferences`.
- **Bootstrap**: One-time app initialization logic.

### 2.4. Data Layer (`lib/models/`)
- Strongly typed Dart classes for API responses and internal data structures.
- Logic for JSON serialization/deserialization.

## 3. Core Data Flows

### 3.1. Recording Flow
1. User taps "Start" in `active_record_screen`.
2. UI calls `AudioService.startRecording()`.
3. `AudioService` requests permissions, creates a file in the Android public directory or iOS documents, and starts the timer.
4. `AudioService` exposes a `durationStream` and `stateStream`.
5. UI listens to these streams to update the recording timer and waveform visualization.

### 3.2. Meeting Retrieval Flow
1. `MainTabsScreen` (Recordings Tab) initializes.
2. UI calls `context.read<MeetingService>().loadMeetings()`.
3. `MeetingService` calls `Repository.getMeetings()`.
4. `Repository` performs a GET request via `Dio`.
5. Data is mapped to `List<MeetingResponse>`.
6. `MeetingService` updates internal list and calls `notifyListeners()`.
7. UI rebuilds automatically via `Consumer<MeetingService>`.

## 4. Platform-Specific Implementations

### 4.1. Android
- **File Storage**: Custom logic in `AudioService` to use the public `Recordings/Recapit/` directory on Android 11+ to ensure users can access their files outside the app.
- **Permissions**: Complex handling for Android 13+ (Media permissions) vs older versions (Storage permissions).

### 4.2. iOS
- **File Storage**: Standard `getApplicationDocumentsDirectory()` usage.
- **Permissions**: Info.plist keys for `NSMicrophoneUsageDescription`.

## 5. Error Handling Strategy

- **API Errors**: Caught in `Repository` or `MeetingService`, logged via `debugPrintStack`, and UI updated to show an empty or error state.
- **Permission Denials**: Handled gracefully in `AudioService` returning `false` on start attempts, allowing the UI to show permission dialogs or settings links.
- **Bootstrap Failures**: Placeholder in `Bootstrap.init()` to ensure the app doesn't hang on a black screen if a non-critical service fails to load.
