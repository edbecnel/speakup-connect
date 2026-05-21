import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/app.dart';
import 'package:speakup_connect/config/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase — all platforms are configured except Linux.
  final bool firebaseSupported = defaultTargetPlatform != TargetPlatform.linux;

  if (firebaseSupported) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    // ProviderScope is the root of the Riverpod dependency graph.
    // All providers defined in the app are accessible within this scope.
    const ProviderScope(
      child: SpeakUpConnectApp(),
    ),
  );
}
