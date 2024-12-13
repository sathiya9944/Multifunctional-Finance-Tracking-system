import 'package:flutter/material.dart';
import 'individual_expenses_screen.dart';
import 'group_expenses_screen.dart';
import 'reminders_screen.dart';
import 'package:finance_tracker/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String uid; // Add uid parameter

  const HomeScreen({super.key, required this.uid}); // Require uid

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  // @override
  // void initState() {
  //   super.initState();
  //   // Pass uid to the child screens
  //   _screens = [
  //     FirestoreCRUD(uid: widget.uid),
  //     GroupFinanceTracker(uid: widget.uid),
  //     Reminders(uid: widget.uid),
  //   ];
  // }
  @override
  void initState() {
    super.initState();
    // Pass uid to the child screens
    _screens = [
      FirestoreCRUD(uid: widget.uid),
      GroupFinanceTracker(currentUserId: widget.uid), // Pass uid here
      Reminders(uid: widget.uid), // Pass uid here
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _screens.length) {
            // Navigate to the login screen (Logout)
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()));
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: "Individual",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Group",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: "Reminder",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: "Logout",
          ),
        ],
        backgroundColor: const Color.fromARGB(
            255, 247, 246, 249), // Background color for bottom bar
        selectedItemColor: const Color(0xFF6200EA), // Selected icon color
        unselectedItemColor: Colors.black54, // Dark color for unselected items
      ),
    );
  }
}
