
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:finance_tracker/auth/auth_service.dart';
import 'package:finance_tracker/auth/signup_screen.dart';
import 'package:finance_tracker/widgets/button.dart';
import 'package:finance_tracker/widgets/textfield.dart';
import 'package:finance_tracker/pages/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _verificationError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Method to validate inputs and log in the user
  void _validateAndLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _verificationError = null;
    });

    bool isValid = true;

    // Email validation
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = "Email is required.";
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text)) {
      setState(() {
        _emailError = "Enter a valid email.";
      });
      isValid = false;
    }

    // Password validation
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = "Password is required.";
      });
      isValid = false;
    }

    if (isValid) {
      try {
        // Log in the user with email and password
        final user = await _auth.loginUserWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );

        if (user != null) {
          if (!user.emailVerified) {
            setState(() {
              _verificationError =
                  "Please verify your email before logging in.";
            });
            // Show a snackbar with an option to resend email
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    "Email not verified. Resend verification email?"),
                action: SnackBarAction(
                  label: "RESEND",
                  onPressed: () => _resendVerificationEmail(user),
                ),
              ),
            );
            return;
          }

          log("User Logged In with UID: ${user.uid}");
          await _fetchUserData(user.uid);
          goToHome(context, user.uid);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid email or password")),
          );
        }
      } catch (e) {
        if (e.toString().contains('too-many-requests')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text("Too many login attempts. Please try again later.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error logging in")),
          );
        }
      }
    }
  }

  // Method to resend email verification
  Future<void> _resendVerificationEmail(user) async {
    try {
      await user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Verification email has been resent. Check your inbox.")),
      );
    } catch (e) {
      log("Error resending verification email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to resend verification email. Try again.")),
      );
    }
  }

  // Fetch user-specific data
  Future<void> _fetchUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data();
        log('User data: $userData');
      } else {
        log('User data not found for UID: $userId');
      }
    } catch (e) {
      log('Error fetching user data for UID $userId: $e');
    }
  }

  // Navigate to Home Screen
  void goToHome(BuildContext context, String uid) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(uid: uid),
      ),
    );
  }

  // Navigate to Signup Screen
  void goToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const Spacer(),
            const Text(
              "Login",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 50),
            CustomTextField(
              hint: "Enter Email",
              label: "Email",
              controller: _emailController,
            ),
            if (_emailError != null)
              Text(
                _emailError!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Password",
              label: "Password",
              isPassword: true,
              controller: _passwordController,
            ),
            if (_passwordError != null)
              Text(
                _passwordError!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_verificationError != null)
              Text(
                _verificationError!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 30),
            CustomButton(
              label: "Login",
              onPressed: _validateAndLogin,
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                InkWell(
                  onTap: () => goToSignup(context),
                  child: const Text(
                    "Signup",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
