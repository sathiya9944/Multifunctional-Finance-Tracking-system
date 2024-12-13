import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker/auth/login_screen.dart';
import 'package:finance_tracker/pages/home_screen.dart';
import 'package:finance_tracker/widgets/button.dart';
import 'package:finance_tracker/widgets/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_tracker/auth/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const Spacer(),
            const Text("Signup",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
            const SizedBox(height: 50),
            CustomTextField(
              hint: "Enter Name",
              label: "Name",
              controller: _name,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Email",
              label: "Email",
              controller: _email,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: "Enter Password",
              label: "Password",
              isPassword: true,
              controller: _password,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 30),
            CustomButton(
              label: "Signup",
              onPressed: _signup,
            ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Already have an account? "),
              InkWell(
                onTap: () => goToLogin(context),
                child: const Text("Login", style: TextStyle(color: Colors.red)),
              )
            ]),
            const Spacer()
          ],
        ),
      ),
    );
  }

  void goToLogin(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

  void goToHome(BuildContext context, String uid) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(uid: uid)),
      );


  Future<void> _signup() async {
    setState(() {
      _errorMessage = null;
    });

    if (_email.text.isEmpty || _password.text.isEmpty || _name.text.isEmpty) {
      setState(() {
        _errorMessage = "All fields are required.";
      });
      return;
    }

    try {
      // Check if the email already exists
      final emailExists = await _auth.checkIfEmailExists(_email.text);
      if (emailExists) {
        setState(() {
          _errorMessage = "Email already registered. Please log in.";
        });
        return;
      }

      // Create the user with email and password
      final user = await _auth.createUserWithEmailAndPassword(
          _email.text, _password.text);

      if (user != null) {
        final uid = user.uid; // Fetch the UID

        // Save user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid, // Store UID explicitly in Firestore
          'name': _name.text,
          'email': _email.text,
          'accountType': 'basic',
          'creationDate': FieldValue.serverTimestamp(),
        });

        // Initialize user's expenses collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('expenses')
            .add({
          'initialExpense': '0',
        });

        // Initialize user's reminders collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('reminders')
            .add({
          'reminderMessage': 'Welcome to your personal finance tracker!',
        });

        log("User created successfully with UID: $uid");
        goToHome(context, uid); // Navigate to the HomeScreen
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') {
          _errorMessage = "The password is too weak.";
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = "The email is already in use.";
        } else if (e.code == 'invalid-email') {
          _errorMessage = "The email address is invalid.";
        } else {
          _errorMessage = "An error occurred. Please try again.";
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "An unexpected error occurred.";
      });
    }
  }
}
