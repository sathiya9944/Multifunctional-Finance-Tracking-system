import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date and currency formatting

class Reminders extends StatefulWidget {
  final String uid; // User's UID

  const Reminders({Key? key, required this.uid}) : super(key: key);

  @override
  State<Reminders> createState() => _RemindersState();
}

class _RemindersState extends State<Reminders> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final TextEditingController _reminderTitleController =
      TextEditingController();
  final TextEditingController _reminderAmountController =
      TextEditingController();
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _reminders = [];
  String? userId; // Add userId

  @override
  void initState() {
    super.initState();
    userId =
        widget.uid; // Assign userId with the UID passed from Reminders widget
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _loadReminders();
  }

  // Load and sort reminders, and delete expired ones
  Future<void> _loadReminders() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reminders')
        .where('uid', isEqualTo: userId) // Filter by user's UID
        .get();

    List<Map<String, dynamic>> reminders = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();

    // Remove expired reminders
    for (var reminder in reminders) {
      DateTime reminderDate = (reminder['date'] as Timestamp).toDate();
      if (reminderDate.isBefore(DateTime.now())) {
        await FirebaseFirestore.instance
            .collection('reminders')
            .doc(reminder['id'])
            .delete();
      }
    }

    // Reload the non-expired reminders
    reminders = reminders
        .where((reminder) =>
            (reminder['date'] as Timestamp).toDate().isAfter(DateTime.now()))
        .toList();

    // Sort reminders by date
    reminders.sort((a, b) => (a['date'] as Timestamp)
        .toDate()
        .compareTo((b['date'] as Timestamp).toDate()));

    setState(() {
      _reminders = reminders;
    });
  }

  // Function to show notification
  Future<void> _showNotification(String title, String body) async {
    var androidDetails = const AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.high,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  // Set or update reminder
  Future<void> _setReminder({String? id}) async {
    final reminderTitle = _reminderTitleController.text;
    final reminderAmount = _reminderAmountController.text;

    if (reminderTitle.isNotEmpty &&
        reminderAmount.isNotEmpty &&
        _selectedDate != null &&
        _selectedDate!.isAfter(DateTime.now())) {
      final reminderData = {
        'title': reminderTitle,
        'amount': reminderAmount,
        'date': _selectedDate,
        'uid': userId, // Add user's UID here
      };

      if (id == null) {
        await FirebaseFirestore.instance
            .collection('reminders')
            .add(reminderData);
      } else {
        await FirebaseFirestore.instance
            .collection('reminders')
            .doc(id)
            .update(reminderData);
      }

      _showNotification(reminderTitle, 'Amount: $reminderAmount');
      _reminderTitleController.clear();
      _reminderAmountController.clear();
      _selectedDate = null;

      _loadReminders();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(id == null
            ? 'Reminder added: $reminderTitle'
            : 'Reminder updated: $reminderTitle'),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all fields and select a valid date!'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _deleteReminder(String id) async {
    await FirebaseFirestore.instance.collection('reminders').doc(id).delete();
    _loadReminders();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Reminder deleted!'),
      backgroundColor: Colors.red,
    ));
  }

  void _showAddReminderDialog(BuildContext context, bool isEdit, String? id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Reminder' : 'Add Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _reminderTitleController,
                decoration: const InputDecoration(
                  labelText: 'Reminder Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _reminderAmountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickDate,
                child: Text(_selectedDate == null
                    ? 'Pick Date'
                    : 'Date: ${_selectedDate!.toLocal()}'.split(' ')[0]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _setReminder(id: id);
                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _editReminder(int index) {
    final reminder = _reminders[index];
    _reminderTitleController.text = reminder['title'];
    _reminderAmountController.text = reminder['amount'];
    _selectedDate = (reminder['date'] as Timestamp).toDate();

    _showAddReminderDialog(context, true, reminder['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Reminder'),
        backgroundColor: const Color(0xFF6200EA),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _reminders.length,
          itemBuilder: (context, index) {
            final reminder = _reminders[index];
            final reminderDate = (reminder['date'] as Timestamp).toDate();

            // Format date and amount
            String formattedDate =
                DateFormat('MM/dd/yyyy').format(reminderDate);
            String formattedAmount = NumberFormat.currency(symbol: '\$')
                .format(double.parse(reminder['amount']));

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  reminder['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Amount: $formattedAmount\nDate: $formattedDate',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editReminder(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteReminder(reminder['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddReminderDialog(context, false, null);
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF6200EA),
      ),
    );
  }
}
