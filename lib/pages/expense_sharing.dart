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
// // //   Map<String, String> memberNames = {}; // Cache for UID-to-Name mapping

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     groupRef =
// // //         FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
// // //   }

// // //   Future<void> _fetchMemberNames(List members) async {
// // //     final usersCollection = FirebaseFirestore.instance.collection('users');

// // //     for (var member in members) {
// // //       final uid = member['uid'];
// // //       if (uid != null && !memberNames.containsKey(uid)) {
// // //         try {
// // //           // Fetch user document from Firestore
// // //           final userDoc = await usersCollection.doc(uid).get();
// // //           if (userDoc.exists) {
// // //             setState(() {
// // //               memberNames[uid] = userDoc['name'] ?? 'Unknown';
// // //             });
// // //           } else {
// // //             setState(() {
// // //               memberNames[uid] = 'Unknown';
// // //             });
// // //           }
// // //         } catch (e) {
// // //           // Handle errors
// // //           setState(() {
// // //             memberNames[uid] = 'Error';
// // //           });
// // //         }
// // //       }
// // //     }
// // //   }

// // //   double _calculateTotalExpense(List expenses) {
// // //     double total = 0;
// // //     for (var expense in expenses) {
// // //       total += expense['amount'] ?? 0.0;
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
// // //           final budget = groupData['budget'] ?? 0.0;
// // //           final remainingAmount = budget - totalAmount;

// // //           // Fetch member names based on UIDs
// // //           _fetchMemberNames(members);

// // //           return Container(
// // //             color: const Color(0xFFF2F2F2), // Light gray background
// // //             child: Padding(
// // //               padding: const EdgeInsets.all(16.0),
// // //               child: ListView(
// // //                 children: [
// // //                   // Group Details Card
// // //                   Card(
// // //                     elevation: 4,
// // //                     shape: RoundedRectangleBorder(
// // //                       borderRadius: BorderRadius.circular(12),
// // //                     ),
// // //                     margin: const EdgeInsets.only(bottom: 20),
// // //                     child: Padding(
// // //                       padding: const EdgeInsets.all(20.0),
// // //                       child: Column(
// // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // //                         children: [
// // //                           Row(
// // //                             children: [
// // //                               Icon(Icons.group,
// // //                                   color: const Color(0xFF6200EA), size: 28),
// // //                               SizedBox(width: 10),
// // //                               Text(
// // //                                 'Group Details',
// // //                                 style: TextStyle(
// // //                                     fontSize: 20,
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: const Color(0xFF6200EA)),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                           SizedBox(height: 20),
// // //                           Row(
// // //                             children: [
// // //                               Icon(Icons.monetization_on, color: Colors.green),
// // //                               SizedBox(width: 10),
// // //                               Text(
// // //                                 'Total Expense: \$${totalAmount.toStringAsFixed(2)}',
// // //                                 style: TextStyle(fontSize: 16),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                           SizedBox(height: 10),
// // //                           Row(
// // //                             children: [
// // //                               Icon(Icons.people, color: Colors.blue),
// // //                               SizedBox(width: 10),
// // //                               Text(
// // //                                 'Number of Members: ${members.length}',
// // //                                 style: TextStyle(fontSize: 16),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                           SizedBox(height: 10),
// // //                           Row(
// // //                             children: [
// // //                               Icon(Icons.attach_money, color: Colors.orange),
// // //                               SizedBox(width: 10),
// // //                               Text(
// // //                                 'Budget: \$${budget.toStringAsFixed(2)}',
// // //                                 style: TextStyle(fontSize: 16),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                           SizedBox(height: 10),
// // //                           Row(
// // //                             children: [
// // //                               Icon(Icons.savings, color: Colors.red),
// // //                               SizedBox(width: 10),
// // //                               Text(
// // //                                 'Remaining Budget: \$${remainingAmount.toStringAsFixed(2)}',
// // //                                 style: TextStyle(fontSize: 16),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ),
// // //                   // Members List Card
// // //                   Card(
// // //                     elevation: 4,
// // //                     shape: RoundedRectangleBorder(
// // //                       borderRadius: BorderRadius.circular(12),
// // //                     ),
// // //                     child: Padding(
// // //                       padding: const EdgeInsets.all(20.0),
// // //                       child: Column(
// // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // //                         children: [
// // //                           Row(
// // //                             children: [
// // //                               Icon(Icons.person, color: Colors.blue, size: 28),
// // //                               SizedBox(width: 10),
// // //                               Text(
// // //                                 'Members',
// // //                                 style: TextStyle(
// // //                                   fontSize: 20,
// // //                                   fontWeight: FontWeight.bold,
// // //                                   color: Colors.blue,
// // //                                 ),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                           SizedBox(height: 20),
// // //                           ...members.map((member) {
// // //                             final uid = member['uid'];
// // //                             final name = memberNames[uid] ?? 'Loading...';
// // //                             return Padding(
// // //                               padding:
// // //                                   const EdgeInsets.symmetric(vertical: 8.0),
// // //                               child: Row(
// // //                                 children: [
// // //                                   Icon(Icons.person_outline,
// // //                                       color: Colors.grey, size: 24),
// // //                                   SizedBox(width: 10),
// // //                                   Column(
// // //                                     crossAxisAlignment:
// // //                                         CrossAxisAlignment.start,
// // //                                     children: [
// // //                                       Text(
// // //                                         'Name: $name',
// // //                                         style: TextStyle(fontSize: 16),
// // //                                       ),
// // //                                       Text(
// // //                                         'UID: ${uid ?? 'N/A'}',
// // //                                         style: TextStyle(
// // //                                           fontSize: 14,
// // //                                           color: Colors.grey[600],
// // //                                         ),
// // //                                       ),
// // //                                     ],
// // //                                   ),
// // //                                 ],
// // //                               ),
// // //                             );
// // //                           }).toList(),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           );
// // //         },
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
// //   Map<String, String> memberNames = {}; // Cache for UID-to-Name mapping

