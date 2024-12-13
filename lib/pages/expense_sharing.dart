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

  @override
  void initState() {
    super.initState();
    groupRef =
        FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
  }

  void _updateMemberShare(Map<String, dynamic> expense,
      Map<String, dynamic> member, double newPercent) {
    final totalAmount = expense['amount'] ?? 0.0;

    setState(() {
      member['sharePercent'] = newPercent;
    });

    // Calculate each member's updated share amount
    final members = expense['members'] as List<dynamic>?;
    members?.forEach((m) {
      m['share'] = totalAmount * (m['sharePercent'] ?? 0) / 100.0;
    });

    // Calculate remaining amount
    final remainingAmount =
        totalAmount - members!.fold(0.0, (sum, m) => sum + (m['share'] ?? 0.0));

    // Update Firestore
    groupRef.update({
      'expenses': FieldValue.arrayRemove([expense]),
    }).then((_) {
      expense['remainingAmount'] = remainingAmount;
      groupRef.update({
        'expenses': FieldValue.arrayUnion([expense]),
      });
    });
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shared Expenses:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index] as Map<String, dynamic>;
                      final totalAmount = expense['amount'] ?? 0.0;
                      final members =
                          (expense['members'] as List<dynamic>?) ?? [];
                      final remainingAmount = totalAmount -
                          members.fold(
                              0.0, (sum, m) => sum + (m['share'] ?? 0.0));

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expense: ${expense['name'] ?? 'Unknown'}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  'Total Amount: \$${totalAmount.toStringAsFixed(2)}'),
                              Text(
                                  'Remaining Amount: \$${remainingAmount.toStringAsFixed(2)}'),
                              SizedBox(height: 10),
                              if (members.isNotEmpty)
                                ...members.map((member) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${member['name'] ?? 'Unknown'} - Share Percent: ${(member['sharePercent'] ?? 0).toStringAsFixed(2)}%',
                                        ),
                                        Text(
                                          'Share Amount: \$${(member['share'] ?? 0.0).toStringAsFixed(2)}',
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                              labelText:
                                                  'Update Share Percent for ${member['name'] ?? 'Unknown'}'),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            final newPercent =
                                                double.tryParse(value) ?? 0.0;
                                            _updateMemberShare(
                                                expense, member, newPercent);
                                          },
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    ))
                              else
                                Text('No members for this expense'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
