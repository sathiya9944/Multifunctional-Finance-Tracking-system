// // // import 'package:flutter/material.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';

// // // class ExpenseSharingPage extends StatefulWidget {
// // //   final String groupId;
// // //   ExpenseSharingPage({required this.groupId});

// // //   @override
// // //   _ExpenseSharingPageState createState() => _ExpenseSharingPageState();
// // // }

// // // class _ExpenseSharingPageState extends State<ExpenseSharingPage> {
// // //   late DocumentReference groupRef;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     groupRef =
// // //         FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
// // //   }

// // //   void _updateMemberShare(Map<String, dynamic> expense,
// // //       Map<String, dynamic> member, double newPercent) {
// // //     final totalAmount = expense['amount'] ?? 0.0;

// // //     setState(() {
// // //       member['sharePercent'] = newPercent;
// // //     });

// // //     // Calculate each member's updated share amount
// // //     final members = expense['members'] as List<dynamic>?;
// // //     members?.forEach((m) {
// // //       m['share'] = totalAmount * (m['sharePercent'] ?? 0) / 100.0;
// // //     });

// // //     // Calculate remaining amount
// // //     final remainingAmount =
// // //         totalAmount - members!.fold(0.0, (sum, m) => sum + (m['share'] ?? 0.0));

// // //     // Update Firestore
// // //     groupRef.update({
// // //       'expenses': FieldValue.arrayRemove([expense]),
// // //     }).then((_) {
// // //       expense['remainingAmount'] = remainingAmount;
// // //       groupRef.update({
// // //         'expenses': FieldValue.arrayUnion([expense]),
// // //       });
// // //     });
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text('Expense Sharing'),
// // //         backgroundColor: const Color(0xFF6200EA),
// // //       ),
// // //       body: FutureBuilder<DocumentSnapshot>(
// // //         future: groupRef.get(),
// // //         builder: (context, snapshot) {
// // //           if (snapshot.connectionState == ConnectionState.waiting) {
// // //             return Center(child: CircularProgressIndicator());
// // //           }

// // //           if (!snapshot.hasData || snapshot.data!.data() == null) {
// // //             return Center(child: Text('No data available'));
// // //           }

// // //           final groupData =
// // //               snapshot.data!.data() as Map<String, dynamic>? ?? {};
// // //           final expenses = (groupData['expenses'] as List?) ?? [];

// // //           return Padding(
// // //             padding: const EdgeInsets.all(16.0),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Text(
// // //                   'Shared Expenses:',
// // //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // //                 ),
// // //                 SizedBox(height: 10),
// // //                 Expanded(
// // //                   child: ListView.builder(
// // //                     itemCount: expenses.length,
// // //                     itemBuilder: (context, index) {
// // //                       final expense = expenses[index] as Map<String, dynamic>;
// // //                       final totalAmount = expense['amount'] ?? 0.0;
// // //                       final members =
// // //                           (expense['members'] as List<dynamic>?) ?? [];
// // //                       final remainingAmount = totalAmount -
// // //                           members.fold(
// // //                               0.0, (sum, m) => sum + (m['share'] ?? 0.0));

// // //                       return Card(
// // //                         margin: const EdgeInsets.symmetric(vertical: 10),
// // //                         child: Padding(
// // //                           padding: const EdgeInsets.all(8.0),
// // //                           child: Column(
// // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // //                             children: [
// // //                               Text(
// // //                                 'Expense: ${expense['name'] ?? 'Unknown'}',
// // //                                 style: TextStyle(
// // //                                     fontSize: 16, fontWeight: FontWeight.bold),
// // //                               ),
// // //                               Text(
// // //                                   'Total Amount: \$${totalAmount.toStringAsFixed(2)}'),
// // //                               Text(
// // //                                   'Remaining Amount: \$${remainingAmount.toStringAsFixed(2)}'),
// // //                               SizedBox(height: 10),
// // //                               if (members.isNotEmpty)
// // //                                 ...members.map((member) => Column(
// // //                                       crossAxisAlignment:
// // //                                           CrossAxisAlignment.start,
// // //                                       children: [
// // //                                         Text(
// // //                                           '${member['name'] ?? 'Unknown'} - Share Percent: ${(member['sharePercent'] ?? 0).toStringAsFixed(2)}%',
// // //                                         ),
// // //                                         Text(
// // //                                           'Share Amount: \$${(member['share'] ?? 0.0).toStringAsFixed(2)}',
// // //                                         ),
// // //                                         TextField(
// // //                                           decoration: InputDecoration(
// // //                                               labelText:
// // //                                                   'Update Share Percent for ${member['name'] ?? 'Unknown'}'),
// // //                                           keyboardType: TextInputType.number,
// // //                                           onChanged: (value) {
// // //                                             final newPercent =
// // //                                                 double.tryParse(value) ?? 0.0;
// // //                                             _updateMemberShare(
// // //                                                 expense, member, newPercent);
// // //                                           },
// // //                                         ),
// // //                                         SizedBox(height: 10),
// // //                                       ],
// // //                                     ))
// // //                               else
// // //                                 Text('No members for this expense'),
// // //                             ],
// // //                           ),
// // //                         ),
// // //                       );
// // //                     },
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }
// // // }
// // // import 'package:flutter/material.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';

