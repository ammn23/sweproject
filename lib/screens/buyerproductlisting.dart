import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http;

class BuyerProductListingPage extends StatefulWidget {
  final int userId;

  const BuyerProductListingPage({required this.userId, super.key});

  @override
  State<BuyerProductListingPage> createState() =>
      _BuyerProductListingPageState();
}

class _BuyerProductListingPageState extends State<BuyerProductListingPage> {
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 1000);
  String? _selectedCategory;
  String? _farmLocation;

  final List<String> categories = [
    'Vegetables',
    'Fruits',
    'Dairy',
    'Meat',
    'Condiments',
    'Bakery'
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final apiUrl = 'http://10.0.2.2:8080/get_all_products';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _products = data;
          _filteredProducts = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Failed to fetch products');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching products: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch = _searchQuery.isEmpty ||
            product['name'].toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCategory = _selectedCategory == null ||
            product['category'] == _selectedCategory;
        final matchesPrice = product['price'] >= _priceRange.start &&
            product['price'] <= _priceRange.end;
        final matchesLocation =
            _farmLocation == null || product['farm_location'] == _farmLocation;

        return matchesSearch &&
            matchesCategory &&
            matchesPrice &&
            matchesLocation;
      }).toList();
    });
  }

  Future<void> _addToCart(
      int productId, int quantity, int availableQuantity) async {
    if (quantity > availableQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Error: Selected quantity exceeds available stock (${availableQuantity}).'),
        ),
      );
      return;
    }

    final apiUrl = 'http://10.0.2.2:8080/add_to_cart';
    final cartData = {
      'userId': widget.userId,
      'productId': productId,
      'quantity': quantity,
    };
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(cartData),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added to cart!')),
        );
      } else {
        print('Failed to add product to cart');
      }
    } catch (e) {
      print('Error adding product to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Listing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(
                  categories: categories,
                  onSearch: (query) {
                    setState(() {
                      _searchQuery = query;
                      _applyFilters();
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Widgets
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      DropdownButton<String>(
                        hint: const Text('Category'),
                        value: _selectedCategory,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                            _applyFilters();
                          });
                        },
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        hint: const Text('Farm Location'),
                        value: _farmLocation,
                        onChanged: (value) {
                          setState(() {
                            _farmLocation = value;
                            _applyFilters();
                          });
                        },
                        items: _products
                            .map(
                                (product) => product['farm_location'] as String)
                            .toSet()
                            .map((location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 10),
                      Text(
                          'Price Range: ${_priceRange.start.round()} - ${_priceRange.end.round()}'),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 1000,
                        onChanged: (values) {
                          setState(() {
                            _priceRange = values;
                            _applyFilters();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Image.network(
                                product['images'][0],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('Price: \$${product['price']}'),
                                  Text('Available: ${product['quantity']}'),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon:
                                            const Icon(Icons.add_shopping_cart),
                                        onPressed: () {
                                          _addToCart(product['id'], 1,
                                              product['quantity']);
                                        },
                                      ),
                                      DropdownButton<int>(
                                        hint: const Text('Qty'),
                                        onChanged: (value) {
                                          if (value != null) {
                                            _addToCart(product['id'], value,
                                                product['quantity']);
                                          }
                                        },
                                        items: List.generate(
                                            product['quantity'], (index) {
                                          return DropdownMenuItem(
                                            value: index + 1,
                                            child: Text('${index + 1}'),
                                          );
                                        }),
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
                ),
              ],
            ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate {
  final List<String> categories;
  final Function(String) onSearch;

  ProductSearchDelegate({required this.categories, required this.onSearch});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    close(context, null);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = categories.where((category) {
      return category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            onSearch(query);
            close(context, null);
          },
        );
      },
    );
  }
}
