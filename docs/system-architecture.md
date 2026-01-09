# System Architecture

This document describes the high-level system architecture of the `RecapIt` mobile application, detailing its main components, their relationships, data flow, and API integration patterns.

## 1. High-Level Architecture Diagram (Text-based)

```
+-------------------+      +-------------------+      +-------------------+
|                   |      |                   |      |                   |
|   User Interface  | <--> |   State Management| <--> |   Business Logic  |
|  (Screens/Widgets)|      |   (Provider/AppS) |      |   (Services)      |
|                   |      |                   |      |                   |
+-------------------+      +-------------------+      +-------------------+
        ^                          ^     ^                          ^
        |                          |     |                          |
        |                          V     V                          |
        |                  +-------------------+                  |
        |                  |                   |                  |
        |                  | Local Data Storage|                  |
        |                  |  (SharedPreferences)|                 |
        |                  |                   |                  |
        |                  +-------------------+                  |
        |                                                         |
        |                                                         |
        +---------------------------------------------------------+
                                    |
                                    V
                          +-------------------+
                          |                   |
                          |    API Client     |
                          |    (Dio)          |
                          |                   |
                          +-------------------+
                                    |
                                    V
                          +-------------------+
                          |                   |
                          |    Backend API    |
                          | (External Service)|
                          |                   |
                          +-------------------+
```

## 2. Component Relationships

The `RecapIt` application employs a layered architecture to ensure separation of concerns and maintainability.

-   **User Interface (UI Layer)**:
    -   **Screens (`lib/screens/`)**: Full-page UI components that users interact with, categorized by feature (e.g., `auth/`, `main/`, `onboarding/`, `recording/`).
    -   **Widgets (`lib/widgets/`, `lib/components/`)**: Reusable UI building blocks used across screens.
    -   **Theme (`lib/theme/`)**: Provides consistent styling (colors, typography, spacing) for the entire UI.

-   **State Management Layer**:
    -   **AppState (`lib/contexts/app_context.dart`)**: A central `ChangeNotifier` that holds the global application state (e.g., `booted`, `onboarded` status). Screens and widgets consume this state via `Provider`. It orchestrates data fetching and updates by interacting with the Business Logic layer.

-   **Business Logic Layer**:
    -   **Services (`lib/services/`)**: Contains application-specific business logic and integrations.
        -   **App Bootstrap (`lib/services/app_bootstrap.dart`)**: Handles initial application setup, data loading, and service initialization.
    -   **Models (`lib/models/`)**: Defines the data structures (e.g., `ProfileUser`, `BaseResponse`) and mock recording data (`lib/data/mock_recordings.dart`) used throughout the application, ensuring type safety and consistency.

-   **Data Access Layer**:
    -   **API Client (`lib/services/api_client.dart`)**: Built with `Dio`, this component is responsible for making HTTP requests to the backend API, handling request/response serialization/deserialization, and managing errors related to network communication.
    -   **Local Data Storage (`lib/services/storage.dart`)**: Utilizes `SharedPreferences` for persistent storage of simple key-value pairs (e.g., user preferences, authentication tokens).

-   **Navigation Layer**:
    -   **App Navigator (`lib/navigation/app_navigator.dart`)**: Manages the flow between different screens, handling route pushing, popping, and replacement.
    -   **App Routes (`lib/navigation/app_routes.dart`)**: Defines a centralized list of all named routes used in the application.

## 3. Data Flow

1.  **User Interaction**: A user interacts with a UI element (e.g., taps a 'Start Recording' button on `CreateRecordSheet`).
2.  **UI Event to State**: The UI dispatches an action or calls a method on the `AppState` (via `Provider.of<AppState>(context, listen: false)` or `context.read`). For recording specific actions, direct service calls might be made.
3.  **State to Business Logic**: `AppState` (or relevant UI logic) interacts with various services (e.g., `StorageService` for preferences, `ApiClient` for authentication/user profile).
4.  **API Interaction**: If remote data is needed (e.g., user login, future recording metadata upload), `API Client` makes an HTTP request to the `Backend API`.
5.  **Backend Response**: The `Backend API` processes the request and sends a response back to the `API Client`.
6.  **Data Processing & Model Mapping**: `API Client` receives the raw data, potentially parses it, and maps it to the appropriate data `models/`.
7.  **Data back to State/UI**: The processed data is returned to `AppState` or directly to the UI, triggering necessary updates.
8.  **Local Storage/Permissions**: Recording functionality directly interacts with device services like microphone access (via `permission_handler`) and local file storage for audio. Recording metadata is managed within the app's state.
9.  **State Update & UI Rebuild**: `AppState` updates its internal state and calls `notifyListeners()`. All widgets consuming `AppState` (with `listen: true`) rebuild to reflect the new data.

## 4. API Integration Pattern

The application integrates with a backend API using the following pattern:

-   **Dedicated API Client**: `lib/services/api_client.dart` uses the `Dio` package to manage all HTTP communications.
    -   **Base URL & Headers**: Configurable base URL, authentication headers (e.g., Bearer token) are managed by `Dio` interceptors.
    -   **Request/Response Interceptors**: Used for logging, error handling, adding authentication tokens, and transforming requests/responses.
    -   **Error Handling**: Centralized error handling within `ApiClient` to convert raw API errors into application-specific exceptions or user-friendly messages.
-   **Service Abstraction**: Direct API calls are typically handled by services (e.g., for authentication). Data for recordings is primarily local initially, with future plans for API integration for storage and AI analysis.
-   **Data Models**: API responses for user profiles and generic responses are deserialized into strongly typed Dart objects defined in `lib/models/`. Recording data is currently managed via a local model in `lib/data/mock_recordings.dart`.
-   **Authentication**: Authentication tokens (e.g., JWTs) are typically stored securely using `SharedPreferences` (`lib/services/storage.dart`) and are automatically attached to outgoing API requests via `Dio` interceptors.
-   **URL Constants**: API endpoints are defined as constants in `lib/constants/urls.dart` to prevent hardcoding and improve maintainability.