// //   @override
// //   void initState() {
// //     super.initState();
// //     groupRef =
// //         FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
// //   }

// //   Future<void> _fetchMemberNames(List members) async {
// //     final usersCollection = FirebaseFirestore.instance.collection('users');

// //     for (var member in members) {
// //       final uid = member['uid'];
// //       if (uid != null && !memberNames.containsKey(uid)) {
// //         try {
// //           // Fetch user document from Firestore
// //           final userDoc = await usersCollection.doc(uid).get();
// //           if (userDoc.exists) {
// //             setState(() {
// //               memberNames[uid] = userDoc['name'] ?? 'Unknown';
// //             });
// //           } else {
// //             setState(() {
// //               memberNames[uid] = 'Unknown';
// //             });
// //           }
// //         } catch (e) {
// //           // Handle errors
// //           setState(() {
// //             memberNames[uid] = 'Error';
// //           });
// //         }
// //       }
// //     }
// //   }

// //   double _calculateTotalExpense(List expenses) {
// //     double total = 0;
// //     for (var expense in expenses) {
// //       total += expense['amount'] ?? 0.0;
// //     }
// //     return total;
// //   }

// //   Map<String, double> _calculateMemberContributions(
// //       List members, List expenses) {
// //     Map<String, double> contributions = {};

// //     // Initialize contributions to 0 for all members
// //     for (var member in members) {
// //       contributions[member['uid']] = 0.0;
// //     }

// //     // Add up each member's expenses
// //     for (var expense in expenses) {
// //       final uid = expense['uid'];
// //       final amount = expense['amount'] ?? 0.0;
// //       if (uid != null && contributions.containsKey(uid)) {
// //         contributions[uid] = (contributions[uid] ?? 0.0) + amount;
// //       }
// //     }

// //     return contributions;
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

// //           if (!snapshot.hasData || snapshot.data!.data() == null) {
// //             return Center(child: Text('No data available'));
// //           }

