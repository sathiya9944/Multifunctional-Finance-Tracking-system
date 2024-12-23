import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseSharingPage extends StatefulWidget {
  final String groupId;

  ExpenseSharingPage({required this.groupId});

  @override
  _ExpenseSharingPageState createState() => _ExpenseSharingPageState();
}

class _ExpenseSharingPageState extends State<ExpenseSharingPage> {
  late DocumentReference groupRef;
  Map<String, String> memberNames = {}; // Cache for UID-to-Name mapping
  Map<String, TextEditingController> splitControllers = {};
  Map<String, double> splitPercentages = {}; // Store entered split percentages

  @override
  void initState() {
    super.initState();
    groupRef =
        FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
  }

  Future<void> _fetchMemberNames(List members) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');

    for (var member in members) {
      final uid = member['uid'];
      if (uid != null && !memberNames.containsKey(uid)) {
        try {
          final userDoc = await usersCollection.doc(uid).get();
          if (userDoc.exists) {
            setState(() {
              memberNames[uid] = userDoc['name'] ?? 'Unknown';
            });
          } else {
            setState(() {
              memberNames[uid] = 'Unknown';
            });
          }
        } catch (e) {
          setState(() {
            memberNames[uid] = 'Error';
          });
        }
      }
    }
  }

  double _calculateTotalExpense(List expenses) {
    return expenses.fold(
        0.0, (sum, expense) => sum + (expense['amount'] ?? 0.0));
  }

  Map<String, double> _calculateMemberContributions(
      List members, List expenses) {
    Map<String, double> contributions = {};

    for (var member in members) {
      final uid = member['uid'];
      if (uid != null) {
        contributions[uid] = 0.0;
      }
    }

    for (var expense in expenses) {
      final spendByList = expense['spentBy'] ?? [];
      final amount = (expense['amount'] ?? 0).toDouble();

      for (var uid in spendByList) {
        if (contributions.containsKey(uid)) {
          contributions[uid] = (contributions[uid] ?? 0.0) + amount;
        }
      }
    }

    return contributions;
  }

  double _calculateSplit(double totalAmount, String uid) {
    final percentage = splitPercentages[uid] ?? (100 / splitControllers.length);
    return totalAmount * (percentage / 100);
  }

  double _calculateBalance(double contribution, double fairShare) {
    return contribution - fairShare;
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

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('No data available'));
          }

          final groupData =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final expenses = (groupData['expenses'] as List?) ?? [];
          final totalAmount = _calculateTotalExpense(expenses);
          final members = (groupData['members'] as List?) ?? [];
          final budget = groupData['budget'] ?? 0.0;

          _fetchMemberNames(members);
          final contributions =
              _calculateMemberContributions(members, expenses);

          return Container(
            color: const Color(0xFFF2F2F2),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Group Details Card
                _buildGroupDetailsCard(totalAmount, members.length, budget),
                SizedBox(height: 20),
                // Members List Card
                _buildMembersListCard(members, contributions, totalAmount),
                SizedBox(height: 20),
                // New Split Card with % Input
                _buildSplitPercentageCard(members, totalAmount),
              ],
            ),
          );
        },
      ),
    );
  }

  // Group Details Card
  Widget _buildGroupDetailsCard(
      double totalAmount, int memberCount, double budget) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.group, color: const Color(0xFF6200EA), size: 28),
                SizedBox(width: 10),
                Text(
                  'Group Details',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6200EA)),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Total Expense: \$${totalAmount.toStringAsFixed(2)}'),
            Text('Number of Members: $memberCount'),
            Text('Budget: \$${budget.toStringAsFixed(2)}'),
            Text(
              'Remaining Budget: \$${(budget - totalAmount).toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  // Members List Card
  Widget _buildMembersListCard(
      List members, Map<String, double> contributions, double totalAmount) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: members.map((member) {
            final uid = member['uid'];
            final name = memberNames[uid] ?? 'Loading...';
            final contribution = contributions[uid] ?? 0.0;
            final fairShare = _calculateSplit(totalAmount, uid);
            final balance = _calculateBalance(contribution, fairShare);

            return ListTile(
              leading: Icon(Icons.person, color: Colors.blue),
              title: Text('$name'),
              subtitle:
                  Text('Contribution: \$${contribution.toStringAsFixed(2)}'),
              trailing: Text(
                'Balance: \$${balance.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

// Split Percentage Card
  Widget _buildSplitPercentageCard(List members, double totalAmount) {
    double totalEnteredPercentage = splitPercentages.values.fold(
      0.0,
      (sum, percentage) => sum + percentage,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: Colors.green, size: 28),
                SizedBox(width: 10),
                Text(
                  'Split Expense',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
            SizedBox(height: 10),
            Column(
              children: members.map((member) {
                final uid = member['uid'];
                final name = memberNames[uid] ?? 'Loading...';
                splitControllers[uid] ??= TextEditingController();

                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text('$name'),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: splitControllers[uid],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Split %',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            splitPercentages[uid] =
                                double.tryParse(value) ?? 0.0;
                            totalEnteredPercentage =
                                splitPercentages.values.fold(
                              0.0,
                              (sum, percentage) => sum + percentage,
                            );

                            // If total exceeds 100%, reset the value and show error
                            if (totalEnteredPercentage > 100.0) {
                              splitControllers[uid]?.text = '';
                              splitPercentages[uid] = 0.0;
                              totalEnteredPercentage = splitPercentages.values
                                  .fold(0.0,
                                      (sum, percentage) => sum + percentage);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Total percentage cannot exceed 100%.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              );
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Share: \$${_calculateSplit(totalAmount, uid).toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            // Remaining Percentage
            Text(
              'Total Entered Percentage: ${totalEnteredPercentage.toStringAsFixed(2)}%',
              style: TextStyle(
                color:
                    totalEnteredPercentage == 100.0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (totalEnteredPercentage != 100.0)
              Text(
                'Ensure the total percentage equals 100%',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
