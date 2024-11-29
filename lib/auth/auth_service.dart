
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to create a user with email and password
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

  // Method to log in a user with email and password
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
      log("Invalid Username or Password $e");
      rethrow;
    }
  }

  // Method to sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Error signing out: $e");
    }
  }

  // Method to check if an email exists
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

  // Method to get the current logged-in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
