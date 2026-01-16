// lib/src/pages/app_mode_switcher.dart (or wherever you put it)

import 'package:flutter/material.dart';
import 'ClientMainSCreen.dart';
import 'seller_main_screen.dart'; // We will create this
import '../../services/user_session.dart';

class AppModeSwitcher extends StatefulWidget {
  const AppModeSwitcher({super.key});

  @override
  State<AppModeSwitcher> createState() => _AppModeSwitcherState();
}

class _AppModeSwitcherState extends State<AppModeSwitcher> {
  // Central State for the entire app mode (Client = false, Seller = true)
  bool _isSellerMode = false;

  // Callback function passed down to the ProfileScreen
  void _toggleAppMode(bool newValue) {
    setState(() {
      _isSellerMode = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the authenticated user's phone UID from UserSession
    final phoneUID = UserSession().phoneUID;

    // If user is not authenticated, redirect to login
    if (!UserSession().isAuthenticated || phoneUID == null) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // This is the primary conditional switch for the entire view
    if (_isSellerMode) {
      // If Seller Mode is ON, show the Seller's full navigation
      return SellerMainScreen(
        isSellerMode: _isSellerMode,
        onToggleMode: _toggleAppMode,
        phoneUID: phoneUID,
      );
    } else {
      // If Seller Mode is OFF, show the Client's full navigation
      return ClientMainScreen(
        
        isSellerMode: _isSellerMode,
        onToggleMode: _toggleAppMode,
        phoneUID: phoneUID,
      );
    }
  }
}