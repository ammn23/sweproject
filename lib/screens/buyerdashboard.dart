import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'buyerinfo.dart';
import 'buyerproductlisting.dart';
import 'cart.dart';
import 'chat.dart';

class BuyerDashboard extends StatefulWidget {
  final int userId;
  final String name;

  const BuyerDashboard({required this.userId, required this.name, super.key});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  List<Map<String, dynamic>> orders = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/orders?userId=${widget.userId}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          orders = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to respective pages
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BuyerProductListingPage(
              userId: widget.userId, name: widget.name), // Replace with your product listing class
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CartPage(userId: widget.userId,name: widget.name), // Replace with your cart class
        ),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(), // Replace with your chat class
        ),
      );
    }
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return _dashboardPage();
      case 1:
        return const Center(child: Text('Product Listing Page'));
      case 2:
        return const Center(child: Text('Cart Page'));
      case 3:
        return const Center(child: Text('Chat Page'));
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  Widget _dashboardPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${widget.name}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'My Data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuyerInfoPage(userId: widget.userId),
                ),
              );
            },
            child: const Text('View My Info'),
          ),
          const SizedBox(height: 20),
          const Text(
            'My Orders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: orders.isEmpty
                ? const Center(child: Text('No orders found'))
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return ListTile(
                        title: Text('Order ID: ${order['orderid']}'),
                        subtitle: Text('Status: ${order['status']}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buyer Dashboard')),
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
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
