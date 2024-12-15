import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // For generating unique expense IDs
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'expense_sharing.dart'; // Import the ExpenseSharingPage

class GroupDetailsPage extends StatefulWidget {
  final String groupId;
  GroupDetailsPage({required this.groupId});

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  final TextEditingController _expenseNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _selectedExpenseId;
  String? _editedExpenseName;
  double? _editedAmount;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add a new expense
  void _addExpense() async {
    final user =
        FirebaseAuth.instance.currentUser; // Get the currently logged-in user
    if (user != null &&
        _expenseNameController.text.isNotEmpty &&
        _amountController.text.isNotEmpty) {
      final expenseId = const Uuid().v4();
      final expenseName = _expenseNameController.text;
      final amount = double.tryParse(_amountController.text);

      if (amount != null) {
        // Fetch user name from Firestore Users collection
        final userDoc =
            await _firestore.collection('Users').doc(user.uid).get();
        final userName = userDoc.data()?['name'] ??
            'Unknown'; // Default to 'Unknown' if not found

        final expenseData = {
          'id': expenseId,
          'name': expenseName,
          'amount': amount,
          'spentBy': [user.uid], // Include the current user's UID
        };

        _firestore.collection('groups').doc(widget.groupId).update({
          'expenses': FieldValue.arrayUnion([expenseData])
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Expense "$expenseName" added!')),
        );

        _expenseNameController.clear();
        _amountController.clear();
        Navigator.pop(context); // Close the dialog
      }
    }
  }

  // Function to calculate total expenses
  double _calculateTotalExpense(List expenses) {
    double total = 0;
    for (var expense in expenses) {
      total += expense['amount'];
    }
    return total;
  }

  // Function to navigate to the Expense Sharing Page
  void _navigateToExpenseSharing(Map<String, dynamic> groupData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseSharingPage(groupId: widget.groupId),
      ),
    );
  }

  // Stream to fetch group data
  Stream<DocumentSnapshot> _fetchGroupData() {
    return _firestore.collection('groups').doc(widget.groupId).snapshots();
  }

  // Function to edit an existing expense
  void _editExpense(String expenseId, String expenseName, double amount) {
    _expenseNameController.text = expenseName;
    _amountController.text = amount.toString();
    setState(() {
      _selectedExpenseId = expenseId;
      _editedExpenseName = expenseName;
      _editedAmount = amount;
    });
    _showExpenseDialog(true);
  }

  // Function to update the edited expense
  void _updateExpense() async {
    if (_selectedExpenseId != null &&
        _expenseNameController.text.isNotEmpty &&
        _amountController.text.isNotEmpty) {
      final updatedExpenseName = _expenseNameController.text;
      final updatedAmount = double.tryParse(_amountController.text);

      if (updatedAmount != null) {
        final groupDoc =
            await _firestore.collection('groups').doc(widget.groupId).get();
        if (groupDoc.exists) {
          final groupData = groupDoc.data() as Map<String, dynamic>;
          final expenses =
              List<Map<String, dynamic>>.from(groupData['expenses']);

          // Find the index of the expense to update
          final expenseIndex = expenses
              .indexWhere((expense) => expense['id'] == _selectedExpenseId);

          if (expenseIndex != -1) {
            // Update the specific expense
            expenses[expenseIndex] = {
              'id': _selectedExpenseId,
              'name': updatedExpenseName,
              'amount': updatedAmount,
              'spentBy': expenses[expenseIndex]
                  ['spentBy'], // Keep the original spentBy
            };

            // Update the group document with the modified expenses array
            await _firestore.collection('groups').doc(widget.groupId).update({
              'expenses': expenses,
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Expense updated!')),
            );

            setState(() {
              _selectedExpenseId = null;
              _editedExpenseName = null;
              _editedAmount = null;
            });

            _expenseNameController.clear();
            _amountController.clear();
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Expense not found!')),
            );
          }
        }
      }
    }
  }

  // Function to show the expense dialog
  void _showExpenseDialog(bool isEditMode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isEditMode ? 'Edit Expense' : 'Add Expense',
            style: TextStyle(color: Colors.white), // Set the color here
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _expenseNameController,
                decoration: const InputDecoration(
                  labelText: 'Expense Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isEditMode ? _updateExpense : _addExpense,
              child: Text(isEditMode ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _fetchGroupData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(),
              title: Text('Loading Group Details...'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(),
              title: Text('Error'),
            ),
            body: Center(child: Text('Failed to load group data')),
          );
        }

        final groupData = snapshot.data!.data() as Map<String, dynamic>;
        final totalExpense = _calculateTotalExpense(groupData['expenses']);
        final remainingBudget = groupData['budget'] - totalExpense;

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(),
            title: Text(
              '${groupData['name']} - Group Details',
              style: TextStyle(color: Colors.white), // Set the text color here
            ),
            backgroundColor: const Color(0xFF6200EA),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Center the Group Budget Card
                Center(
                  child: Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Group Budget',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6200EA),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '₹${groupData['budget'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6200EA),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Total Expenses: ₹${totalExpense.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Remaining Budget: ₹${remainingBudget.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              color: remainingBudget < 0
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: groupData['expenses'].length,
                    itemBuilder: (context, index) {
                      final expense = groupData['expenses'][index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(expense['name']),
                          subtitle: Text(
                              'Spent by: ${expense['spentBy'].join(', ')}'),
                          trailing:
                              Text('₹${expense['amount'].toStringAsFixed(2)}'),
                          onTap: () => _editExpense(
                            expense['id'],
                            expense['name'],
                            expense['amount'].toDouble(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.attach_money),
                label: 'Split Bill',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Add Expense',
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                _navigateToExpenseSharing(groupData);
              } else if (index == 1) {
                _showExpenseDialog(false);
              }
            },
          ),
        );
      },
    );
  }
}
