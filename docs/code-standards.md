# Code Standards and Conventions

## 1. Naming Conventions

### 1.1. Files and Directories
-   **Files**: `snake_case.dart` (e.g., `app_theme.dart`, `active_record_screen.dart`).
-   **Directories**: `snake_case/` (e.g., `screens/`, `services/`).
-   **Feature Folders**: Group by feature under `screens/` (e.g., `recording/tabs/`).

### 1.2. Classes and Enums
-   **Classes**: `PascalCase` (e.g., `AppState`, `AudioService`, `MainTabsScreen`).
-   **Enums**: `PascalCase` for type, `camelCase` for values (Standard Dart style) (e.g., `enum RecordingState { idle, recording }`).

### 1.3. Variables and Fields
-   **Local Variables**: `camelCase` (e.g., `recordedDuration`).
-   **Private Fields**: `_camelCase` (prefixed with underscore) (e.g., `_isRecording`).
-   **Constants**: `kPascalCase` for globals (e.g., `kPrimaryColor`), `static const` within classes.

### 1.4. Functions and Methods
-   **Functions**: `camelCase` (e.g., `startRecording()`).
-   **Event Handlers**: Often prefixed with `on` (e.g., `onTapRecord`).

## 2. File Organization

### 2.1. Feature-First Screens
Organize UI by feature rather than widget type:
- `lib/screens/auth/`
- `lib/screens/recording/`

### 2.2. Service Layer
- Logic for external interfaces (Audio, Storage, API) belongs in `lib/services/`.
- Use `static` methods for stateless utilities (e.g., `StorageService`).
- Use `ChangeNotifier` for stateful services (e.g., `MeetingService`).

## 3. State Management (Provider)

### 3.1. Global State
- Use `AppState` in `contexts/app_context.dart` for app-wide lifecycle states.
- Register global providers in `main.dart` using `MultiProvider`.

### 3.2. Local State
- Prefer `StatefulWidget` for UI-only state (e.g., current tab index, animation controllers).
- Avoid putting temporary UI state into global Providers.

## 4. Code Style & Best Practices

### 4.1. Formatting
- Use `dart format .` before committing.
- Follow trailing comma convention for multi-line parameters to improve formatting.

### 4.2. Null Safety
- Strictly avoid `!` (bang operator) unless absolutely necessary. Use `?` and null-coalescing (`??`) or `if (x != null)`.

### 4.3. Error Handling
- Wrap async service calls in `try-catch`.
- Use `debugPrint` for development logging instead of `print`.

### 4.4. Widgets
- Break large `build` methods into smaller private methods or separate widgets.
- Use `const` constructors wherever possible to optimize rebuilds.

## 5. Architectural Rules

- **YAGNI**: Don't implement features "just in case" (e.g., TopOn SDK was removed as it wasn't currently usable).
- **KISS**: Keep services focused on one task (e.g., `AudioService` only handles audio capture).
- **DRY**: Use `lib/theme/` constants instead of hardcoding colors/styles in widgets.

By following these standards, we aim to maintain a clean, consistent, and high-quality codebase for the `RecapIt` project.

