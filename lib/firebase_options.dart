// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyDWvYftb8PxGiYyq5uAkYI0FdfsQ6YwpT0',
    appId: '1:604370164738:web:1bec4a770ee9cc3523db1b',
    messagingSenderId: '604370164738',
    projectId: 'cenkirpall-afbe9',
    authDomain: 'cenkirpall-afbe9.firebaseapp.com',
    storageBucket: 'cenkirpall-afbe9.appspot.com',
    measurementId: 'G-STZ2PJE89T',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC2wKL9m-l7LyfqZ4faVLxf12VuzzCtk4I',
    appId: '1:604370164738:android:2461d5e4d43de10623db1b',
    messagingSenderId: '604370164738',
    projectId: 'cenkirpall-afbe9',
    storageBucket: 'cenkirpall-afbe9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDqcSXixVeHi0buz2aV8R1NaK9FLEjE530',
    appId: '1:604370164738:ios:9450334f5c8181cb23db1b',
    messagingSenderId: '604370164738',
    projectId: 'cenkirpall-afbe9',
    storageBucket: 'cenkirpall-afbe9.appspot.com',
    androidClientId: '604370164738-1rejn4vsvi2onnadjf32bg3up82omh8b.apps.googleusercontent.com',
    iosBundleId: 'com.example.touna',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDqcSXixVeHi0buz2aV8R1NaK9FLEjE530',
    appId: '1:604370164738:ios:9450334f5c8181cb23db1b',
    messagingSenderId: '604370164738',
    projectId: 'cenkirpall-afbe9',
    storageBucket: 'cenkirpall-afbe9.appspot.com',
    androidClientId: '604370164738-1rejn4vsvi2onnadjf32bg3up82omh8b.apps.googleusercontent.com',
    iosBundleId: 'com.example.touna',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDWvYftb8PxGiYyq5uAkYI0FdfsQ6YwpT0',
    appId: '1:604370164738:web:9ecd60857de9833223db1b',
    messagingSenderId: '604370164738',
    projectId: 'cenkirpall-afbe9',
    authDomain: 'cenkirpall-afbe9.firebaseapp.com',
    storageBucket: 'cenkirpall-afbe9.appspot.com',
    measurementId: 'G-N10R6H5V10',
  );
}
