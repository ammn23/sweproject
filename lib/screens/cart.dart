import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final String _apiBaseUrl = "https://yourapi.com"; // Replace with your API URL
  List<Map<String, dynamic>> _cartItems = [];
  int _buyerID = 456; // This should be dynamically set to the logged-in user's ID

  bool _isLoading = true;

  // Fetch cart items from the database for the specific buyer
  Future<void> _fetchCartItems() async {
    try {
      final response = await http.get(Uri.parse("$_apiBaseUrl/cart/$_buyerID"));
      if (response.statusCode == 200) {
        setState(() {
          _cartItems = List<Map<String, dynamic>>.from(jsonDecode(response.body));
          _isLoading = false;
        });
      } else {
        _showError("Failed to load cart items.");
      }
    } catch (e) {
      _showError("Error fetching cart items.");
    }
  }

  // Update the quantity of a product in the cart
  Future<void> _updateCartQuantity(int productID, int quantity) async {
    if (quantity > 0) {
      try {
        final response = await http.put(
          Uri.parse("$_apiBaseUrl/cart/update"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "productID": productID,
            "buyerID": _buyerID,
            "quantity": quantity,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 'success') {
            _showSuccess("Cart updated successfully.");
            _fetchCartItems(); // Reload the cart items
          } else {
            _showError("Failed to update cart.");
          }
        } else {
          _showError("Failed to update cart.");
        }
      } catch (e) {
        _showError("Error updating cart.");
      }
    } else {
      _showError("Quantity must be greater than 0.");
    }
  }

  // Remove product from the cart
  Future<void> _removeFromCart(int productID) async {
    try {
      final response = await http.delete(
        Uri.parse("$_apiBaseUrl/cart/remove"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "productID": productID,
          "buyerID": _buyerID,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          _showSuccess("Product removed from cart.");
          _fetchCartItems(); // Reload the cart items
        } else {
          _showError("Failed to remove product from cart.");
        }
      } else {
        _showError("Failed to remove product from cart.");
      }
    } catch (e) {
      _showError("Error removing product from cart.");
    }
  }

  // Show success message
  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Show error message
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchCartItems(); // Load cart items when the page is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cartItems.isEmpty
                    ? const Center(child: Text("Your cart is empty"))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final cartItem = _cartItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: cartItem['image'] != null
                                  ? Image.network(
                                      cartItem['image'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.image, size: 50),
                              title: Text(cartItem['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Price: \$${cartItem['price']}"),
                                  Text("Quantity: ${cartItem['quantity']}"),
                                  Text("Total: \$${cartItem['price'] * cartItem['quantity']}"),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_shopping_cart),
                                onPressed: () {
                                  _removeFromCart(cartItem['productID']);
                                },
                              ),
                            ),
                          );
                        },
                      ),
            const SizedBox(height: 20),
            // Checkout Button (if you have a checkout page)
            ElevatedButton(
              onPressed: () {
                // Navigate to the checkout page (You can implement this)
              },
              child: const Text("Proceed to Checkout"),
            ),
          ],
        ),
      ),
    );
  }
}
