import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Public client configuration from the INTI Care Web registration in Firebase.
/// Configure additional platforms with FlutterFire before running on them.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'This project is configured for web. Run flutter run -d chrome.',
    );
  }

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyD-CkLgy9lSsEtVwAkilzbz-nO8hIzWo5A',
    appId: '1:985522310398:web:eac80f2d952d447cfd69af',
    messagingSenderId: '985522310398',
    projectId: 'inti-care',
    authDomain: 'inti-care.firebaseapp.com',
    storageBucket: 'inti-care.firebasestorage.app',
    measurementId: 'G-S8Q9JNTLD9',
  );
}
