# Tudu - Project Status Tracker

**Objective:** Build a minimalist cross-platform notes application using Flutter, MVVM, and Firebase, maintaining zero unnecessary external dependencies.

## Phase 1: Project Setup & Infrastructure
- [x] Create Flutter project (iOS, Android)
- [x] Initialize Git repository
- [x] Configure Firebase (Auth & Firestore) via FlutterFire CLI
- [x] Update `pubspec.yaml` with Firebase dependencies
- [x] Define global theme (AppColors, Light/Dark mode) in `lib/app/theme.dart`
- [x] Setup basic `main.dart` entry point structure

## Phase 2: Data & Services Layer
- [x] Create `Note` data model (`lib/models/note.dart`)
- [x] Implement `AuthService` (`lib/services/auth_service.dart`) for Firebase Auth
- [x] Implement `NoteService` (`lib/services/note_service.dart`) for Firestore CRUD
- [x] Configure Firestore Security Rules

## Phase 3: State Management (ViewModels)
- [x] Implement `AuthViewModel` (`lib/viewmodels/auth_viewmodel.dart`)
- [x] Implement `NoteViewModel` (`lib/viewmodels/note_viewmodel.dart`)
- [x] Ensure ViewModels correctly use `ChangeNotifier` and handle loading/error states

## Phase 4: UI & Navigation
- [x] Implement global Auth Gate (`StreamBuilder` in `main.dart`)
- [x] Build `AuthScreen` (Login & Register tabs)
- [x] Build reusable widgets (`NoteCard`, `EmptyState`, `TuduTextField`)
- [x] Build `HomeScreen` (List of notes, Floating Action Button)
- [x] Build `NoteDetailScreen` (Create/Edit notes, Save, Delete)
- [x] Build `AboutScreen` (Static developer information)

## Phase 5: Polish & Finalization
- [ ] Test Firebase offline persistence
- [ ] Validate responsive layouts and input forms
- [ ] Perform manual testing on iOS simulator / physical device
- [ ] Perform manual testing on Android emulator / physical device
- [ ] Code cleanup and linting
