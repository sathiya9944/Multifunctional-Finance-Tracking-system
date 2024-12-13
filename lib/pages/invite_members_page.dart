import 'package:flutter/material.dart';

class InviteMembersPage extends StatefulWidget {
  final Map<String, dynamic> group;
  const InviteMembersPage({super.key, required this.group});

  @override
  _InviteMembersPageState createState() => _InviteMembersPageState();
}

class _InviteMembersPageState extends State<InviteMembersPage> {
  final TextEditingController _emailController = TextEditingController();

  void _inviteMember() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      setState(() {
        widget.group['members']
            .add(email); // Assuming email is unique identifier for members
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member invited: $email')),
      );
      _emailController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Members'),
        backgroundColor: const Color(0xFF6200EA),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Enter Email to Invite',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _inviteMember,
              child: const Text('Invite'),
            ),
            const SizedBox(height: 20),
            const Text('Invited Members:'),
            Expanded(
              child: ListView.builder(
                itemCount: widget.group['members'].length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(widget.group['members'][index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
