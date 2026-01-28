import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'src/components/LoginPage.dart';
import 'src/components/SIgnupPage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/pages/app_mode_switcher.dart';
import 'services/user_session.dart';
import 'services/user_presence_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  runApp(const FixRightApp());
}

class FixRightApp extends StatefulWidget {
  const FixRightApp({super.key});

  @override
  State<FixRightApp> createState() => _FixRightAppState();
}

class _FixRightAppState extends State<FixRightApp> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserPresenceService _presenceService = UserPresenceService();
  bool _hasInitializedPresence = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize presence if user is already logged in
    _initializePresenceIfNeeded();
  }

  /// Initialize presence for authenticated users
  /// Ensures presence is set on app startup
  Future<void> _initializePresenceIfNeeded() async {
    if (_auth.currentUser != null && !_hasInitializedPresence) {
      _hasInitializedPresence = true;
      await _presenceService.initializePresence();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Mark user as offline when app closes
    _presenceService.updatePresence(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground - mark as online
        _presenceService.updatePresence(true);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App is in background or closing - mark as offline
        _presenceService.updatePresence(false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2B7CD3);

    final theme = ThemeData(
      primaryColor: primaryBlue,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue),
      scaffoldBackgroundColor: const Color(0xFFE9F2FB),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );

    return MaterialApp(
      title: 'FixRight',
      debugShowCheckedModeBanner: false,
      theme: theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const AppModeSwitcher(),
        '/signup': (context) => const SignupScreen(),
      },
      navigatorObservers: [_RouteObserver()],
    );
  }
}

/// Observer to track navigation and manage user session
class _RouteObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    // Handle logout when navigating back to login
    if (previousRoute?.settings.name == '/' && route.settings.name != '/') {
      UserSession().clearSession();
    }
  }
}
