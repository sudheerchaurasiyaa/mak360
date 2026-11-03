import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FirebaseBootstrapResult {
  const FirebaseBootstrapResult._({required this.isReady, this.errorMessage});

  const FirebaseBootstrapResult.ready() : this._(isReady: true);

  const FirebaseBootstrapResult.failed(String message)
    : this._(isReady: false, errorMessage: message);

  final bool isReady;
  final String? errorMessage;
}

abstract final class FirebaseBootstrap {
  static Future<FirebaseBootstrapResult> initialize() async {
    try {
      await Firebase.initializeApp();
      return const FirebaseBootstrapResult.ready();
    } catch (error) {
      return FirebaseBootstrapResult.failed(
        'Firebase is not configured on this build. Add the Android '
        'google-services.json downloaded from Firebase project “mak360” to '
        'android/app/google-services.json, then rebuild.\n\n$error',
      );
    }
  }
}

class FirebaseConfigurationScreen extends StatelessWidget {
  const FirebaseConfigurationScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_outlined,
                      size: 56,
                      color: AppColors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Firebase setup required',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message ?? 'The Firebase configuration is missing.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
