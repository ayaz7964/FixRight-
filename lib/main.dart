import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'src/components/LoginPage.dart';
import 'src/components/SIgnupPage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/pages/app_mode_switcher.dart';
import 'services/user_session.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updatePresence(true); // Set online when app starts
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updatePresence(false); // Set offline when app closes
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground
        _updatePresence(true);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // App is in background or closing
        _updatePresence(false);
        break;
      case AppLifecycleState.hidden:
        // App is hidden (Flutter 3.13+)
        _updatePresence(false);
        break;
    }
  }

  /// Update user presence status in Firestore
  Future<void> _updatePresence(bool isOnline) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final phoneUID = currentUser.phoneNumber;
      if (phoneUID == null || phoneUID.isEmpty) return;

      final updates = <String, dynamic>{
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      };

      if (!isOnline) {
        updates['status'] = 'offline';
      } else {
        updates['status'] = 'online';
      }

      await _firestore.collection('users').doc(phoneUID).update(updates);
      
      print('Presence updated: ${isOnline ? "Online" : "Offline"} for $phoneUID');
    } catch (e) {
      print('Error updating presence: $e');
      // Silently fail - don't crash app if presence update fails
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
