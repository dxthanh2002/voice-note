# RecapIt - Project Documentation Index

**Updated:** 2026-01-15 | **Environment:** Flutter 3.9.2 | **Project Type:** AI-Powered Meeting Recorder

---

## Project Overview

- **Name:** RecapIt (AI Meeting Recorder)
- **Architecture:** Clean Architecture with Service Layer
- **State Management:** Provider with ChangeNotifier
- **Platform:** iOS (13.0+) & Android (API 33+)

---

## Core Documentation

### Strategic Documents
- [README](../README.md) - Project landing and quick start
- [Project Overview PDR](./project-overview-pdr.md) - Features, requirements, and limitations (TopOn status)
- [Project Roadmap](./project-roadmap.md) - Status and upcoming AI/Monetization tasks

### Technical Reference
- [System Architecture](./system-architecture.md) - Layered design and data flows
- [Codebase Summary](./codebase-summary.md) - Directory structure and file responsibilities
- [Code Standards](./code-standards.md) - Naming conventions and best practices
- [Deployment Guide](./deployment-guide.md) - Build process and platform setup

### Design & UI
- [Design Guidelines](./design-guidelines.md) - Colors, Typography, and UI patterns
- [Component Inventory](./component-inventory.md) - Catalog of reusable widgets

---

## Directory Map

```text
recapit/
├── lib/
│   ├── main.dart                  # App Entry & Provider Setup
│   ├── components/                # Shared UI Components
│   ├── contexts/                  # Global AppState
│   ├── models/                    # Data Models (Audio, Meeting, etc.)
│   ├── screens/                   # Feature-based UI
│   │   ├── auth/                  # Social Login
│   │   ├── recording/             # Active Recording & AI Analysis
│   │   └── onboarding/            # First-run Walkthrough
│   ├── services/                  # Business Logic (Audio, Repository)
│   └── theme/                     # Colors, Typography, AppTheme
├── android/                       # Native Android (Gradle 8.12)
├── ios/                           # Native iOS (CocoaPods)
└── assets/                        # Images (bg_app.png) & Fonts (Inter)
```

---

## Critical Knowledge

1. **Ad SDK Status**: The TopOn SDK is currently disabled due to Flutter embedding conflicts. Do not re-enable without migration.
2. **Audio Storage**: Android 11+ uses `/Recordings/Recapit/` for public access to recordings.
3. **AI Integration**: AI tabs (Chat, Summary) are UI-ready; backend hooks are being finalized.
4. **Theming**: Use `AppColors` and `AppTypography`. The app is designed as "Dark-First".

---
*Documentation maintained by docs-manager agent*
