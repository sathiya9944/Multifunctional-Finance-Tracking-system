// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// // ignore: depend_on_referenced_packages
// import 'package:firebase_core/firebase_core.dart';
// import './pages/splash_page.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   if (kIsWeb) {
//     await Firebase.initializeApp(
//         options: const FirebaseOptions(
//             apiKey: "AIzaSyAbMrTxkaTpIaPy7AnjpsUJvwMIYS9cCtY",
//             authDomain: "expensetracker007-b6780.firebaseapp.com",
//             projectId: "expensetracker007-b6780",
//             storageBucket: "expensetracker007-b6780.appspot.com",
//             messagingSenderId: "288629209069",
//             appId: "1:288629209069:web:00164ce420af47631cd9e4",
//             measurementId: "G-W6LPN69YGZ"));
//   } else {
//     Firebase.initializeApp();
//   }

//   runApp(
//     SplashPage(
//       key: UniqueKey(),
//       onInitializationComplete: () {},
//     ),
//   );
// }

//import 'dart:async';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:finance_tracker/auth/login_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Check if the platform is web and initialize Firebase accordingly
//   if (kIsWeb) {
//     await Firebase.initializeApp(
//       options: const FirebaseOptions(
//         apiKey: "AIzaSyAbMrTxkaTpIaPy7AnjpsUJvwMIYS9cCtY",
//         authDomain: "expensetracker007-b6780.firebaseapp.com",
//         projectId: "expensetracker007-b6780",
//         storageBucket: "expensetracker007-b6780.appspot.com",
//         messagingSenderId: "288629209069",
//         appId: "1:288629209069:web:00164ce420af47631cd9e4",
//         measurementId: "G-W6LPN69YGZ",
//       ),
//     );
//   } else {
//     await Firebase.initializeApp();
//   }

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: LoginScreen(),
//     );
//   }
// }
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:finance_tracker/auth/login_screen.dart'; // Your LoginScreen import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase differently for web and mobile
  if (kIsWeb) {
    // Web-specific Firebase initialization
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAbMrTxkaTpIaPy7AnjpsUJvwMIYS9cCtY",
        authDomain: "expensetracker007-b6780.firebaseapp.com",
        projectId: "expensetracker007-b6780",
        storageBucket: "expensetracker007-b6780.appspot.com",
        messagingSenderId: "288629209069",
        appId: "1:288629209069:web:00164ce420af47631cd9e4",
        measurementId: "G-W6LPN69YGZ",
      ),
    );
  } else {
    // Mobile-specific Firebase initialization
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          LoginScreen(), // This should be your initial screen, e.g., LoginScreen
    );
  }
}