// //           final groupData =
// //               snapshot.data!.data() as Map<String, dynamic>? ?? {};
// //           final expenses = (groupData['expenses'] as List?) ?? [];
// //           final totalAmount = _calculateTotalExpense(expenses);
// //           final members = (groupData['members'] as List?) ?? [];
// //           final budget = groupData['budget'] ?? 0.0;
// //           final remainingAmount = budget - totalAmount;

// //           // Fetch member names based on UIDs
// //           _fetchMemberNames(members);

// //           // Calculate contributions and shares
// //           final contributions =
// //               _calculateMemberContributions(members, expenses);
// //           final sharePerMember =
// //               members.isNotEmpty ? totalAmount / members.length : 0.0;

// //           return Container(
// //             color: const Color(0xFFF2F2F2), // Light gray background
// //             child: Padding(
// //               padding: const EdgeInsets.all(16.0),
// //               child: ListView(
// //                 children: [
// //                   // Group Details Card
// //                   Card(
// //                     elevation: 4,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     margin: const EdgeInsets.only(bottom: 20),
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(20.0),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Row(
// //                             children: [
// //                               Icon(Icons.group,
// //                                   color: const Color(0xFF6200EA), size: 28),
// //                               SizedBox(width: 10),
// //                               Text(
// //                                 'Group Details',
// //                                 style: TextStyle(
// //                                     fontSize: 20,
// //                                     fontWeight: FontWeight.bold,
// //                                     color: const Color(0xFF6200EA)),
// //                               ),
// //                             ],
// //                           ),
// //                           SizedBox(height: 20),
// //                           Row(
// //                             children: [
// //                               Icon(Icons.monetization_on, color: Colors.green),
// //                               SizedBox(width: 10),
// //                               Text(
// //                                 'Total Expense: \$${totalAmount.toStringAsFixed(2)}',
// //                                 style: TextStyle(fontSize: 16),
// //                               ),
// //                             ],
// //                           ),
// //                           SizedBox(height: 10),
// //                           Row(
// //                             children: [
// //                               Icon(Icons.people, color: Colors.blue),
// //                               SizedBox(width: 10),
// //                               Text(
// //                                 'Number of Members: ${members.length}',
// //                                 style: TextStyle(fontSize: 16),
// //                               ),
// //                             ],
// //                           ),
// //                           SizedBox(height: 10),
// //                           Row(
// //                             children: [
// //                               Icon(Icons.attach_money, color: Colors.orange),
// //                               SizedBox(width: 10),
// //                               Text(
// //                                 'Budget: \$${budget.toStringAsFixed(2)}',
// //                                 style: TextStyle(fontSize: 16),
// //                               ),
// //                             ],
// //                           ),
// //                           SizedBox(height: 10),
// //                           Row(
// //                             children: [
// //                               Icon(Icons.savings, color: Colors.red),
// //                               SizedBox(width: 10),
// //                               Text(
// //                                 'Remaining Budget: \$${remainingAmount.toStringAsFixed(2)}',
// //                                 style: TextStyle(fontSize: 16),
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                   // Members List Card with Contributions and Shares
// //                   Card(
// //                     elevation: 4,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(20.0),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Row(
// //                             children: [
// //                               Icon(Icons.person, color: Colors.blue, size: 28),
// //                               SizedBox(width: 10),
// //                               Text(
// //                                 'Members',
// //                                 style: TextStyle(
// //                                   fontSize: 20,
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.blue,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                           SizedBox(height: 20),
// //                           ...members.map((member) {
// //                             final uid = member['uid'];
// //                             final name = memberNames[uid] ?? 'Loading...';
// //                             final contribution = contributions[uid] ?? 0.0;
// //                             return Padding(
// //                               padding:
// //                                   const EdgeInsets.symmetric(vertical: 8.0),
// //                               child: Row(
// //                                 children: [
// //                                   Icon(Icons.person_outline,
// //                                       color: Colors.grey, size: 24),
// //                                   SizedBox(width: 10),
// //                                   Expanded(
// //                                     child: Column(
// //                                       crossAxisAlignment:
// //                                           CrossAxisAlignment.start,
// //                                       children: [
// //                                         Text(
// //                                           'Name: $name',
// //                                           style: TextStyle(fontSize: 16),
// //                                         ),
// //                                         Text(
// //                                           'UID: ${uid ?? 'N/A'}',
// //                                           style: TextStyle(
// //                                             fontSize: 14,
// //                                             color: Colors.grey[600],
// //                                           ),
// //                                         ),
// //                                         Text(
// //                                           'Contribution: \$${contribution.toStringAsFixed(2)}',
// //                                           style: TextStyle(
// //                                             fontSize: 14,
// //                                             color: Colors.green,
// //                                           ),
// //                                         ),
// //                                         Text(
// //                                           'Share: \$${sharePerMember.toStringAsFixed(2)}',
// //                                           style: TextStyle(
// //                                             fontSize: 14,
// //                                             color: Colors.orange,
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             );
// //                           }).toList(),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ExpenseSharingPage extends StatefulWidget {
//   final String groupId;
//   ExpenseSharingPage({required this.groupId});

