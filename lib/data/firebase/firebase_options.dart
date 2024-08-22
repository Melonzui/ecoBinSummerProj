import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;

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
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
    authDomain: '',
    databaseURL: '',
    storageBucket: '',
    measurementId: '',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0zuzROOA0tSHkHpPoDkq7IclDGMWRPBk', //Web API
    appId: '1:868715042666:android:920c172c2a72daa8b27713',
    messagingSenderId: '868715042666',
    projectId: 'ecobin-4096e',
    //databaseURL: 'https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app',//
    storageBucket: 'ecobin-4096e.appspot.com', //
  );
}
