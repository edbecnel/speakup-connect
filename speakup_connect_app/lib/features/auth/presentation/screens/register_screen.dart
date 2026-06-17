// Standalone register screen (also accessible from login tab).
// The primary register flow is via the tab switcher in LoginScreen.
// This screen is used when navigating directly to /register.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';

export 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to login screen and open the Sign Up tab
    // The Login screen handles both Login and Sign Up via tabs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(Routes.login);
    });
    return const Scaffold(body: SizedBox.shrink());
  }
}
