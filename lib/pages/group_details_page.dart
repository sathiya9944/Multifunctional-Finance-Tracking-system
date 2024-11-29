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

  // Reference to the Firestore collection for groups
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add a new expense
  void _addExpense() {
    if (_expenseNameController.text.isNotEmpty &&
        _amountController.text.isNotEmpty) {
      final expenseId = const Uuid().v4(); // Generate unique expense ID
      final expenseName = _expenseNameController.text;
      final amount = double.tryParse(_amountController.text);

      if (amount != null) {
        // Add the expense to Firestore
        _firestore.collection('groups').doc(widget.groupId).update({
          'expenses': FieldValue.arrayUnion([
            {
              'id': expenseId,
              'name': expenseName,
              'amount': amount,
              'spentBy': [],
            }
          ])
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Expense "$expenseName" added!')),
        );

        _expenseNameController.clear();
        _amountController.clear();
      }
    }
  }

  // Function to calculate the total expenses and remaining budget
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

  // Stream to fetch group data from Firestore in real time
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
  }

  // Function to update the edited expense in Firestore
  void _updateExpense() {
    if (_selectedExpenseId != null &&
        _expenseNameController.text.isNotEmpty &&
        _amountController.text.isNotEmpty) {
      final updatedExpenseName = _expenseNameController.text;
      final updatedAmount = double.tryParse(_amountController.text);

      if (updatedAmount != null) {
        // Update the expense in Firestore
        _firestore.collection('groups').doc(widget.groupId).update({
          'expenses': FieldValue.arrayRemove([
            {
              'id': _selectedExpenseId,
              'name': _editedExpenseName,
              'amount': _editedAmount,
              'spentBy': [],
            }
          ])
        }).then((_) {
          _firestore.collection('groups').doc(widget.groupId).update({
            'expenses': FieldValue.arrayUnion([
              {
                'id': _selectedExpenseId,
                'name': updatedExpenseName,
                'amount': updatedAmount,
                'spentBy': [],
              }
            ])
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Expense updated!')),
          );

          // Clear the selected expense for editing
          setState(() {
            _selectedExpenseId = null;
            _editedExpenseName = null;
            _editedAmount = null;
          });

          _expenseNameController.clear();
          _amountController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _fetchGroupData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading Group Details...'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
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
            title: Text('${groupData['name']} - Group Details'),
            backgroundColor: const Color(0xFF6200EA),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group Information
                Text(
                  'Group Budget: \$${groupData['budget'].toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Total Expenses: \$${totalExpense.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Remaining Budget: \$${remainingBudget.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Add Expense Section
                TextField(
                  controller: _expenseNameController,
                  decoration: InputDecoration(
                    labelText: 'Expense Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed:
                      _selectedExpenseId == null ? _addExpense : _updateExpense,
                  child: Text(_selectedExpenseId == null
                      ? 'Add Expense'
                      : 'Update Expense'),
                ),
                SizedBox(height: 20),

                // List of Expenses
                Text(
                  'Expenses:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: groupData['expenses'].length,
                    itemBuilder: (context, index) {
                      final expense = groupData['expenses'][index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text(expense['name']),
                          subtitle: Text(
                              'Amount: \$${expense['amount'].toStringAsFixed(2)}'),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editExpense(expense['id'], expense['name'],
                                  expense['amount']);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),

                // Large, professional "Go to Expense Sharing" Button
                Center(
                  child: ElevatedButton(
                    onPressed: () => _navigateToExpenseSharing(groupData),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      backgroundColor: Color.fromARGB(255, 253, 252, 255),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Ensure the text color is white
                      ),
                    ),
                    child: Text('Expense Sharing'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
