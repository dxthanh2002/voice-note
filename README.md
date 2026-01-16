# RecapIt - AI Meeting Recorder

AI-powered meeting recorder application built with Flutter. Record, transcribe, and summarize your meetings with intelligent insights.

## Overview

RecapIt is a mobile application that helps users capture meetings, lectures, and conversations. It provides real-time transcription, AI-generated summaries, and an interactive AI chat to query your recording content.

## Features

- **Intuitive Recording**: Real-time audio recording with pause/resume functionality.
- **AI Transcription**: Convert speech to text automatically.
- **Smart Summaries**: AI-generated meeting summaries, key points, and action items.
- **AI Chat**: Interactive chat interface to ask questions about your recordings.
- **Onboarding & Auth**: Secure social authentication (Google, Apple) and user-friendly onboarding.
- **Recording Management**: Organize, search, and playback recordings with a sleek dark theme.

## Tech Stack

- **Framework**: Flutter 3.9.2 (Dart ^3.9.2)
- **State Management**: Provider with ChangeNotifier
- **Networking**: Dio (5.7.0)
- **Audio**: record (6.1.2), just_audio (0.9.40)
- **Local Storage**: shared_preferences
- **Architecture**: Service Layer with Clean Architecture principles

## Current Status

- **Version**: 1.0.0+1
- **Ads Status**: TopOn SDK is currently disabled due to incompatibility with the current Flutter environment. The app is fully functional for recording and AI features.
- **Environment**: Optimized for Android 13+ (API 33+) and iOS 13.0+.

## Project Structure

```
lib/
├── main.dart              # App entry point & MultiProvider setup
├── components/            # Shared UI components
├── config/                # Environment & feature configuration
├── contexts/              # Global state (AppState)
├── models/                # Data models (Audio, Meeting, Transcript, User)
├── navigation/            # Routing & Navigation management
├── screens/               # Feature-based UI screens
│   ├── auth/              # Login & Authentication
│   ├── main/              # Dashboard, Recordings List, Settings
│   ├── onboarding/        # Initial app walkthrough
│   └── recording/         # Active recording & Detailed view (Tabs)
├── services/              # Business logic (Audio, Meeting, Repository, Storage)
├── theme/                 # Consolidated AppTheme (Colors, Typography)
└── utils/                 # Utility functions
```

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2
- Android SDK (API 33+) / Xcode (iOS 13.0+)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Documentation

Detailed technical documentation is available in the `docs/` directory:

- [Project Overview & PDR](docs/project-overview-pdr.md)
- [System Architecture](docs/system-architecture.md)
- [Codebase Summary](docs/codebase-summary.md)
- [Code Standards](docs/code-standards.md)
- [Project Roadmap](docs/project-roadmap.md)

## License

Proprietary - All rights reserved.