// // // class ExpenseSharingPage extends StatefulWidget {
// // //   final String groupId;
// // //   ExpenseSharingPage({required this.groupId});

// // //   @override
// // //   _ExpenseSharingPageState createState() => _ExpenseSharingPageState();
// // // }

// // // class _ExpenseSharingPageState extends State<ExpenseSharingPage> {
// // //   late DocumentReference groupRef;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     groupRef =
// // //         FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
// // //   }

// // //   void _updateMemberShare(Map<String, dynamic> expense,
// // //       Map<String, dynamic> member, double newPercent) {
// // //     final totalAmount = expense['amount'] ?? 0.0;

// // //     setState(() {
// // //       member['sharePercent'] = newPercent;
// // //     });

// // //     // Calculate each member's updated share amount
// // //     final members = expense['members'] as List<dynamic>?;
// // //     members?.forEach((m) {
// // //       m['share'] = totalAmount * (m['sharePercent'] ?? 0) / 100.0;
// // //     });

// // //     // Calculate remaining amount
// // //     final remainingAmount =
// // //         totalAmount - members!.fold(0.0, (sum, m) => sum + (m['share'] ?? 0.0));

// // //     // Update Firestore
// // //     groupRef.update({
// // //       'expenses': FieldValue.arrayRemove([expense]),
// // //     }).then((_) {
// // //       expense['remainingAmount'] = remainingAmount;
// // //       groupRef.update({
// // //         'expenses': FieldValue.arrayUnion([expense]),
// // //       });
// // //     });
// // //   }

// // //   double _calculateTotalExpense(List expenses) {
// // //     double total = 0;
// // //     for (var expense in expenses) {
// // //       total += expense['amount'];
// // //     }
// // //     return total;
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text('Expense Sharing'),
// // //         backgroundColor: const Color(0xFF6200EA),
// // //       ),
// // //       body: FutureBuilder<DocumentSnapshot>(
// // //         future: groupRef.get(),
// // //         builder: (context, snapshot) {
// // //           if (snapshot.connectionState == ConnectionState.waiting) {
// // //             return Center(child: CircularProgressIndicator());
// // //           }

// // //           if (!snapshot.hasData || snapshot.data!.data() == null) {
// // //             return Center(child: Text('No data available'));
// // //           }

// // //           final groupData =
// // //               snapshot.data!.data() as Map<String, dynamic>? ?? {};
// // //           final expenses = (groupData['expenses'] as List?) ?? [];
// // //           final totalAmount = _calculateTotalExpense(expenses);
// // //           final members = (groupData['members'] as List?) ?? [];
// // //           final numberOfMembers = members.length;
// // //           final budget = groupData['budget'] ?? 0.0;
// // //           final remainingAmount = budget - totalAmount;

// // //           return Padding(
// // //             padding: const EdgeInsets.all(16.0),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Text(
// // //                   'Group Details:',
// // //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // //                 ),
// // //                 SizedBox(height: 10),
// // //                 Text('Total Expense: \$${totalAmount.toStringAsFixed(2)}'),
// // //                 Text('Number of Members: $numberOfMembers'),
// // //                 Text('Budget: \$${budget.toStringAsFixed(2)}'),
// // //                 Text(
// // //                     'Remaining Budget: \$${remainingAmount.toStringAsFixed(2)}'),
// // //                 SizedBox(height: 20),
// // //                 Text(
// // //                   'Shared Expenses:',
// // //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // //                 ),
// // //                 SizedBox(height: 10),
// // //                 Expanded(
// // //                   child: ListView.builder(
// // //                     itemCount: expenses.length,
// // //                     itemBuilder: (context, index) {
// // //                       final expense = expenses[index] as Map<String, dynamic>;
// // //                       final totalExpenseAmount = expense['amount'] ?? 0.0;
// // //                       final members =
// // //                           (expense['members'] as List<dynamic>?) ?? [];
// // //                       final remainingAmount = totalExpenseAmount -
// // //                           members.fold(
// // //                               0.0, (sum, m) => sum + (m['share'] ?? 0.0));

