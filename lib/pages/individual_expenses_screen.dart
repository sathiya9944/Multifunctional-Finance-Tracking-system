import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for DateFormat

class FirestoreCRUD extends StatefulWidget {
  final String uid; // Accept UID as a parameter

  const FirestoreCRUD({Key? key, required this.uid}) : super(key: key);

  @override
  State<FirestoreCRUD> createState() => _FirestoreCRUDState();
}

class _FirestoreCRUDState extends State<FirestoreCRUD> {
  late CollectionReference userCollection;

  double balance = 0.0;
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    userCollection = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection("expenses");
    _getBalance();
  }

  // Fetch balance, total income, and total expenses
  void _getBalance() async {
    final QuerySnapshot snapshot = await userCollection.get();

    double income = 0.0;
    double expenses = 0.0;

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data['type'] == 'Income') {
        income += data['amount'] ?? 0.0;
      } else if (data['type'] == 'Expense') {
        expenses += data['amount'] ?? 0.0;
      }
    }

    setState(() {
      totalIncome = income;
      totalExpense = expenses;
      balance = income - expenses;
    });
  }

  // Fetch filtered expenses based on search query
  Stream<QuerySnapshot> _getFilteredExpenses() {
    return userCollection
        .where('name', isGreaterThanOrEqualTo: searchQuery)
        .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background
      appBar: AppBar(
        backgroundColor: const Color(0xFF6200EA), // Material 3 Primary color
        centerTitle: true,
        title: Text(
          "Finance Manager",
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance display card
            Card(
              elevation: 4,
              color: const Color(0xFFE8F5E9), // Light green background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Current Balance',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF388E3C), // Dark green text
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '₹${balance.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF388E3C), // Dark green text
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Total Income',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${totalIncome.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Total Expense',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${totalExpense.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search expenses...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getFilteredExpenses(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Something went wrong',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.redAccent),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple, // Loading indicator color
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No data available',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.black),
                      ),
                    );
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return GestureDetector(
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text(
                              data['name'] ?? 'Unnamed',
                              style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '₹${data['amount']?.toString() ?? '0'}',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: Colors.black54),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Date: ${DateFormat.yMMMd().format((data['timestamp'] as Timestamp).toDate())}',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.black54),
                                ),
                              ],
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  const Color(0xFF6200EA), // Purple
                              child: Text(
                                data['type']?[0] ?? 'E',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.black54),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 1,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(
                                          context); // Close the dialog
                                      updateBottomSheet(
                                        context,
                                        document.id,
                                        data['name'] ?? '',
                                        data['type'] ?? 'Expense',
                                        data['amount']?.toString() ?? '0',
                                      );
                                    },
                                    leading: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    title: Text(
                                      "Edit",
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(
                                          context); // Close the dialog
                                      userCollection
                                          .doc(document.id)
                                          .delete()
                                          .then((_) {
                                        _getBalance(); // Update balance after deletion
                                      });
                                    },
                                    leading: const Icon(Icons.delete,
                                        color: Colors.red),
                                    title: Text(
                                      "Delete",
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          // Handle tap event if needed
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showExpenseDialog(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF6200EA), // Original purple color
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Move to the right
    );
  }

  // Show the dialog to add/edit expenses
  Future<void> _showExpenseDialog(BuildContext context,
      {String id = '',
      String name = '',
      String type = 'Expense',
      String amount = ''}) async {
    final TextEditingController nameController =
        TextEditingController(text: name);
    final TextEditingController amountController =
        TextEditingController(text: amount);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by clicking outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(id.isEmpty ? 'Add Expense' : 'Edit Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Expense Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  hintText: 'Amount',
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  final double amountValue =
                      double.parse(amountController.text);

                  if (id.isEmpty) {
                    // Add new expense
                    userCollection.add({
                      'name': nameController.text,
                      'type': type,
                      'amount': amountValue,
                      'timestamp': Timestamp.now(),
                    }).then((value) {
                      _getBalance(); // Update balance after adding
                      Navigator.of(context).pop();
                    });
                  } else {
                    // Update existing expense
                    userCollection.doc(id).update({
                      'name': nameController.text,
                      'amount': amountValue,
                    }).then((value) {
                      _getBalance(); // Update balance after editing
                      Navigator.of(context).pop();
                    });
                  }
                }
              },
              child: Text(id.isEmpty ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  // Show bottom sheet for editing expenses
  void updateBottomSheet(
    BuildContext context,
    String id,
    String name,
    String type,
    String amount,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: name),
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextField(
                controller: TextEditingController(text: amount),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: () {
                  // Add your update logic here
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          ),
        );
      },
    );
  }
}
