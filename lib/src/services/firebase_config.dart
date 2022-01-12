import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseConfig {
  static FirebaseOptions get platformOptions {
    if (kIsWeb) {
      // Web
      return const FirebaseOptions(
        apiKey: "AIzaSyAdrpwqbREnk2raUqm9YGDtMD_qf2oZt8k",
        authDomain: "advisor-b7d65.firebaseapp.com",
        databaseURL: "https://advisor-b7d65-default-rtdb.firebaseio.com",
        projectId: "advisor-b7d65",
        storageBucket: "advisor-b7d65.appspot.com",
        messagingSenderId: "1042310334359",
        appId: "1:1042310334359:web:063c67719a4eb1a15c26d2",
        measurementId: "G-NTZE8BX507",
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      // iOS and MacOS
      return const FirebaseOptions(
        apiKey: 'AIzaSyDaFS2A0WvRobRJc3vraRj1AHf_Yr79W5g',
        appId: '1:1042310334359:ios:7bcebc5bd1fd28b95c26d2',
        messagingSenderId: '1042310334359',
        projectId: "advisor-b7d65",
        authDomain: "advisor-b7d65.firebaseapp.com",
        iosBundleId: "com.pdu.menuadvisor.menuadvisor",
        iosClientId:
            '1042310334359-7qjd5plkpfl0csbv78877dlr6uq6mu76.apps.googleusercontent.com',
        databaseURL: "https://advisor-b7d65-default-rtdb.firebaseio.com",
      );
    } else {
      // Android
      return const FirebaseOptions(
        apiKey: 'AIzaSyAjjiR1_zNCHiCJz9UDUSNmQq2ijYzo6TY',
        appId: "1:1042310334359:android:50ebdfdc354cbbb05c26d2",
        messagingSenderId: '1042310334359',
        projectId: "advisor-b7d65",
        authDomain: "advisor-b7d65.firebaseapp.com",
        androidClientId:
            '1042310334359-do63m7jlmifglqnciq6qpv89i0kunl1a.apps.googleusercontent.com',
        databaseURL: "https://advisor-b7d65-default-rtdb.firebaseio.com",
      );
    }
  }
}
