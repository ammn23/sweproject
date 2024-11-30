import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Replace with actual chat message count
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    index % 2 == 0
                        ? 'User: Message $index'
                        : 'You: Reply $index', // Sample messages
                  ),
                );
              },
            ),
          ),
          // Input field and send button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Add send message functionality
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
