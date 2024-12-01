import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'productdetailspage.dart';
import 'buyerdashboard.dart';
import 'cart.dart';
import 'chat.dart';

class BuyerProductListingPage extends StatefulWidget {
  final int userId;
  final String name;

  const BuyerProductListingPage({required this.userId, super.key, required this.name});

  @override
  State<BuyerProductListingPage> createState() =>
      _BuyerProductListingPageState();
}

class _BuyerProductListingPageState extends State<BuyerProductListingPage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  Map<int, int> selectedQuantities = {};
  bool isLoading = true;

  // Filters
  double minPrice = 0.0;
  double maxPrice = double.infinity;
  String? selectedCategory;
  String? selectedFarmLocation;

  List<String> categories = [
    'Meat',
    'Dairy',
    'Vegetables',
    'Fruits',
    'Condiments',
    'Bakery'
  ];
  List<String> farmLocations = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchFarmLocations();
  }

  Future<void> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8080/products_with_images'));
    if (response.statusCode == 200) {
      final data = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      setState(() {
        products = data;
        filteredProducts = products;
        selectedQuantities = {for (var product in products) product['id']: 1};
        isLoading = false;
      });
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  Future<void> fetchFarmLocations() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8080/farm_locations'));
    if (response.statusCode == 200) {
      setState(() {
        farmLocations = List<String>.from(jsonDecode(response.body));
      });
    } else {
      throw Exception('Failed to fetch farm locations');
    }
  }

  void applyFilters() {
    setState(() {
      filteredProducts = products.where((product) {
        final double price = product['price'];
        final String category = product['category'];
        final String farmLocation = product['farm_location'];

        final matchesPrice = price >= minPrice && price <= maxPrice;
        final matchesCategory =
            selectedCategory == null || category == selectedCategory;
        final matchesFarmLocation = selectedFarmLocation == null ||
            farmLocation == selectedFarmLocation;

        return matchesPrice && matchesCategory && matchesFarmLocation;
      }).toList();
    });
  }

  Future<void> _addToCart(int productId, int quantity, double price) async {
    try {
      final product = products.firstWhere((p) => p['id'] == productId);
      if (quantity > product['available']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Selected quantity exceeds available stock')),
        );
        return;
      }

      final includedInResponse = await http.post(
        Uri.parse('http://10.0.2.2:8080/add_to_included_in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.userId,
          'product_id': productId,
          'selected_quantity': quantity,
          'total_price': price,
        }),
      );

      if (includedInResponse.statusCode == 200) {
        final cartResponse = await http.post(
          Uri.parse('http://10.0.2.2:8080/update_cart'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'buyer_id': widget.userId}),
        );

        if (cartResponse.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Product added to cart successfully!')),
            );
          }
        } else {
          throw Exception('Failed to update cart');
        }
      } else {
        throw Exception('Failed to add product to included_in');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2 / 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                final price = product['price'] as double;
                final available = product['available'] as int;
                final quantity = selectedQuantities[product['id']] ?? 1;

                return Card(
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 3 / 2,
                        child: Image.network(
                          product['first_image_url'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsPage(
                                      productId: product['id'],
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                product['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text('Price: \$${price.toStringAsFixed(2)}'),
                            Text('Available: $available'),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DropdownButton<int>(
                                  value: quantity,
                                  items: List.generate(
                                    available,
                                    (i) => DropdownMenuItem(
                                      value: i + 1,
                                      child: Text('${i + 1}'),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedQuantities[product['id']] =
                                            value;
                                      });
                                    }
                                  },
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _addToCart(
                                      product['id'],
                                      quantity,
                                      price * quantity,
                                    );
                                  },
                                  child: const Text('Add to Cart'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: NavigationBar(
        indicatorColor: Colors.blue,
        selectedIndex: 1, // Highlight Products
        onDestinationSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BuyerDashboard(userId: widget.userId, name: widget.name),
              ),
            );
          } else if (index == 1) {
            // Stay on Products
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(userId: widget.userId, name: widget.name),
              ),
            );
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
