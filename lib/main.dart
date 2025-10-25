import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './src/pages/ClientMainScreen.dart';
// Import your pages
import 'src/pages/home_page.dart'; // The HomePage we built
// import 'src/pages/login_page.dart'; // Uncomment when you create LoginPage

void main() {
  runApp(const FixRightApp());
}

class FixRightApp extends StatelessWidget {
  const FixRightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixRight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      // Start the app directly on HomePage
      initialRoute: '/',
      routes: {
        '/home': (context) => const ClientMainScreen(),
        '/': (context) => const LoginPage(), // temp route
      },
    );
  }
}

// Temporary LoginPage (you can replace this later with a real one)
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: const Text('Login and go to Home'),
        ),
      ),
    );
  }
}
