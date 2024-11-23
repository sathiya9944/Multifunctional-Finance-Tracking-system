// import 'dart:developer';

// import 'package:firebase_auth/firebase_auth.dart';

// class AuthService {
//   final _auth = FirebaseAuth.instance;

//   Future<User?> createUserWithEmailAndPassword(
//       String email, String password) async {
//     try {
//       final cred = await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       return cred.user;
//     } catch (e) {
//       log("Something went wrong");
//     }
//     return null;
//   }

//   Future<User?> loginUserWithEmailAndPassword(
//       String email, String password) async {
//     try {
//       final cred = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);
//       return cred.user;
//     } catch (e) {
//       log("Something went wrong");
//     }
//     return null;
//   }

//   Future<void> signout() async {
//     try {
//       await _auth.signOut();
//     } catch (e) {
//       log("Something went wrong");
//     }
//   }
// }

import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log("FirebaseAuthException: ${e.code}");
      rethrow; // Rethrow to let the calling method handle the error
    } catch (e) {
      log("Error creating user: $e");
      rethrow;
    }
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log("FirebaseAuthException: ${e.code}");
      rethrow; // Rethrow to let the calling method handle the error
    } catch (e) {
      log("Error logging in user: $e");
      rethrow;
    }
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Error signing out: $e");
    }
  }

  Future<bool> checkIfEmailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } on FirebaseAuthException catch (e) {
      log("FirebaseAuthException: ${e.code}");
      rethrow; // Rethrow to let the calling method handle the error
    } catch (e) {
      log("Error checking email existence: $e");
      rethrow;
    }
  }
}
