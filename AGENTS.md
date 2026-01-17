# AGENTS.md - Voice Note Flutter App

## Commands
- **Run:** `flutter run`
- **Build:** `flutter build apk` (Android) / `flutter build ios` (iOS)
- **Analyze:** `flutter analyze`
- **Test all:** `flutter test`
- **Test single:** `flutter test test/<file>_test.dart`
- **Get deps:** `flutter pub get`

## Architecture
- **State Management:** Provider with ChangeNotifier (`AppState`, `MeetingService`)
- **HTTP:** Dio for API calls (`services/client_request.dart`)
- **Audio:** `record` for recording, `just_audio` for playback
- **Storage:** `shared_preferences` for local storage, `path_provider` for files

## Project Structure
- `lib/components/` - Reusable UI widgets
- `lib/models/` - Data models (Meeting, Audio, User, Transcript)
- `lib/services/` - Business logic and API services
- `lib/screens/` - Screen widgets
- `lib/contexts/` - App state and providers
- `lib/theme/` - Theming and colors

## Code Style
- Use `flutter_lints` rules (analysis_options.yaml)
- Relative imports for project files, package imports for external deps
- Prefer `const` constructors, use `super.key` for widget keys
- Models use factory constructors for JSON parsing