//   @override
//   _ExpenseSharingPageState createState() => _ExpenseSharingPageState();
// }

// class _ExpenseSharingPageState extends State<ExpenseSharingPage> {
//   late DocumentReference groupRef;
//   Map<String, String> memberNames = {}; // Cache for UID-to-Name mapping

//   @override
//   void initState() {
//     super.initState();
//     groupRef =
//         FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
//   }

//   Future<void> _fetchMemberNames(List members) async {
//     final usersCollection = FirebaseFirestore.instance.collection('users');

//     for (var member in members) {
//       final uid = member['uid'];
//       if (uid != null && !memberNames.containsKey(uid)) {
//         try {
//           // Fetch user document from Firestore
//           final userDoc = await usersCollection.doc(uid).get();
//           if (userDoc.exists) {
//             setState(() {
//               memberNames[uid] = userDoc['name'] ?? 'Unknown';
//             });
//           } else {
//             setState(() {
//               memberNames[uid] = 'Unknown';
//             });
//           }
//         } catch (e) {
//           // Handle errors
//           setState(() {
//             memberNames[uid] = 'Error';
//           });
//         }
//       }
//     }
//   }

//   double _calculateTotalExpense(List expenses) {
//     double total = 0;
//     for (var expense in expenses) {
//       total += expense['amount'] ?? 0.0;
//     }
//     return total;
//   }

//   Map<String, double> _calculateMemberContributions(
//       List members, List expenses) {
//     Map<String, double> contributions = {};

//     // Initialize contributions for all members
//     for (var member in members) {
//       final uid = member['uid'];
//       if (uid != null) {
//         contributions[uid] = 0.0;
//       }
//     }

//     // Iterate over expenses and handle spentBy as an array
//     for (var expense in expenses) {
//       final spendByList = expense['spentBy'] ?? [];
//       final amount = (expense['amount'] ?? 0).toDouble();

//       // Add the amount for each member in the spentBy array
//       for (var uid in spendByList) {
//         if (contributions.containsKey(uid)) {
//           contributions[uid] = (contributions[uid] ?? 0.0) + amount;
//         }
//       }
//     }

