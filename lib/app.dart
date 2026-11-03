import 'package:flutter/material.dart';

import 'core/config/firebase_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_gate.dart';

class Mak360App extends StatelessWidget {
  const Mak360App({super.key, required this.bootstrap});

  final FirebaseBootstrapResult bootstrap;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAK360',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: bootstrap.isReady
          ? const AuthGate()
          : FirebaseConfigurationScreen(message: bootstrap.errorMessage),
    );
  }
}