// // //                       return Card(
// // //                         margin: const EdgeInsets.symmetric(vertical: 10),
// // //                         child: Padding(
// // //                           padding: const EdgeInsets.all(8.0),
// // //                           child: Column(
// // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // //                             children: [
// // //                               Text(
// // //                                 'Expense: ${expense['name'] ?? 'Unknown'}',
// // //                                 style: TextStyle(
// // //                                     fontSize: 16, fontWeight: FontWeight.bold),
// // //                               ),
// // //                               Text(
// // //                                   'Total Amount: \$${totalExpenseAmount.toStringAsFixed(2)}'),
// // //                               Text(
// // //                                   'Remaining Amount: \$${remainingAmount.toStringAsFixed(2)}'),
// // //                               SizedBox(height: 10),
// // //                               if (members.isNotEmpty)
// // //                                 ...members.map((member) => Column(
// // //                                       crossAxisAlignment:
// // //                                           CrossAxisAlignment.start,
// // //                                       children: [
// // //                                         Text(
// // //                                           '${member['name'] ?? 'Unknown'} - Share Percent: ${(member['sharePercent'] ?? 0).toStringAsFixed(2)}%',
// // //                                         ),
// // //                                         Text(
// // //                                           'Share Amount: \$${(member['share'] ?? 0.0).toStringAsFixed(2)}',
// // //                                         ),
// // //                                         TextField(
// // //                                           decoration: InputDecoration(
// // //                                               labelText:
// // //                                                   'Update Share Percent for ${member['name'] ?? 'Unknown'}'),
// // //                                           keyboardType: TextInputType.number,
// // //                                           onChanged: (value) {
// // //                                             final newPercent =
// // //                                                 double.tryParse(value) ?? 0.0;
// // //                                             _updateMemberShare(
// // //                                                 expense, member, newPercent);
// // //                                           },
// // //                                         ),
// // //                                         SizedBox(height: 10),
// // //                                       ],
// // //                                     ))
// // //                               else
// // //                                 Text('No members for this expense'),
// // //                             ],
// // //                           ),
// // //                         ),
// // //                       );
// // //                     },
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //       bottomNavigationBar: Padding(
// // //         padding: const EdgeInsets.all(16.0),
// // //         child: ElevatedButton(
// // //           onPressed: () {
// // //             // Split the bill when button is pressed
// // //             double totalAmount = 0.0;
// // //             List<Map<String, dynamic>> members = [];
// // //             // Calculate total expense and gather member data
// // //             groupRef.get().then((snapshot) {
// // //               if (snapshot.exists) {
// // //                 final data = snapshot.data() as Map<String, dynamic>;
// // //                 final expenses = data['expenses'] as List<dynamic>;
// // //                 for (var expense in expenses) {
// // //                   totalAmount += expense['amount'] ?? 0.0;
// // //                   members.addAll(expense['members'] ?? []);
// // //                 }
// // //               }
// // //               // Calculate individual split amount
// // //               final splitAmount = totalAmount / members.length;

// // //               // Update each member's share in Firestore
// // //               members.forEach((member) {
// // //                 member['share'] = splitAmount;
// // //               });

// // //               // Update Firestore with the new split amounts
// // //               groupRef.update({
// // //                 'members': members,
// // //               }).then((_) {
// // //                 ScaffoldMessenger.of(context).showSnackBar(
// // //                   SnackBar(content: Text('Expenses split successfully!')),
// // //                 );
// // //               });
// // //             });
// // //           },
// // //           child: Text('Split Bill'),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class ExpenseSharingPage extends StatefulWidget {
// //   final String groupId;

// //   ExpenseSharingPage({required this.groupId});

// //   @override
// //   _ExpenseSharingPageState createState() => _ExpenseSharingPageState();
// // }

// // class _ExpenseSharingPageState extends State<ExpenseSharingPage> {
// //   late DocumentReference groupRef;

// //   @override
// //   void initState() {
// //     super.initState();
// //     groupRef =
// //         FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
// //   }

// //   /// Updates the share percentage and recalculates share amounts.
// //   void _updateMemberShare(Map<String, dynamic> expense,
// //       Map<String, dynamic> member, double newPercent) async {
// //     final totalAmount = expense['amount'] ?? 0.0;

// //     setState(() {
// //       member['sharePercent'] = newPercent;
// //       member['share'] = (newPercent / 100.0) * totalAmount;
// //     });

