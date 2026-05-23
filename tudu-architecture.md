# Tudu — Flutter Architecture

**App:** Notes · **Platform:** iOS + Android · **Language:** Dart · **UI:** Flutter · **Pattern:** MVVM
> ✅ One codebase, both platforms. Zero overkill dependencies.

---

## Philosophy

> If Flutter can do it, we don't add a package for it.

| Concern | Uses | Built-in? |
|---|---|---|
| State management | `ChangeNotifier` + `ListenableBuilder` | ✅ Yes |
| Navigation | `Navigator` + named routes | ✅ Yes |
| Models | Plain Dart classes | ✅ Yes |
| Auth + Database | Firebase | ❌ External (required) |

**Total added packages: 3** — `firebase_core`, `firebase_auth`, `cloud_firestore`. That's it.

---

## 1. Features

| Feature | Description |
|---|---|
| Create note | FAB → bottom sheet with title + body fields |
| Edit note | Tap any note → editable detail screen |
| Save note | Save button commits to Firestore |
| Delete note | Delete icon on detail screen → removes from Firestore |
| View all notes | Home screen — live list of all user notes |
| About page | Static screen listing the developers |

---

## 2. Project Structure

```
tudu/
├── lib/
│   ├── main.dart                   # Entry point + MaterialApp + auth gate
│   │
│   ├── models/
│   │   └── note.dart               # Plain Dart class, manual fromMap/toMap
│   │
│   ├── services/
│   │   ├── auth_service.dart       # Firebase Auth wrapper
│   │   └── note_service.dart       # Firestore CRUD + stream
│   │
│   ├── viewmodels/
│   │   ├── auth_viewmodel.dart     # ChangeNotifier
│   │   └── note_viewmodel.dart     # ChangeNotifier
│   │
│   ├── screens/
│   │   ├── auth_screen.dart        # Login + Register
│   │   ├── home_screen.dart        # View all notes
│   │   ├── note_detail_screen.dart # Edit + Delete + Save note
│   │   └── about_screen.dart       # Static developers page
│   │
│   └── widgets/
│       ├── note_card.dart          # Note preview tile
│       ├── empty_state.dart        # Shown when no notes exist
│       └── tudu_text_field.dart    # Reusable styled TextField
│
├── pubspec.yaml
└── firebase_options.dart
```

---

## 3. Data Model (`lib/models/note.dart`)

Plain Dart — no code generation, no annotations.

```dart
class Note {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id:        id,
      userId:    map['userId']    as String,
      title:     map['title']     as String,
      body:      map['body']      as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId':    userId,
    'title':     title,
    'body':      body,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  Note copyWith({String? title, String? body}) {
    return Note(
      id:        id,
      userId:    userId,
      title:     title     ?? this.title,
      body:      body      ?? this.body,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
```

---

## 4. Services

### `lib/services/auth_service.dart`

```dart
class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> register(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email, password: password,
    );
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email, password: password,
    );
  }

  Future<void> logout() => _auth.signOut();
}
```

### `lib/services/note_service.dart`

```dart
class NoteService {
  final _db = FirebaseFirestore.instance;

  // Real-time stream — all notes for a user, newest first
  Stream<List<Note>> notesStream(String userId) {
    return _db
      .collection('notes')
      .where('userId', isEqualTo: userId)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
        .map((d) => Note.fromMap(d.id, d.data()))
        .toList());
  }

  Future<void> createNote(Note note) {
    return _db.collection('notes').add(note.toMap());
  }

  Future<void> saveNote(Note note) {
    return _db.collection('notes').doc(note.id).update(note.toMap());
  }

  Future<void> deleteNote(String noteId) {
    return _db.collection('notes').doc(noteId).delete();
  }
}
```

---

## 5. State Management

**No Riverpod. No Provider package.** Flutter's built-in `ChangeNotifier` + `ListenableBuilder`.

### `lib/viewmodels/auth_viewmodel.dart`

```dart
class AuthViewModel extends ChangeNotifier {
  final _service = AuthService();

  bool isLoading = false;
  String? error;

  Stream<User?> get authStateChanges => _service.authStateChanges;

  Future<void> login(String email, String password) async {
    isLoading = true; error = null; notifyListeners();
    try {
      await _service.login(email, password);
    } on FirebaseAuthException catch (e) {
      error = e.message;
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    isLoading = true; error = null; notifyListeners();
    try {
      await _service.register(email, password);
    } on FirebaseAuthException catch (e) {
      error = e.message;
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> logout() => _service.logout();
}
```

### `lib/viewmodels/note_viewmodel.dart`

