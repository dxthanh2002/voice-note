# Code Standards and Conventions

This document outlines the coding standards, naming conventions, file organization, state management guidelines, and code style rules for the `RecapIt` project. Adhering to these guidelines ensures consistency, readability, and maintainability across the codebase.

## 1. Naming Conventions

### 1.1. Files and Directories
-   **Files**: `snake_case.dart` (e.g., `api_client.dart`, `app_theme.dart`).
-   **Directories**: `snake_case/` (e.g., `components/`, `screens/`, `services/`).

### 1.2. Classes and Enums
-   **Classes**: `PascalCase` (e.g., `AppState`, `ApiClient`, `RecordDetailScreen`).
-   **Enums**: `PascalCase` for the enum type, `UPPER_SNAKE_CASE` for enum values (e.g., `enum Status { LOADING, SUCCESS, ERROR }`).

### 1.3. Variables and Fields
-   **Local Variables**: `camelCase` (e.g., `recordingTitle`, `isRecording`).
-   **Private Fields/Variables**: `_camelCase` (prefixed with an underscore).
-   **Public Fields/Variables**: `camelCase`.
-   **Constants**: `kPascalCase` for globally accessible constants (e.g., `kPrimaryColor`), `UPPER_SNAKE_CASE` for class-level or private constants (e.g., `_DEFAULT_TIMEOUT`).

### 1.4. Functions and Methods
-   **Functions/Methods**: `camelCase` (e.g., `startRecording()`, `_saveRecording()`).

## 2. File Organization Patterns

### 2.1. Feature-First Structure
The `lib/` directory is organized into logical modules, primarily by concern:

-   `main.dart`: Application entry point.
-   `components/`: Reusable, generic UI widgets that are not full screens (e.g., `screen.dart`).
-   `constants/`: Application-wide constants (e.g., URLs).
-   `contexts/`: State management related files (e.g., `app_context.dart` for `AppState`).
-   `data/`: Data models and mock data (e.g., `mock_recordings.dart`).
-   `models/`: API response base class and profile user models (e.g., `base_response.dart`, `profile_user.dart`).
-   `navigation/`: Files related to app navigation and routing (e.g., `app_routes.dart`, `app_navigator.dart`).
-   `screens/`: UI components that represent entire pages/screens of the application, further categorized by feature:
    -   `auth/`: Authentication-related screens (e.g., `login_screen.dart`).
    -   `main/`: Main application tabs and their content (e.g., `main_tabs_screen.dart`, `recordings_tab.dart`, `settings_tab.dart`).
    -   `onboarding/`: Onboarding flow screens (e.g., `onboarding_screen.dart`).
    -   `recording/`: Recording-specific screens and sheets (e.g., `active_record_screen.dart`, `create_record_sheet.dart`, `record_detail_screen.dart`).
-   `services/`: Business logic, API interaction, local storage, and app initialization (e.g., `api_client.dart`, `storage.dart`, `app_bootstrap.dart`).
-   `theme/`: Theming-related files (colors, typography, spacing).
-   `utils/`: General utility functions (e.g., `device.dart`, `file.dart`).
-   `widgets/`: Reusable UI widgets.

### 2.2. Single Responsibility Principle
Each file, class, and function should ideally have a single, well-defined responsibility.

## 3. State Management Guidelines (Provider with ChangeNotifierProvider)

### 3.1. AppState (`contexts/app_context.dart`)
-   The `AppState` class (`ChangeNotifier`) should encapsulate global application state and business logic that affects multiple parts of the application (e.g., `booted`, `onboarded` states).
-   Avoid putting UI-specific state here.
-   All state modifications should happen within `AppState` methods, which then call `notifyListeners()` to update consumers.

### 3.2. Provider Usage
-   Use `ChangeNotifierProvider` at the root of the widget tree (or higher-up if needed) to provide `AppState`.
-   Access state using `Provider.of<AppState>(context, listen: true)` for widgets that need to rebuild on state changes.
-   Use `Provider.of<AppState>(context, listen: false)` or `context.read<AppState>()` for dispatching actions without needing to rebuild.
-   For local, widget-specific state, prefer `StatefulWidget` or other local state management solutions to avoid bloating `AppState`.

## 4. Code Style Rules

### 4.1. Dart Formatting
-   Adhere to the official Dart style guide. Use `dart format .` to automatically format code.
-   Line length: Aim for a maximum of 80 characters per line. Break long lines appropriately.

### 4.2. Imports
-   Organize imports into three groups, separated by a blank line:
    1.  Dart SDK imports.
    2.  Package imports.
    3.  Project-specific (relative) imports.
-   Use `package:` imports for project-specific files where possible to avoid long relative paths.
-   Use `show` or `hide` clauses for specific imports to avoid naming conflicts.

### 4.3. Comments
-   Use `///` for documentation comments on public APIs (classes, methods, fields).
-   Use `//` for inline comments explaining complex logic or unusual choices.
-   Avoid excessive commenting for self-explanatory code.

### 4.4. Error Handling
-   Use `try-catch` blocks for asynchronous operations that might fail (e.g., API calls).
-   Propagate errors appropriately or handle them gracefully with user feedback.
-   Define custom exception classes for specific application errors.

### 4.5. Null Safety
-   Embrace Dart's null safety features.
-   Declare variables as non-nullable unless they are explicitly designed to be nullable.
-   Use `?` for nullable types and `!` for null assertion (sparingly, when sure).

### 4.6. Widget Structure
-   Prefer `StatelessWidget` when no mutable state is required.
-   Break down complex widgets into smaller, focused widgets to improve readability and reusability.
-   Extract `build` methods into separate private methods when they become too large.

### 4.7. Asynchronous Programming
-   Use `async`/`await` for asynchronous operations.
-   Handle futures and streams correctly, considering loading, success, and error states.

### 4.8. Assets
-   Ensure all assets (images, fonts) are properly declared in `pubspec.yaml`.
-   Refer to assets using constant paths.

By following these standards, we aim to maintain a clean, consistent, and high-quality codebase for the `RecapIt` project.

