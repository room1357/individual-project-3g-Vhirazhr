import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data pesan
    final List<Map<String, String>> messages = [
      {
        "sender": "System",
        "content": "Welcome to the app! 🎉",
        "date": "08/01/2024",
      },
      {
        "sender": "System",
        "content": "Your profile has been updated.",
        "date": "19/09/2024",
      },
      {
        "sender": "Support",
        "content": "Don’t forget to check our new features.",
        "date": "18/09/2025",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.message, color: Colors.white),
              ),
              title: Text(message["sender"]!),
              subtitle: Text(message["content"]!),
              trailing: Text(
                message["date"]!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              onTap: () {
                _showMessageDetail(context, message);
              },
            ),
          );
        },
      ),
    );
  }

  // Detail pesan
  void _showMessageDetail(BuildContext context, Map<String, String> message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(message["sender"]!),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Date: ${message["date"]}"),
                const SizedBox(height: 8),
                Text("Message:"),
                const SizedBox(height: 4),
                Text(message["content"]!),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }
}