```dart
class NoteViewModel extends ChangeNotifier {
  final _service = NoteService();

  List<Note> _notes = [];
  bool isLoading = false;
  String? error;

  List<Note> get notes => _notes;

  void listen(String userId) {
    isLoading = true; notifyListeners();
    _service.notesStream(userId).listen((notes) {
      _notes    = notes;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> createNote(String userId, String title, String body) {
    final now  = DateTime.now();
    final note = Note(
      id:        '',               // Firestore assigns the ID
      userId:    userId,
      title:     title.trim(),
      body:      body.trim(),
      createdAt: now,
      updatedAt: now,
    );
    return _service.createNote(note);
  }

  Future<void> saveNote(Note note) => _service.saveNote(note);

  Future<void> deleteNote(String noteId) => _service.deleteNote(noteId);
}
```

### Wiring in `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TuduApp());
}

class TuduApp extends StatefulWidget {
  const TuduApp({super.key});
  @override
  State<TuduApp> createState() => _TuduAppState();
}

class _TuduAppState extends State<TuduApp> {
  final _authVM = AuthViewModel();
  final _noteVM = NoteViewModel();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tudu',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      // Auth gate — StreamBuilder replaces go_router redirect
      home: StreamBuilder<User?>(
        stream: _authVM.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            _noteVM.listen(snapshot.data!.uid);
            return HomeScreen(noteVM: _noteVM, authVM: _authVM);
          }
          return AuthScreen(authVM: _authVM);
        },
      ),
    );
  }
}
```

---

## 6. Navigation

**No go_router.** Flutter's built-in `Navigator.push`.

```dart
// Home → Note detail (edit existing)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => NoteDetailScreen(note: note, noteVM: noteVM),
  ),
);

// Home → About page
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const AboutScreen()),
);

// Logout — handled automatically:
// authVM.logout() triggers authStateChanges stream
// StreamBuilder in main.dart rebuilds to AuthScreen
```

---

## 7. Screen Specifications

### AuthScreen
- `DefaultTabController` — Login / Register tabs
- Login: email + password → `authVM.login()`
- Register: email + password → `authVM.register()`
- `ListenableBuilder` on `authVM` → shows spinner / inline error message

### HomeScreen *(View All Notes)*
- `AppBar` with app name + `AboutScreen` icon button (top right)
- `ListenableBuilder` on `noteVM` → rebuilds on any note change
- `ListView` of `NoteCard` widgets — shows title + body preview + `updatedAt`
- Tap note card → `NoteDetailScreen` (edit)
- `EmptyState` widget when `noteVM.notes` is empty
- `FloatingActionButton` → `showModalBottomSheet` with **Create Note** form
  - Title field + Body field + Save button
  - On save → `noteVM.createNote()` → sheet closes → list auto-updates

### NoteDetailScreen *(Edit + Save + Delete)*
- Pre-filled `TextFormField` for title and body
- `AppBar` actions:
  - 💾 Save `IconButton` → `noteVM.saveNote(note.copyWith(title, body))` → `Navigator.pop()`
  - 🗑 Delete `IconButton` → confirm dialog → `noteVM.deleteNote(note.id)` → `Navigator.pop()`
- No auto-save — user explicitly taps Save

### AboutScreen *(Static — no Firebase, no ViewModel)*
- App name + version
- Short app description
- **Developers** section — list of developer names, roles, and contact info
- Back arrow navigates to HomeScreen

---

## 8. Key Operations

| Operation | Method |
|---|---|
| Register | `authVM.register(email, password)` |
| Login | `authVM.login(email, password)` |
| Logout | `authVM.logout()` |
| Stream notes | `noteVM.listen(userId)` — called once on login |
| Create note | `noteVM.createNote(userId, title, body)` |
| Save / edit note | `noteVM.saveNote(note.copyWith(title, body))` |
| Delete note | `noteVM.deleteNote(noteId)` |

---

## 9. Persistence & Backend

**Firebase — Authentication + Firestore**

```
/notes/{noteId}
  userId:    String       ← links note to its owner
  title:     String
  body:      String
  createdAt: Timestamp
  updatedAt: Timestamp    ← used for sort order
```

**Firestore Security Rules**

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notes/{noteId} {
      allow read, write: if request.auth != null
        && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

Offline persistence is on by default — notes load from local cache instantly, sync when reconnected.

---

## 10. Color Scheme

A warm, earthy tone.

### Brand Palette

| Token | Light Mode | Dark Mode | Usage |
|---|---|---|---|
| `primary` | `#EA580C` (Orange 600) | `#FB923C` (Orange 400) | Buttons, FAB, active tabs |
| `secondary` | `#0D9488` (Teal 600) | `#2DD4BF` (Teal 400) | Accent, icons |
| `surface` | `#FFFFFF` | `#1C1917` (Stone 900) | Cards, sheets |
| `background` | `#FFF7ED` (Orange 50) | `#0C0A09` (Near Black) | App background |
| `outline` | `#FED7AA` (Orange 200) | `#292524` (Stone 800) | Borders, dividers |
| `error` | `#DC2626` | `#F87171` | Errors, delete actions |

