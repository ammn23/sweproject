import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String buyerName;
  final String farmerName;

  const ChatScreen({
    Key? key,
    required this.buyerName,
    required this.farmerName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage(String text) {
    setState(() {
      _messages.add({'sender': 'You', 'message': text});
    });
    _messageController.clear();
    // Simulate receiving a reply
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _messages.add({'sender': widget.farmerName, 'message': 'Got your message!'});
      });
    });
  }

  void _sendOffer(String offer) {
    setState(() {
      _messages.add({'sender': 'You', 'message': 'Offer: $offer'});
    });
    // Simulate a counteroffer
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _messages.add({'sender': widget.farmerName, 'message': 'Counter-offer: $offer + 10%'});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.farmerName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['sender'] == 'You';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${message['sender']}: ${message['message']}",
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.attach_money),
                  onPressed: () {
                    _sendOffer('100 USD'); // Example offer value
                  },
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(_messageController.text);
                    }
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
