import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'order.dart';
import 'buyerdashboard.dart';
import 'chat.dart';
import 'buyerproductlisting.dart';

class CartPage extends StatefulWidget {
  final int userId;
  final String name;

  const CartPage({required this.userId, required this.name, super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  double totalCost = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartDetails();
  }

  Future<void> fetchCartDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/cart_items?buyer_id=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(jsonDecode(response.body));

        double total = data.fold(
          0.0,
          (sum, item) => sum + item['total_price'],
        );

        setState(() {
          cartItems = data;
          totalCost = total;
          isLoading = false;
        });

        await http.post(
          Uri.parse('http://10.0.2.2:8080/update_cart_total'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'buyer_id': widget.userId,
            'total_cost': total,
          }),
        );
      } else {
        throw Exception('Failed to fetch cart details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> deleteCartItem(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          'http://10.0.2.2:8080/delete_cart_item?user_id=${widget.userId}&product_id=$productId',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          cartItems.removeWhere((item) => item['product_id'] == productId);
          totalCost = cartItems.fold(
            0.0,
            (sum, item) => sum + item['total_price'],
          );
        });

        await http.post(
          Uri.parse('http://10.0.2.2:8080/update_cart_total'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': widget.userId,
            'total_cost': totalCost,
          }),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product removed from cart')),
          );
        }
      } else {
        throw Exception('Failed to delete item from cart');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void navigateToCreateOrderPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrderPage(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        leading: const Icon(Icons.shopping_cart),
                        title: Text(item['product_name']),
                        subtitle:
                            Text('Quantity: ${item['selected_quantity']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${item['total_price'].toStringAsFixed(2)}',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteCartItem(item['product_id']);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Total Price: \$${totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: navigateToCreateOrderPage,
                        child: const Text('Create Order'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2, // Highlight Cart
        indicatorColor: Colors.blue,
        onDestinationSelected: (index) {
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
            // Stay on Cart
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(),
              ),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}