### Implementation (`lib/app/theme.dart`)

```dart
class AppColors {
  static const primary        = Color(0xFFEA580C);
  static const primaryDark    = Color(0xFFFB923C);
  static const secondary      = Color(0xFF0D9488);
  static const secondaryDark  = Color(0xFF2DD4BF);

  static const background     = Color(0xFFFFF7ED);
  static const backgroundDark = Color(0xFF0C0A09);
  static const surface        = Color(0xFFFFFFFF);
  static const surfaceDark    = Color(0xFF1C1917);

  static const textPrimary    = Color(0xFF1C1917);
  static const textDark       = Color(0xFFFAFAF9);
  static const textSecondary  = Color(0xFF78716C);

  static const outline        = Color(0xFFFED7AA);
  static const outlineDark    = Color(0xFF292524);

  static const error          = Color(0xFFDC2626);
}

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary:   AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    surface:   AppColors.surface,
    error:     AppColors.error,
    outline:   AppColors.outline,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.outline),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary:   AppColors.primaryDark,
    onPrimary: Colors.white,
    secondary: AppColors.secondaryDark,
    surface:   AppColors.surfaceDark,
    error:     const Color(0xFFF87171),
    outline:   AppColors.outlineDark,
  ),
  scaffoldBackgroundColor: AppColors.backgroundDark,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.textDark,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surfaceDark,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.outlineDark),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  ),
);
```

Wire into `main.dart`:

```dart
MaterialApp(
  theme: lightTheme,
  darkTheme: darkTheme,
  themeMode: ThemeMode.system,
  ...
)
```

---

## 11. Module Responsibilities

| Module | Responsibility |
|---|---|
| `models/note.dart` | Plain Dart class — `fromMap`, `toMap`, `copyWith`. No logic. |
| `services/` | Firebase wrappers only — no business logic. |
| `viewmodels/` | `ChangeNotifier` — state, loading, error, all note operations. |
| `screens/` | Presentation only. Reads viewmodel, calls viewmodel methods. |
| `widgets/` | Reusable UI with no viewmodel dependency. |

---

## 12. `pubspec.yaml`

```yaml
name: tudu
description: A simple notes app.

dependencies:
  flutter:
    sdk: flutter

  # The only 3 external packages
  firebase_core: ^3.x.x
  firebase_auth: ^5.x.x
  cloud_firestore: ^5.x.x

dev_dependencies:
  flutter_test:
    sdk: flutter
```

---

## 13. System Requirements

| Tool | Version |
|---|---|
| Flutter | 3.41.1 (stable channel) |
| Dart | 3.11.0 |
| DevTools | 2.54.1 |

### iOS — Direct Device Install (Free Apple ID)

| Requirement | Notes |
|---|---|
| macOS Ventura (13)+ | Required to run Xcode |
| Xcode — latest stable or beta | Free from Mac App Store |
| CocoaPods — latest | `sudo gem install cocoapods` |
| iPhone running iOS 13+ | Flutter 3.41 supports iOS 13–26 |

App expires every **7 days**. Reinstall: `flutter run --release`.

### Android

| Requirement | Version |
|---|---|
| Android Studio | Latest stable |
| `minSdkVersion` | 24 |
| `targetSdkVersion` | 36 |
| JDK | 17 |

---

## 14. GitHub & Setup

```bash
# 1. Create project
flutter create tudu --platforms=ios,android
cd tudu

# 2. Push to GitHub
git init && git add . && git commit -m "initial commit"
git remote add origin https://github.com/yourusername/tudu.git
git branch -M main && git push -u origin main

# 3. Configure Firebase
dart pub global activate flutterfire_cli
flutterfire configure

# 4. Install dependencies
flutter pub get

# 5a. Run on Android
flutter run

# 5b. Run on iPhone
cd ios && pod install && cd ..
open ios/Runner.xcworkspace   # set Team → hit Run ▶
```

### After Fresh Clone

```bash
git clone https://github.com/yourusername/tudu.git
cd tudu
flutter pub get
flutterfire configure    # re-generates firebase_options.dart
cd ios && pod install && cd ..
flutter run
```

### `.gitignore` — Key Entries

```
google-services.json
GoogleService-Info.plist
firebase_options.dart
ios/Pods/
build/
.dart_tool/
```
