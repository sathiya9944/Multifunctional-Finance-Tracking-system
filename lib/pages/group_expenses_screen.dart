import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // For generating unique group IDs
import 'package:url_launcher/url_launcher.dart'; // For opening email with link
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'group_details_page.dart';

class GroupFinanceTracker extends StatefulWidget {
  @override
  _GroupFinanceTrackerState createState() => _GroupFinanceTrackerState();
}

class _GroupFinanceTrackerState extends State<GroupFinanceTracker> {
  final TextEditingController _groupNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to create a new group with budget
  void _createGroup() {
    if (_groupNameController.text.isNotEmpty) {
      final groupId = const Uuid().v4(); // Generate unique group ID
      final budgetController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Set Group Budget'),
            content: TextField(
              controller: budgetController,
              decoration: const InputDecoration(
                labelText: 'Budget',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final budget = double.tryParse(budgetController.text);
                  if (budget != null) {
                    // Create the new group in Firestore
                    _firestore.collection('groups').doc(groupId).set({
                      'id': groupId,
                      'name': _groupNameController.text,
                      'members': [], // Initial empty members list
                      'expenses': [], // Initial empty expenses list
                      'budget': budget, // Set the initial budget
                      'link':
                          'https://example.com/join/$groupId', // Example group link
                    }).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Group "${_groupNameController.text}" created!')),
                      );
                      _groupNameController.clear();
                      Navigator.pop(context);
                    });
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      );
    }
  }

  // Function to send email invite
  void _sendInvite(String groupLink) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: '',
      queryParameters: {
        'subject': 'You\'ve been invited to a group!',
        'body': 'Click the following link to join the group: $groupLink',
      },
    );

    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      throw 'Could not send email';
    }
  }

  // Fetch all groups from Firestore
  Future<List<Map<String, dynamic>>> _fetchGroups() async {
    QuerySnapshot snapshot = await _firestore.collection('groups').get();
    return snapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  }

  // Navigate to group details
  void _openGroupDetails(Map<String, dynamic> group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailsPage(
            groupId: group['id']), // Pass groupId to GroupDetailsPage
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Finance Tracker'),
        backgroundColor: const Color(0xFF6200EA),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchGroups(), // Fetch groups from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No groups available.'));
          }

          final groups = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final groupName =
                    group['name'] ?? 'No Name'; // Handle null group name
                final membersCount =
                    group['members']?.length ?? 0; // Handle null members
                final groupLink = group['link'] ?? ''; // Handle null link

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    title: Text(groupName),
                    subtitle: Text('Members: $membersCount'),
                    trailing: IconButton(
                      icon: const Icon(Icons.group_add),
                      onPressed: () {
                        if (groupLink.isNotEmpty) {
                          _sendInvite(
                              groupLink); // Send invite when button pressed
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Group link is missing')),
                          );
                        }
                      },
                    ),
                    onTap: () => _openGroupDetails(
                        group), // Navigate to group details page
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openGroupCreationDialog,
        backgroundColor: const Color(0xFF6200EA),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Open the group creation dialog
  void _openGroupCreationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Group'),
          content: TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(
              labelText: 'Group Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _createGroup,
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
