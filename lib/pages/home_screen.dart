import 'package:flutter/material.dart';
import 'individual_expenses_screen.dart';
import 'group_expenses_screen.dart';
import 'reminders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // List of screens to navigate to
  final List<Widget> _screens = [
    FirestoreCRUD(),
    GroupFinanceTracker(),
    Reminders(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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
        ],
        backgroundColor: const Color.fromARGB(
            255, 247, 246, 249), // background for bottom bar
        selectedItemColor: const Color(0xFF6200EA), // selected icon color
        unselectedItemColor: Colors.black54, // Dark color for unselected items
      ),
    );
  }
}
