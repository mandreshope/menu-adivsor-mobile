import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseConfig {
  static FirebaseOptions get platformOptions {
    if (kIsWeb) {
      // Web
      return const FirebaseOptions(
        apiKey: "AIzaSyBt5xCXINLzU4B2r9C9KdISVlqNeLnbMH8",
        authDomain: "menuadvisor-f06d2.firebaseapp.com",
        databaseURL: "https://menuadvisor-f06d2.firebaseio.com",
        projectId: "menuadvisor-f06d2",
        storageBucket: "menuadvisor-f06d2.appspot.com",
        messagingSenderId: "886054910744",
        appId: "1:886054910744:web:78aa961c8e157fec3e7c6d",
        measurementId: "G-FB5SQB4ZFY",
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      // iOS and MacOS
      return const FirebaseOptions(
        apiKey: 'AIzaSyB87DZ_x_5plS_no0vkbL3vRejuVcxHSOU',
        appId: '1:886054910744:ios:de31fe210985ca423e7c6d',
        messagingSenderId: '886054910744',
        projectId: "menuadvisor-f06d2",
        authDomain: "menuadvisor-f06d2.firebaseapp.com",
        iosBundleId: "com.pdu.menuadvisor.menuadvisor",
        iosClientId:
            '886054910744-al0frcjdpub5b52jut2c7utskiqa6kbl.apps.googleusercontent.com',
        databaseURL: "https://menuadvisor-f06d2.firebaseio.com",
      );
    } else {
      // Android
      return const FirebaseOptions(
        apiKey: 'AIzaSyB87DZ_x_5plS_no0vkbL3vRejuVcxHSOU',
        appId: "1:886054910744:android:6dc71859d5cb6a333e7c6d",
        messagingSenderId: '886054910744',
        projectId: "menuadvisor-f06d2",
        authDomain: "menuadvisor-f06d2.firebaseapp.com",
        androidClientId:
            '886054910744-af3dn3tvo67dc1v7jc9b1ilkbi7ev616.apps.googleusercontent.com',
        databaseURL: "https://menuadvisor-f06d2.firebaseio.com",
      );
    }
  }
}