// //     // Update Firestore with the new expense data
// //     try {
// //       final updatedMembers =
// //           List<Map<String, dynamic>>.from(expense['members']);
// //       final updatedExpense = {...expense, 'members': updatedMembers};

// //       await groupRef.update({
// //         'expenses': FieldValue.arrayRemove([expense]),
// //       });

// //       await groupRef.update({
// //         'expenses': FieldValue.arrayUnion([updatedExpense]),
// //       });

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Share updated successfully!')),
// //       );
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Failed to update share: $e')),
// //       );
// //     }
// //   }

// //   /// Calculates the total expense from a list of expenses.
// //   double _calculateTotalExpense(List expenses) {
// //     return expenses.fold(
// //       0.0,
// //       (total, expense) => total + (expense['amount'] ?? 0.0),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Expense Sharing'),
// //         backgroundColor: const Color(0xFF6200EA),
// //       ),
// //       body: FutureBuilder<DocumentSnapshot>(
// //         future: groupRef.get(),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return Center(child: CircularProgressIndicator());
// //           }

// //           if (!snapshot.hasData || snapshot.data?.data() == null) {
// //             return Center(child: Text('No group data available.'));
// //           }

// //           final groupData = snapshot.data!.data() as Map<String, dynamic>;
// //           final expenses = (groupData['expenses'] as List?) ?? [];
// //           final members = (groupData['members'] as List?) ?? [];
// //           final budget = groupData['budget'] ?? 0.0;
// //           final totalExpense = _calculateTotalExpense(expenses);
// //           final remainingBudget = budget - totalExpense;

// //           return Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   'Group Details:',
// //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //                 ),
// //                 SizedBox(height: 10),
// //                 Text('Total Expense: ₹${totalExpense.toStringAsFixed(2)}'),
// //                 Text(
// //                     'Remaining Budget: ₹${remainingBudget.toStringAsFixed(2)}'),
// //                 SizedBox(height: 20),
// //                 Text(
// //                   'Shared Expenses:',
// //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //                 ),
// //                 SizedBox(height: 10),
// //                 Expanded(
// //                   child: ListView.builder(
// //                     itemCount: expenses.length,
// //                     itemBuilder: (context, index) {
// //                       final expense = expenses[index] as Map<String, dynamic>;
// //                       final expenseMembers =
// //                           (expense['members'] as List<dynamic>?) ?? [];

// //                       return Card(
// //                         margin: const EdgeInsets.symmetric(vertical: 8.0),
// //                         child: Padding(
// //                           padding: const EdgeInsets.all(10.0),
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 'Expense: ${expense['name'] ?? 'Unnamed'}',
// //                                 style: TextStyle(
// //                                     fontSize: 16, fontWeight: FontWeight.bold),
// //                               ),
// //                               Text(
// //                                   'Total Amount: ₹${(expense['amount'] ?? 0.0).toStringAsFixed(2)}'),
// //                               Divider(),
// //                               Text(
// //                                 'Members:',
// //                                 style: TextStyle(fontWeight: FontWeight.bold),
// //                               ),
// //                               if (expenseMembers.isNotEmpty)
// //                                 ...expenseMembers.map((member) => Padding(
// //                                       padding: const EdgeInsets.symmetric(
// //                                           vertical: 4.0),
// //                                       child: Column(
// //                                         crossAxisAlignment:
// //                                             CrossAxisAlignment.start,
// //                                         children: [
// //                                           Text(
// //                                               '${member['name'] ?? 'Unknown'} - Share: ₹${(member['share'] ?? 0.0).toStringAsFixed(2)}'),
// //                                           TextField(
// //                                             decoration: InputDecoration(
// //                                               labelText:
// //                                                   'Update Share (%) for ${member['name'] ?? 'Member'}',
// //                                               border: OutlineInputBorder(),
// //                                             ),
// //                                             keyboardType:
// //                                                 TextInputType.numberWithOptions(
// //                                                     decimal: true),
// //                                             onChanged: (value) {
// //                                               final newPercent =
// //                                                   double.tryParse(value) ?? 0.0;
// //                                               _updateMemberShare(
// //                                                   expense, member, newPercent);
// //                                             },
// //                                           ),
// //                                         ],
// //                                       ),
// //                                     ))
// //                               else
// //                                 Text('No members for this expense.'),
// //                             ],
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //       bottomNavigationBar: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: ElevatedButton(
// //           onPressed: () async {
// //             try {
// //               final snapshot = await groupRef.get();
// //               final groupData = snapshot.data() as Map<String, dynamic>;
// //               final members = groupData['members'] as List<dynamic>? ?? [];
// //               final totalExpense = _calculateTotalExpense(
// //                   groupData['expenses'] as List<dynamic>);

