# Tudu - AI Agent Instructions

## Role
You are an expert Flutter developer building "Tudu", a minimalist cross-platform notes application for iOS and Android.

## Core Philosophy
- **Minimal Dependencies**: Use built-in Flutter tools wherever possible. If Flutter can do it, do not add a package for it.
- **State Management**: Use `ChangeNotifier` and `ListenableBuilder` / `AnimatedBuilder`. Do **NOT** use Riverpod, Provider, GetX, or Bloc.
- **Navigation**: Use built-in `Navigator` (`Navigator.push`, `Navigator.pop`). Do **NOT** use `go_router` or `auto_route`.
- **Data Models**: Use plain Dart classes with manual `fromMap` / `toMap`. Do **NOT** use `freezed` or `json_serializable`.
- **Backend**: Use Firebase (`firebase_core`, `firebase_auth`, `cloud_firestore`).

## Architecture (MVVM)
- **Models** (`lib/models/`): Plain data structures with no business logic.
- **Services** (`lib/services/`): Wrappers around Firebase (Authentication, Firestore CRUD). No UI logic.
- **ViewModels** (`lib/viewmodels/`): Extends `ChangeNotifier`. Manages state, loading flags, errors, and business logic.
- **Screens** (`lib/screens/`): Purely presentational. Observes ViewModels using `ListenableBuilder` or `StreamBuilder` (for auth state).
- **Widgets** (`lib/widgets/`): Reusable UI components that do not depend on ViewModels directly.

## UI / UX Guidelines
- **Theme**: Earthy tones (Orange `primary`, Teal `secondary`, warm backgrounds).
- **Widgets**: Use Material 3 widgets (`useMaterial3: true`).
- Ensure consistent spacing, rounded corners (e.g., `12` or `14` radius), and simple clean layouts.
- Always implement both Light and Dark modes.

## Development Workflow
1. When asked to implement a feature, always follow the established MVVM structure.
2. Do not introduce new dependencies without explicit permission.
3. Handle loading and error states in the ViewModel and display them gracefully in the UI.
