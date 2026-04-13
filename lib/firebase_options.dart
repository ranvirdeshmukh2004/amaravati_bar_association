// File generated manually based on user provided Web Config
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'please run flutterfire configure again if you need iOS support.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'please run flutterfire configure again if you need macOS support.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'please run flutterfire configure again if you need Linux support.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBZrLX2XuRVvjt29Z_X6H-5gPQPbHczG2g',
    appId: '1:406712023558:web:14ea7be4d0bcde7763a187',
    messagingSenderId: '406712023558',
    projectId: 'adba-subsciptionapp',
    authDomain: 'adba-subsciptionapp.firebaseapp.com',
    storageBucket: 'adba-subsciptionapp.firebasestorage.app',
    measurementId: 'G-R4EZ11WL2Q',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBZrLX2XuRVvjt29Z_X6H-5gPQPbHczG2g',
    appId: '1:406712023558:web:14ea7be4d0bcde7763a187',
    messagingSenderId: '406712023558',
    projectId: 'adba-subsciptionapp',
    authDomain: 'adba-subsciptionapp.firebaseapp.com',
    storageBucket: 'adba-subsciptionapp.firebasestorage.app',
    measurementId: 'G-R4EZ11WL2Q',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBZrLX2XuRVvjt29Z_X6H-5gPQPbHczG2g',
    appId: '1:406712023558:web:14ea7be4d0bcde7763a187',
    messagingSenderId: '406712023558',
    projectId: 'adba-subsciptionapp',
    authDomain: 'adba-subsciptionapp.firebaseapp.com',
    storageBucket: 'adba-subsciptionapp.firebasestorage.app',
    measurementId: 'G-R4EZ11WL2Q',
  );
}