//     return contributions;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Expense Sharing'),
//         backgroundColor: const Color(0xFF6200EA),
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: groupRef.get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.data() == null) {
//             return Center(child: Text('No data available'));
//           }

//           final groupData =
//               snapshot.data!.data() as Map<String, dynamic>? ?? {};
//           final expenses = (groupData['expenses'] as List?) ?? [];
//           final totalAmount = _calculateTotalExpense(expenses);
//           final members = (groupData['members'] as List?) ?? [];
//           final budget = groupData['budget'] ?? 0.0;
//           final remainingAmount = budget - totalAmount;

//           // Fetch member names based on UIDs
//           _fetchMemberNames(members);

//           // Calculate contributions and shares
//           final contributions =
//               _calculateMemberContributions(members, expenses);
//           final sharePerMember =
//               members.isNotEmpty ? totalAmount / members.length : 0.0;

//           return Container(
//             color: const Color(0xFFF2F2F2), // Light gray background
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ListView(
//                 children: [
//                   // Group Details Card
//                   Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     margin: const EdgeInsets.only(bottom: 20),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.group,
//                                   color: const Color(0xFF6200EA), size: 28),
//                               SizedBox(width: 10),
//                               Text(
//                                 'Group Details',
//                                 style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                     color: const Color(0xFF6200EA)),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 20),
//                           Row(
//                             children: [
//                               Icon(Icons.monetization_on, color: Colors.green),
//                               SizedBox(width: 10),
//                               Text(
//                                 'Total Expense: \$${totalAmount.toStringAsFixed(2)}',
//                                 style: TextStyle(fontSize: 16),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 10),
//                           Row(
//                             children: [
//                               Icon(Icons.people, color: Colors.blue),
//                               SizedBox(width: 10),
//                               Text(
//                                 'Number of Members: ${members.length}',
//                                 style: TextStyle(fontSize: 16),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 10),
//                           Row(
//                             children: [
//                               Icon(Icons.attach_money, color: Colors.orange),
//                               SizedBox(width: 10),
//                               Text(
//                                 'Budget: \$${budget.toStringAsFixed(2)}',
//                                 style: TextStyle(fontSize: 16),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 10),
//                           Row(
//                             children: [
//                               Icon(Icons.savings, color: Colors.red),
//                               SizedBox(width: 10),
//                               Text(
//                                 'Remaining Budget: \$${remainingAmount.toStringAsFixed(2)}',
//                                 style: TextStyle(fontSize: 16),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   // Members List Card with Contributions and Shares
//                   Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.person, color: Colors.blue, size: 28),
//                               SizedBox(width: 10),
//                               Text(
//                                 'Members',
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 20),
//                           ...members.map((member) {
//                             final uid = member['uid'];
//                             final name = memberNames[uid] ?? 'Loading...';
//                             final contribution = contributions[uid] ?? 0.0;
//                             return Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 8.0),
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.person_outline,
//                                       color: Colors.grey, size: 24),
//                                   SizedBox(width: 10),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Name: $name',
//                                           style: TextStyle(fontSize: 16),
//                                         ),
//                                         Text(
//                                           'UID: ${uid ?? 'N/A'}',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                         Text(
//                                           'Contribution: \$${contribution.toStringAsFixed(2)}',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.green,
//                                           ),
//                                         ),
//                                         Text(
//                                           'Share: \$${sharePerMember.toStringAsFixed(2)}',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.orange,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }).toList(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
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
          // Fetch user document from Firestore
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
    double total = 0;
    for (var expense in expenses) {
      total += expense['amount'] ?? 0.0;
    }
    return total;
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Group Details Card
                  _buildGroupDetailsCard(totalAmount, members.length, budget),
                  // Members List Card
                  _buildMembersListCard(members, contributions, totalAmount),
                  SizedBox(height: 20),
                  // New Split Card with % Input
                  _buildSplitPercentageCard(members, totalAmount),
                ],
              ),
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
                Text('Group Details',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6200EA))),
              ],
            ),
            SizedBox(height: 20),
            Text('Total Expense: \$${totalAmount.toStringAsFixed(2)}'),
            Text('Number of Members: $memberCount'),
            Text('Budget: \$${budget.toStringAsFixed(2)}'),
            Text(
                'Remaining Budget: \$${(budget - totalAmount).toStringAsFixed(2)}'),
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

            return ListTile(
              leading: Icon(Icons.person, color: Colors.blue),
              title: Text('$name'),
              subtitle:
                  Text('Contribution: \$${contribution.toStringAsFixed(2)}'),
              trailing: Text(
                'Remaining: \$${(totalAmount - contribution).toStringAsFixed(2)}',
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
                Text('Split Expense',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    )),
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
          ],
        ),
      ),
    );
  }

  double _calculateSplit(double totalAmount, String uid) {
    final percentage = splitPercentages[uid] ?? (100 / splitControllers.length);
    return totalAmount * (percentage / 100);
  }
}
