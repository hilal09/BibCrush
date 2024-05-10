import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCTzA3K4UpO89jz1VdrSM443GsWrEddTuc',
    appId: '1:194587936025:web:c7315f3fad77ce2b01f188',
    messagingSenderId: '194587936025',
    projectId: 'bibcrush-97726',
    authDomain: 'bibcrush-97726.firebaseapp.com',
    storageBucket: 'bibcrush-97726.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVHdGphDlmjJVA3HqXfFVNM--86WYZZMM',
    appId: '1:194587936025:android:a612781a96f5d72901f188',
    messagingSenderId: '194587936025',
    projectId: 'bibcrush-97726',
    storageBucket: 'bibcrush-97726.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATnmwoAxdLw7O_ARsIDKYDYqpEh6K8BNo',
    appId: '1:194587936025:ios:df1d26d79e7d94cd01f188',
    messagingSenderId: '194587936025',
    projectId: 'bibcrush-97726',
    storageBucket: 'bibcrush-97726.appspot.com',
    iosBundleId: 'com.example.bibcrush',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyATnmwoAxdLw7O_ARsIDKYDYqpEh6K8BNo',
    appId: '1:194587936025:ios:c4052a04c2db2c8101f188',
    messagingSenderId: '194587936025',
    projectId: 'bibcrush-97726',
    storageBucket: 'bibcrush-97726.appspot.com',
    iosBundleId: 'com.example.bibcrush.RunnerTests',
  );
}
