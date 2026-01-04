// lib/src/pages/app_mode_switcher.dart (or wherever you put it)

import 'package:flutter/material.dart';
import 'ClientMainSCreen.dart';
import 'seller_main_screen.dart'; // We will create this

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
    // This is the primary conditional switch for the entire view
    if (_isSellerMode) {
      // If Seller Mode is ON, show the Seller's full navigation
      return SellerMainScreen(
        isSellerMode: _isSellerMode,
        onToggleMode: _toggleAppMode,
      );
    } else {
      // If Seller Mode is OFF, show the Client's full navigation
      return ClientMainScreen(
        isSellerMode: _isSellerMode,
        onToggleMode: _toggleAppMode,
      );
    }
  }
}