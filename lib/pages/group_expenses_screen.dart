import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'group_details_page.dart';

class GroupFinanceTracker extends StatefulWidget {
  final String currentUserId;

  const GroupFinanceTracker({required this.currentUserId});

  @override
  _GroupFinanceTrackerState createState() => _GroupFinanceTrackerState();
}

class _GroupFinanceTrackerState extends State<GroupFinanceTracker> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _groupUidController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _getUserEmail() async {
    final userDoc =
        await _firestore.collection('users').doc(widget.currentUserId).get();
    return userDoc.data()?['email'] ?? '';
  }

  void _createGroup() {
    if (_groupNameController.text.isNotEmpty &&
        _budgetController.text.isNotEmpty) {
      final groupId = const Uuid().v4();
      final budget = double.tryParse(_budgetController.text);

      if (budget != null) {
        _firestore.collection('groups').doc(groupId).set({
          'id': groupId,
          'name': _groupNameController.text,
          'members': [
            {'uid': widget.currentUserId}
          ],
          'expenses': [],
          'budget': budget,
          'creator': widget.currentUserId,
          'invitedEmails': [], // Initialize invited emails as empty
        }).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Group "${_groupNameController.text}" created!'),
            ),
          );
          _groupNameController.clear();
          _budgetController.clear();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GroupDetailsPage(groupId: groupId),
            ),
          );
        });
      }
    }
  }

  void _addExistingGroup() async {
    if (_groupUidController.text.isNotEmpty) {
      final groupId = _groupUidController.text.trim();
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();

      if (groupDoc.exists) {
        final groupData = groupDoc.data() as Map<String, dynamic>;
        final invitedEmails = groupData['invitedEmails'] ?? [];
        final currentUserEmail = await _getUserEmail();

        if (invitedEmails.contains(currentUserEmail)) {
          if (!(groupData['members'] as List)
              .any((member) => member['uid'] == widget.currentUserId)) {
            await _firestore.collection('groups').doc(groupId).update({
              'members': FieldValue.arrayUnion([
                {'uid': widget.currentUserId}
              ]),
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Successfully joined the group!')),
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupDetailsPage(groupId: groupId),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You are already a member.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are not invited to this group.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid UID. No such group found.')),
        );
      }
    }
  }

  void _openGroupCreationOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select an Option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openExistingGroupDialog();
                },
                child: const Text('Add Existing Group'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openGroupCreationDialog();
                },
                child: const Text('Create New Group'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openExistingGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Group UID'),
          content: TextField(
            controller: _groupUidController,
            decoration: const InputDecoration(
              labelText: 'Group UID',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addExistingGroup();
              },
              child: const Text('Join Group'),
            ),
          ],
        );
      },
    );
  }

  void _openGroupCreationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _groupNameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: 'Group Budget',
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
              onPressed: () {
                Navigator.pop(context);
                _createGroup();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _sendInvite(String groupId) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invite Member'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Enter Email Address',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isNotEmpty) {
                  await _firestore.collection('groups').doc(groupId).update({
                    'invitedEmails': FieldValue.arrayUnion([email]),
                  });
                  Navigator.pop(context);

                  // Automatically open email client and pre-fill group UID
                  final Uri mailUri = Uri(
                    scheme: 'mailto',
                    path: email,
                    query:
                        'subject=Group%20Invitation&body=Your%20group%20UID%20is%20$groupId',
                  );
                  await launch(mailUri.toString());

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invitation sent to $email'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid email address.'),
                    ),
                  );
                }
              },
              child: const Text('Send Invite'),
            ),
          ],
        );
      },
    );
  }

  void _deleteGroup(String groupId) {
    _firestore.collection('groups').doc(groupId).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Group deleted successfully'),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete group: $error'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Finance Tracker',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6200EA),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('groups').where('members',
            arrayContains: {'uid': widget.currentUserId}).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No groups available.'));
          }

          final groups = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final groupId = group['id'];
                final groupName = group['name'];
                final groupOwner = group['creator'] as String;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            groupName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow
                                .ellipsis, // Ensures long names are truncated
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.group_add),
                              onPressed: () {
                                if (group['creator'] == widget.currentUserId) {
                                  _sendInvite(group['id']);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Only the group owner can invite members.')),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () {
                                if (group['creator'] == widget.currentUserId) {
                                  _deleteGroup(group['id']);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Only the group owner can delete this group.')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Members: ${(group['members'] as List).length}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GroupDetailsPage(groupId: group['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openGroupCreationOptionsDialog,
        backgroundColor: const Color(0xFF6200EA),
        child: const Icon(Icons.group_add),
      ),
    );
  }
}
