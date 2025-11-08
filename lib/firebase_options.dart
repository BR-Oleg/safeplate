// File generated from google-services.json
// Firebase project: safeplate-a14e9

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBhAWZ61YF4Qhl_GJjRl6avMpkUZuK6n8k',
    appId: '1:476899420653:android:fcd5a28dc225e9ae03dfe4',
    messagingSenderId: '476899420653',
    projectId: 'safeplate-a14e9',
    storageBucket: 'safeplate-a14e9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBhAWZ61YF4Qhl_GJjRl6avMpkUZuK6n8k',
    appId: '1:476899420653:ios:fcd5a28dc225e9ae03dfe4',
    messagingSenderId: '476899420653',
    projectId: 'safeplate-a14e9',
    storageBucket: 'safeplate-a14e9.firebasestorage.app',
    iosBundleId: 'com.safeplate.safeplate',
  );
}
