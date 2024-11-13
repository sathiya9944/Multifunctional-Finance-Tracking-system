import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashPage({
    Key? key,
    required this.onInitializationComplete,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _setup().then(
      (_) => widget.onInitializationComplete(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(
        dialogBackgroundColor: Color.fromRGBO(36, 35, 49, 1.0),
        scaffoldBackgroundColor: Color.fromRGBO(36, 35, 49, 1.0),
      ),
      home: Scaffold(
        body: Center(
          child: Image.asset(
            'assets/images/logo.png', // Ensure this path is correct
            height: 200,
            width: 200,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Future<void> _setup() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    _registerServices();
  }

  void _registerServices() {}
}
