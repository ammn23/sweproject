import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../chat_screen.dart';
import 'buyerdashboard.dart';
import 'buyerproductlisting.dart';
import 'cart.dart';


class BuyerChatsListScreen extends StatefulWidget {
  final int userId;
  final String name;

  const BuyerChatsListScreen({required this.userId, super.key, required this.name});


  @override
  State<BuyerChatsListScreen> createState() => _BuyerChatsListScreenState();
}

class _BuyerChatsListScreenState extends State<BuyerChatsListScreen> {
  final int userId = 12;  // Mock user ID

  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    try {
      final response = await http.get(

        Uri.parse('http://10.0.2.2:8080/chats?userId=${widget.userId}&role=buyer'),

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to respective pages based on selected index
    if (index == 0) {
      Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BuyerDashboard(userId: widget.userId, name: widget.name),
              ),
            );
    } else if (index == 1) {
      Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BuyerProductListingPage(userId: widget.userId, name: widget.name),
              ),
            );
    } else if (index == 2) {
      Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(userId: widget.userId, name: widget.name),
              ),
            );
    } else if (index == 3) {
      
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

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
