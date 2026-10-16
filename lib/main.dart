import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app/app.dart';
import 'core/constants/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Enable Firestore offline persistence (built-in — handles offline natively)
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    runApp(
      const ProviderScope(
        child: InterneeLmsApp(),
      ),
    );
  } catch (e) {
    // Firebase init failed — show friendly error screen with retry
    runApp(
      ProviderScope(
        child: FirebaseErrorScreen(
          message: e.toString(),
        ),
      ),
    );
  }
}

/// Shown when Firebase fails to initialize (no internet on first launch, etc.)
class FirebaseErrorScreen extends StatelessWidget {
  final String message;

  const FirebaseErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📚', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Firebase init failed',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Restart the app
                    main();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(AppStrings.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
