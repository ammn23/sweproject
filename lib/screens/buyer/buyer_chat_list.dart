import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../chat_screen.dart';

class BuyerChatsListScreen extends StatefulWidget {
  final int userId;

  const BuyerChatsListScreen({required this.userId, Key? key}) : super(key: key);

  @override
  State<BuyerChatsListScreen> createState() => _BuyerChatsListScreenState();
}

class _BuyerChatsListScreenState extends State<BuyerChatsListScreen> {
  final int userId = 12;  // Mock user ID

  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    try {
      final response = await http.get(
        Uri.parse('https://your-api-url.com/chats?userId=${widget.userId}&role=buyer'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _chats = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load chats');
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buyer Chats'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            leading: Icon(Icons.chat_bubble),
            title: Text('Farmer: ${chat['farmerName']}'),
            subtitle: Text('Chat ID: ${chat['chatId']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatId: chat['chatId'],
                    userId: widget.userId,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
