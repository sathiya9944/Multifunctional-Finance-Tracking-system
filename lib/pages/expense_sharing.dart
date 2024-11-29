import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // For generating unique expense IDs
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseSharingPage extends StatefulWidget {
  final String groupId;
  ExpenseSharingPage({required this.groupId});

  @override
  _ExpenseSharingPageState createState() => _ExpenseSharingPageState();
}

class _ExpenseSharingPageState extends State<ExpenseSharingPage> {
  final TextEditingController _expenseNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late DocumentReference groupRef;

  @override
  void initState() {
    super.initState();
    groupRef =
        FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
  }

  // Function to add a new shared expense
  void _addSharedExpense() async {
    if (_expenseNameController.text.isNotEmpty &&
        _amountController.text.isNotEmpty) {
      final expenseId = const Uuid().v4(); // Generate unique expense ID
      final expenseName = _expenseNameController.text;
      final amount = double.tryParse(_amountController.text);

      if (amount != null) {
        final expense = {
          'id': expenseId,
          'name': expenseName,
          'amount': amount,
          'members': [], // We'll update this later based on members
        };

        // Add expense to Firestore
        await groupRef.update({
          'expenses': FieldValue.arrayUnion([expense]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shared expense "$expenseName" added!')),
        );

        _expenseNameController.clear();
        _amountController.clear();
      }
    }
  }

  // Function to split the expense based on percentage
  void _splitExpense() async {
    final groupSnapshot = await groupRef.get();
    final groupData = groupSnapshot.data() as Map<String, dynamic>;

    double totalExpense = groupData['expenses']
        .fold(0.0, (sum, expense) => sum + expense['amount']);

    double totalPercentage = 0.0;

    // Calculate total percentage from members' inputs
    for (var expense in groupData['expenses']) {
      for (var member in expense['members']) {
        totalPercentage += member['percentage'];
      }
    }

    // Ensure total percentage does not exceed 100%
    if (totalPercentage != 100.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Total percentages must add up to 100%.')),
      );
      return;
    }

    // Update the member shares based on percentage
    for (var expense in groupData['expenses']) {
      for (var member in expense['members']) {
        double shareAmount = expense['amount'] * (member['percentage'] / 100);
        member['share'] = shareAmount;

        // Update the member share in Firestore by removing the old expense and adding the updated one
        await groupRef.update({
          'expenses': FieldValue.arrayRemove([expense]), // Remove old expense
        });
        await groupRef.update({
          'expenses': FieldValue.arrayUnion([expense]), // Add updated expense
        });
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Expenses split based on percentages.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Sharing'),
        backgroundColor: const Color(0xFF6200EA),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: groupRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          final groupData = snapshot.data!.data() as Map<String, dynamic>;
          final expenses = groupData['expenses'] ?? [];
          final members = groupData['members'] ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    labelText: 'Total Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addSharedExpense,
                  child: Text('Add Shared Expense'),
                ),
                SizedBox(height: 20),

                // List of Members and their Shares
                Text(
                  'Shared Expenses:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text(expense['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Total: \$${expense['amount'].toStringAsFixed(2)}'),
                              for (var member in expense['members'])
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${member['name']} - Share: \$${member['share'].toStringAsFixed(2)}'),
                                    TextField(
                                      decoration: InputDecoration(
                                          labelText:
                                              'Percentage for ${member['name']}'),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        final percentage =
                                            double.tryParse(value);
                                        if (percentage != null) {
                                          setState(() {
                                            member['percentage'] = percentage;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Split Expenses Button
                ElevatedButton(
                  onPressed: _splitExpense,
                  child: Text('Split Expenses According to Percentage'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
