import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreCRUD extends StatefulWidget {
  const FirestoreCRUD({super.key});

  @override
  State<FirestoreCRUD> createState() => _FirestoreCRUDState();
}

final CollectionReference expensesCollection =
    FirebaseFirestore.instance.collection("expenses");

class _FirestoreCRUDState extends State<FirestoreCRUD> {
  double balance = 0.0;
  double totalIncome = 0.0;
  double totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _getBalance();
  }

  // Method to fetch balance, total income, and total expenses
  void _getBalance() async {
    final QuerySnapshot snapshot = await expensesCollection.get();
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
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: expensesCollection.snapshots(),
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
                            subtitle: Text(
                              '₹${data['amount']?.toString() ?? '0'}',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.black54),
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
                                      Navigator.pop(context);
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
                                      Navigator.pop(context); // Close menu
                                      expensesCollection
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
        onPressed: () => createBottomSheet(context),
        backgroundColor: const Color(0xFF6200EA), // Purple FAB
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void updateBottomSheet(BuildContext context, String id, String name,
      String type, String amount) {
    final TextEditingController nameController =
        TextEditingController(text: name);
    final TextEditingController amountController =
        TextEditingController(text: amount);
    String selectedType = type;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor, // Primary color
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor, // Primary color
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedType,
                    dropdownColor: Theme.of(context).primaryColorLight,
                    items: const [
                      DropdownMenuItem(
                          value: 'Expense', child: Text('Expense')),
                      DropdownMenuItem(value: 'Income', child: Text('Income')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      expensesCollection.doc(id).update({
                        'name': nameController.text.trim(),
                        'amount':
                            double.tryParse(amountController.text.trim()) ??
                                0.0,
                        'type': selectedType,
                      }).then((_) {
                        _getBalance();
                        Navigator.pop(ctx);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void createBottomSheet(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    String selectedType = 'Expense';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor, // Primary color
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor, // Primary color
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedType,
                    dropdownColor: const Color.fromARGB(255, 232, 224, 245),
                    items: const [
                      DropdownMenuItem(
                          value: 'Expense', child: Text('Expense')),
                      DropdownMenuItem(value: 'Income', child: Text('Income')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      expensesCollection.add({
                        'name': nameController.text.trim(),
                        'amount':
                            double.tryParse(amountController.text.trim()) ??
                                0.0,
                        'type': selectedType,
                      }).then((_) {
                        _getBalance();
                        Navigator.pop(ctx);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
