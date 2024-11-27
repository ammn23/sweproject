import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuyerInterface extends StatefulWidget {
  const BuyerInterface({super.key});

  @override
  State<BuyerInterface> createState() => _BuyerInterfaceState();
}

class _BuyerInterfaceState extends State<BuyerInterface> {
  final String _apiBaseUrl = "https://yourapi.com"; // Replace with your API URL
  List<Map<String, dynamic>> _productList = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String _selectedCategory = "All";
  List<String> _categories = ["All", "Fruits", "Vegetables", "Grains", "Dairy"];
  int _buyerID = 456; // This should be dynamically set to the logged-in user's ID

  // Fetch all products from the API
  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse("$_apiBaseUrl/products"));
      if (response.statusCode == 200) {
        setState(() {
          _productList = List<Map<String, dynamic>>.from(jsonDecode(response.body));
          _filteredProducts = _productList;
          _isLoading = false;
        });
      } else {
        _showError("Failed to load products.");
      }
    } catch (e) {
      _showError("Error fetching products.");
    }
  }

  // Filter products based on search and advanced filters
  void _filterProducts() {
    setState(() {
      _filteredProducts = _productList.where((product) {
        final matchesSearch = product['name'].toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCategory = _selectedCategory == "All" || product['category'] == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  // Add product to cart in the database
  Future<void> _addToCart(Map<String, dynamic> product, int quantity) async {
    if (quantity <= product['quantity']) {
      try {
        final response = await http.post(
          Uri.parse("$_apiBaseUrl/cart/add"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "productID": product['id'],
            "buyerID": _buyerID,
            "quantity": quantity,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 'success') {
            _showSuccess("Product added to cart successfully.");
          } else {
            _showError("Failed to add product to cart.");
          }
        } else {
          _showError("Failed to add product to cart.");
        }
      } catch (e) {
        _showError("Error adding product to cart.");
      }
    } else {
      _showError("Quantity exceeds available stock. Please adjust the quantity.");
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

  // Show error dialog
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
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Products"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: "Search",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            _searchQuery = value;
                            _filterProducts();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: _selectedCategory,
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                            _filterProducts();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // Product List Section
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? const Center(child: Text("No products match your search"))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: product['image'] != null
                                  ? Image.network(
                                      product['image'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.image, size: 50),
                              title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Category: ${product['category']}"),
                                  Text("Price: \$${product['price']}"),
                                  Text("Available Quantity: ${product['quantity']}"),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_shopping_cart),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Enter Quantity"),
                                        content: TextField(
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: "Quantity",
                                          ),
                                          onChanged: (value) {
                                            int quantity = int.tryParse(value) ?? 0;
                                            if (quantity > 0) {
                                              _addToCart(product, quantity);
                                              Navigator.pop(context);
                                            }
                                          },
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("Cancel"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
