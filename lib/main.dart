import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import './pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAbMrTxkaTpIaPy7AnjpsUJvwMIYS9cCtY",
            authDomain: "expensetracker007-b6780.firebaseapp.com",
            projectId: "expensetracker007-b6780",
            storageBucket: "expensetracker007-b6780.appspot.com",
            messagingSenderId: "288629209069",
            appId: "1:288629209069:web:00164ce420af47631cd9e4",
            measurementId: "G-W6LPN69YGZ"));
  } else {
    Firebase.initializeApp();
  }

  runApp(
    SplashPage(
      key: UniqueKey(),
      onInitializationComplete: () {},
    ),
  );
}
