# RecapIt - Meeting Recorder App

AI-powered meeting recorder application built with Flutter. Record, transcribe, and summarize your meetings.

## Overview

RecapIt is a mobile application that helps users record meetings, get AI-powered transcriptions, and generate intelligent summaries. The app features an intuitive onboarding flow, easy recording management, and playback capabilities.

## Features

- User onboarding and social authentication (Google, Apple)
- Real-time audio recording with pause/resume
- Recording list with status indicators
- Audio playback with progress controls
- AI-powered transcription and summarization (planned)
- Recording categorization and search (planned)
- Cloud synchronization and sharing (planned)
- App settings with recording/summary preferences

## Tech Stack

- **Framework**: Flutter (Dart SDK ^3.9.2)
- **State Management**: Provider with ChangeNotifier
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences
- **Permissions**: permission_handler
- **Device Info**: device_info_plus
- **Architecture**: Service Layer with Clean Architecture

## Project Structure

```
lib/
├── main.dart              # App entry point with Provider setup
├── components/            # Base UI components (Screen wrapper)
├── constants/             # URLs and app constants
├── contexts/              # State management (AppState)
├── data/                  # Mock data and data sources
├── models/                # Data models (Recording, User, etc.)
├── navigation/            # Routes and navigation
├── screens/               # UI screens organized by feature
│   ├── auth/              # Login screen
│   ├── main/              # Tab screens (Recordings, Settings)
│   ├── onboarding/        # Onboarding flow
│   └── recording/         # Recording creation, detail, active
├── services/              # API client, storage, bootstrap
├── theme/                 # Colors, typography, spacing, theme
├── utils/                 # Utility functions (device, file)
└── widgets/               # Reusable widgets
```

## Getting Started

### Prerequisites

- Flutter SDK ^3.9.2
- Dart SDK ^3.9.2
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd recapit
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
# Debug mode
flutter run

# Specific platform
flutter run -d android
flutter run -d ios
flutter run -d chrome
flutter run -d windows
```

### Build

```bash
# Android APK
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## Documentation

Detailed documentation is available in the `docs/` directory:

- [Project Overview & PDR](docs/project-overview-pdr.md)
- [Codebase Summary](docs/codebase-summary.md)
- [Code Standards](docs/code-standards.md)
- [System Architecture](docs/system-architecture.md)
- [Project Roadmap](docs/project-roadmap.md)

## Development

### Hot Reload

While running `flutter run`:
- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Testing

```bash
flutter test
```

## License

This project is proprietary and not open source.
