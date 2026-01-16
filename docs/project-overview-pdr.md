# Project Overview and Product Development Requirements (PDR)

## 1. Project Information
- **Project Name**: RecapIt - AI Meeting Recorder
- **Description**: A Flutter mobile application designed for recording meetings, lectures, and conversations. It provides real-time transcription, AI-powered summarization, and an interactive AI chat to query recording content.
- **Version**: 1.0.0+1
- **Target Platforms**: Mobile (iOS 13.0+, Android API 33+)

## 2. Core Features and User Stories

### 2.1. User Onboarding & Authentication
- **User Story**: As a user, I want a seamless entry into the app and secure access to my recordings.
- **Features**:
    - Multi-step onboarding flow explaining core value propositions.
    - Social authentication (Google, Apple) via social login screen.
    - Persistent session management via local storage.

### 2.2. Intelligent Recording
- **User Story**: As a user, I want to capture high-quality audio of my meetings with full control over the process.
- **Features**:
    - Real-time audio recording (M4A/AAC format).
    - Pause/Resume functionality to skip unwanted segments.
    - Permission-aware recording (Microphone, Storage permissions).
    - Public directory storage on Android (`/Recordings/Recapit/`) for easy file access.

### 2.3. Recording Detail & AI Analysis
- **User Story**: As a user, I want to review my recordings and get instant AI-powered insights.
- **Features**:
    - **Transcription**: Automatic speech-to-text conversion.
    - **AI Summary**: Concise summaries highlighting key takeaways and action items.
    - **AI Chat**: Interactive tab to ask questions about the recording content (e.g., "What was the decision on the budget?").
    - **Recording Metadata**: Display of title, duration, date, and file size.

### 2.4. Management & Navigation
- **User Story**: As a user, I want to easily organize and find my past recordings.
- **Features**:
    - Recording list with status indicators and search capability.
    - Tab-based navigation (Recordings, Settings).
    - Sleek dark theme UI for reduced eye strain.

## 3. Technical Requirements

### 3.1. Performance & Reliability
- **Audio Integrity**: Ensure no data loss during recording, even if the app goes to background.
- **UI Responsiveness**: Smooth transitions and real-time duration updates during recording.
- **Fast Boot**: Rapid app initialization (< 1s) with `Bootstrap.init()`.

### 3.2. Architecture & Tech Stack
- **Framework**: Flutter 3.9.2
- **State Management**: Provider with `ChangeNotifier` (AppState, MeetingService).
- **Networking**: Dio for robust API communication.
- **Audio Engine**: `record` package for capture, `just_audio` for playback.
- **Persistence**: `shared_preferences` for settings and metadata.

### 3.3. Security & Privacy
- **Permissions**: Granular permission handling via `permission_handler`.
- **Data Safety**: Recordings stored locally and accessed via secure repository patterns.

## 4. Known Limitations & Constraints

### 4.1. Advertising SDK
- **Status**: TopOn SDK is currently **disabled**.
- **Reason**: Incompatibility with the current Flutter environment/embedding causing crashes (NoClassDefFoundError).
- **Impact**: No advertisements are displayed in the current version.

### 4.2. File Management
- **Storage**: External storage permissions are required on older Android versions; Android 13+ uses scoped/media access.

## 5. Success Metrics
- Recording success rate > 99%.
- AI Analysis completion time < 30s for 1-hour meetings.
- High user retention through intuitive onboarding.

