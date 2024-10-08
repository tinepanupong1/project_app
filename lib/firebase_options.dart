// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC0k8a3W3f6Ey90s4KEH_nrvdlHxrLo0tc',
    appId: '1:731506531014:web:1c2e116356b9313d8e95c7',
    messagingSenderId: '731506531014',
    projectId: 'projectauthentication-f9091',
    authDomain: 'projectauthentication-f9091.firebaseapp.com',
    storageBucket: 'projectauthentication-f9091.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCtBTkhUodjc5hr9HWnfcyMZuCUqDhLlDI',
    appId: '1:731506531014:android:6a942d1768e017de8e95c7',
    messagingSenderId: '731506531014',
    projectId: 'projectauthentication-f9091',
    storageBucket: 'projectauthentication-f9091.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAZLH0MDstaVbOCD2o_TEJrUPuB92mJAlA',
    appId: '1:731506531014:ios:8ef331d97e9a9c9c8e95c7',
    messagingSenderId: '731506531014',
    projectId: 'projectauthentication-f9091',
    storageBucket: 'projectauthentication-f9091.appspot.com',
    iosBundleId: 'com.example.projectApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAZLH0MDstaVbOCD2o_TEJrUPuB92mJAlA',
    appId: '1:731506531014:ios:ffe300f512746b738e95c7',
    messagingSenderId: '731506531014',
    projectId: 'projectauthentication-f9091',
    storageBucket: 'projectauthentication-f9091.appspot.com',
    iosBundleId: 'com.example.projectApp.RunnerTests',
  );
}
