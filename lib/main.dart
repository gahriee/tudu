import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'app/theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/note_viewmodel.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      title: 'Recall',
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
          
          _noteVM.clear();
          return AuthScreen(authVM: _authVM);
        },
      ),
    );
  }
}
