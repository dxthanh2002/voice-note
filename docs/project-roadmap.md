# Project Roadmap

## 1. Current Status (January 2026)

The MVP is functional with core recording and playback features.

### 1.1. Working Features
- **Social Login**: Google and Apple authentication.
- **Onboarding**: Multi-step guide for new users.
- **Audio Capture**: Robust M4A recording with background support.
- **Recording Management**: Tab-based list view with details.
- **AI Integration**: Tabs for Transcript, Summary, and AI Chat are implemented in the UI.

### 1.2. Recent Critical Fixes
- **TopOn SDK Disabled**: Resolved `NoClassDefFoundError` and black screen issues by disabling the TopOn ad SDK, which was incompatible with the current Flutter environment (3.38.5).

## 2. Immediate Priorities (Q1 2026)

### 2.1. Advertising SDK Migration
- **Task**: Replace TopOn with a compatible SDK like `google_mobile_ads` or `anythink_sdk`.
- **Goal**: Restore monetization without breaking the Flutter embedding.

### 2.2. AI Service Refinement
- **Task**: Finalize the backend integration for the AI Chat and Summary features.
- **Goal**: Ensure low-latency responses for meeting queries.

### 2.3. Audio Polish
- **Task**: Implement real-time waveform visualization during recording.
- **Goal**: Improve user feedback during the active recording state.

## 3. Future Enhancements (H2 2026)

### 3.1. Cloud Sync
- Automatic backup of recordings to secure cloud storage.
- Cross-device synchronization of transcripts and notes.

### 3.2. Collaboration
- Sharing meeting summaries via link or email.
- Multi-user "Shared Spaces" for team meeting recordings.

### 3.3. Advanced AI
- Speaker diarization (identifying who is speaking).
- Automated action item extraction with calendar integration.

This roadmap is subject to change based on user feedback, market demands, and technical feasibility. Priorities will be re-evaluated regularly to ensure RecapIt delivers maximum value to its users.