// //               if (members.isNotEmpty) {
// //                 final splitAmount = totalExpense / members.length;

// //                 members.forEach((member) {
// //                   member['share'] = splitAmount;
// //                 });

// //                 await groupRef.update({'members': members});
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   SnackBar(content: Text('Bill split successfully!')),
// //                 );
// //               } else {
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   SnackBar(content: Text('No members to split the bill.')),
// //                 );
// //               }
// //             } catch (e) {
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 SnackBar(content: Text('Error splitting the bill: $e')),
// //               );
// //             }
// //           },
// //           child: Text('Split Bill'),
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth for user details

// class ExpenseSharingPage extends StatefulWidget {
//   final String groupId;
//   ExpenseSharingPage({required this.groupId});

//   @override
//   _ExpenseSharingPageState createState() => _ExpenseSharingPageState();
// }

// class _ExpenseSharingPageState extends State<ExpenseSharingPage> {
//   final TextEditingController _inviteEmailController = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Function to invite a new member
//   void _inviteMember() {
//     String email = _inviteEmailController.text.trim();
//     if (email.isNotEmpty) {
//       _firestore
//           .collection('users')
//           .where('email', isEqualTo: email)
//           .get()
//           .then((querySnapshot) {
//         if (querySnapshot.docs.isNotEmpty) {
//           var userDoc = querySnapshot.docs.first;
//           _firestore.collection('groups').doc(widget.groupId).update({
//             'members': FieldValue.arrayUnion(
//                 [userDoc.id]) // Add the user's UID to the group members
//           });

//           // Send an invite email or notification (if required)
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Invite sent to $email!')),
//           );

//           _inviteEmailController.clear();
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('User not found!')),
//           );
//         }
//       });
//     }
//   }

//   // Fetch group members
//   Stream<List<String>> _fetchGroupMembers() {
//     return _firestore
//         .collection('groups')
//         .doc(widget.groupId)
//         .snapshots()
//         .map((snapshot) {
//       List<dynamic> members = snapshot.data()?['members'] ?? [];
//       return List<String>.from(members);
//     });
//   }

//   // Fetch shared expenses for group members
//   Stream<List<Map<String, dynamic>>> _fetchSharedExpenses() {
//     return _firestore
//         .collection('groups')
//         .doc(widget.groupId)
//         .snapshots()
//         .map((snapshot) {
//       List<dynamic> expenses = snapshot.data()?['expenses'] ?? [];
//       return List<Map<String, dynamic>>.from(expenses);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Expense Sharing'),
//         leading: BackButton(),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Invite member section
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _inviteEmailController,
//                     decoration: InputDecoration(
//                       labelText: 'Invite by Email',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: _inviteMember,
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             // List of Group Members
//             Text('Group Members:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             StreamBuilder<List<String>>(
//               stream: _fetchGroupMembers(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData) {
//                   return Center(child: Text('No members found'));
//                 }

//                 final members = snapshot.data!;
//                 return Expanded(
//                   child: ListView.builder(
//                     itemCount: members.length,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         title:
//                             Text(members[index]), // Display user name or email
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//             SizedBox(height: 20),
//             // List of Shared Expenses
//             Text('Shared Expenses:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             StreamBuilder<List<Map<String, dynamic>>>(
//               stream: _fetchSharedExpenses(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData) {
//                   return Center(child: Text('No shared expenses found'));
//                 }

//                 final expenses = snapshot.data!;
//                 return Expanded(
//                   child: ListView.builder(
//                     itemCount: expenses.length,
//                     itemBuilder: (context, index) {
//                       final expense = expenses[index];
//                       return ListTile(
//                         title: Text(expense['name']),
//                         subtitle:
//                             Text('₹${expense['amount'].toStringAsFixed(2)}'),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package

class ExpenseSharingPage extends StatelessWidget {
  final String groupId;
  ExpenseSharingPage({required this.groupId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch and display expenses
  Stream<DocumentSnapshot> _fetchGroupData() {
    return _firestore.collection('groups').doc(groupId).snapshots();
  }

  double _calculateTotalExpense(List expenses) {
    double total = 0;
    for (var expense in expenses) {
      total += expense['amount'];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _fetchGroupData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading Expenses...'),
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

        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${groupData['name']} - Expense Sharing',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF6200EA),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            'Total Expenses',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6200EA),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '₹${totalExpense.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6200EA),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                          // Implement edit logic similar to what is done in GroupDetailsPage
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
                icon: Icon(Icons.arrow_back),
                label: 'Back to Group Details',
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }
}
