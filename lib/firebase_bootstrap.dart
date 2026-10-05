import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

/// Default: **real Firebase** (production) for physical devices.
///
/// Free Spark project `solar-clean-app` — no billing / no Identity Platform.
///
/// Optional local emulators (PC only; not needed on phone):
///   flutter run --dart-define=USE_FIREBASE_EMULATOR=true
///   flutter run --dart-define=USE_FIREBASE_EMULATOR=true --dart-define=FIREBASE_EMU_HOST=192.168.x.x
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool usingEmulator = false;

  /// Default false = phone talks to real Firebase.
  static const bool _wantEmulator =
      bool.fromEnvironment('USE_FIREBASE_EMULATOR', defaultValue: false);

  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (!_wantEmulator) {
      usingEmulator = false;
      return;
    }

    final host = const String.fromEnvironment(
      'FIREBASE_EMU_HOST',
      defaultValue: '',
    );
    final resolved = host.isNotEmpty
        ? host
        : ((!kIsWeb && Platform.isAndroid) ? '10.0.2.2' : '127.0.0.1');

    await FirebaseAuth.instance.useAuthEmulator(resolved, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(resolved, 8080);
    usingEmulator = true;
    debugPrint('Firebase emulators: auth/firestore @ $resolved');
  }
}
