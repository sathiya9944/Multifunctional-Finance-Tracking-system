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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
          'link': 'https://example.com/join/$groupId',
          'creator': widget.currentUserId,
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

  Stream<List<Map<String, dynamic>>> _fetchGroups() {
    return _firestore
        .collection('groups')
        .where('members', arrayContains: {'uid': widget.currentUserId})
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return doc.data() as Map<String, dynamic>;
          }).toList();
        });
  }

  void _sendInvite(String groupLink) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: '',
      queryParameters: {
        'subject': 'You\'ve been invited to a group!',
        'body': 'Click the following link to join the group: $groupLink',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send email')),
      );
    }
  }

  void _openGroupDetails(Map<String, dynamic> group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailsPage(groupId: group['id']),
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchGroups(),
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
                final groupName = group['name'] ?? 'No Name';
                final membersCount = group['members']?.length ?? 0;
                final groupLink = group['link'] ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    title: Text(groupName),
                    subtitle: Text('Members: $membersCount'),
                    trailing: IconButton(
                      icon: const Icon(Icons.group_add),
                      onPressed: () {
                        if (groupLink.isNotEmpty) {
                          _sendInvite(groupLink);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Group link is missing')),
                          );
                        }
                      },
                    ),
                    onTap: () => _openGroupDetails(group),
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
              SizedBox(height: 10),
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
              onPressed: _createGroup,
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
