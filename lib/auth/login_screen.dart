// import 'dart:developer';

// import 'package:finance_tracker/auth/auth_service.dart';
// import 'package:finance_tracker/auth/signup_screen.dart';
// import 'package:finance_tracker/home_screen.dart';
// import 'package:finance_tracker/widgets/button.dart';
// import 'package:finance_tracker/widgets/textfield.dart';
// import 'package:flutter/material.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _auth = AuthService();

//   final _email = TextEditingController();
//   final _password = TextEditingController();

//   @override
//   void dispose() {
//     super.dispose();
//     _email.dispose();
//     _password.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 25),
//         child: Column(
//           children: [
//             const Spacer(),
//             const Text("Login",
//                 style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500)),
//             const SizedBox(height: 50),
//             CustomTextField(
//               hint: "Enter Email",
//               label: "Email",
//               controller: _email,
//             ),
//             const SizedBox(height: 20),
//             CustomTextField(
//               hint: "Enter Password",
//               label: "Password",
//               isPassword: true,
//               controller: _password,
//             ),
//             const SizedBox(height: 30),
//             CustomButton(
//               label: "Login",
//               onPressed: _login,
//             ),
//             const SizedBox(height: 5),
//             Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//               const Text("Already have an account? "),
//               InkWell(
//                 onTap: () => goToSignup(context),
//                 child:
//                     const Text("Signup", style: TextStyle(color: Colors.red)),
//               )
//             ]),
//             const Spacer()
//           ],
//         ),
//       ),
//     );
//   }

//   goToSignup(BuildContext context) => Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const SignupScreen()),
//       );

//   goToHome(BuildContext context) => Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const HomeScreen()),
//       );

//   _login() async {
//     final user =
//         await _auth.loginUserWithEmailAndPassword(_email.text, _password.text);

//     if (user != null) {
//       log("User Logged In");
//       goToHome(context);
//     }
//   }
// }
import 'dart:developer';

import 'package:finance_tracker/auth/auth_service.dart';
import 'package:finance_tracker/auth/signup_screen.dart';
import 'package:finance_tracker/home_screen.dart';
import 'package:finance_tracker/widgets/button.dart';
import 'package:finance_tracker/widgets/textfield.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();

  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  void _validateAndLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool isValid = true;

    if (_email.text.isEmpty) {
      setState(() {
        _emailError = "Email is required.";
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_email.text)) {
      setState(() {
        _emailError = "Enter a valid email.";
      });
      isValid = false;
    }

    if (_password.text.isEmpty) {
      setState(() {
        _passwordError = "Password is required.";
      });
      isValid = false;
    }

    if (isValid) {
      final user = await _auth.loginUserWithEmailAndPassword(
        _email.text,
        _password.text,
      );

      if (user != null) {
        log("User Logged In");
        goToHome(context);
      } else {
        // Show a general login error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );
      }
    }
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
              controller: _email,
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
              controller: _password,
            ),
            if (_passwordError != null)
              Text(
                _passwordError!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 30),
            CustomButton(
              label: "Login",
              onPressed: _validateAndLogin,
            ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Don't have an account? "),
              InkWell(
                onTap: () => goToSignup(context),
                child:
                    const Text("Signup", style: TextStyle(color: Colors.red)),
              )
            ]),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  goToSignup(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignupScreen()),
      );

  goToHome(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
}
