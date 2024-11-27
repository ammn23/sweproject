import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductListingPage extends StatefulWidget {
  const ProductListingPage({super.key});

  @override
  State<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  final String _apiBaseUrl = "https://yourapi.com"; // Replace with your API URL
  List<Map<String, dynamic>> _productList = [];
  final ImagePicker _picker = ImagePicker();

  // Fetch product listings from the API
  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse("$_apiBaseUrl/products"));
      if (response.statusCode == 200) {
        setState(() {
          _productList = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
        _showError("Failed to fetch products.");
      }
    } catch (e) {
      _showError("Error fetching products.");
    }
  }

  // Add or Edit Product
  Future<void> _saveProduct(
      {int? productId,
      required String name,
      required String category,
      required double price,
      required int quantity,
      required String description,
      File? image}) async {
    try {
      var request = http.MultipartRequest(
          productId == null ? "POST" : "PUT",
          Uri.parse(
              productId == null ? "$_apiBaseUrl/products" : "$_apiBaseUrl/products/$productId"));

      request.fields['name'] = name;
      request.fields['category'] = category;
      request.fields['price'] = price.toString();
      request.fields['quantity'] = quantity.toString();
      request.fields['description'] = description;

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath("image", image.path));
      }

      final response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchProducts(); // Refresh product list
      } else {
        _showError("Failed to save product.");
      }
    } catch (e) {
      _showError("Error saving product.");
    }
  }

  // Delete product
  Future<void> _deleteProduct(int productId) async {
    try {
      final response = await http.delete(Uri.parse("$_apiBaseUrl/products/$productId"));
      if (response.statusCode == 200) {
        _fetchProducts(); // Refresh product list
      } else {
        _showError("Failed to delete product.");
      }
    } catch (e) {
      _showError("Error deleting product.");
    }
  }

  // Error dialog
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

  // Add/Edit Product Dialog
  Future<void> _showProductDialog({Map<String, dynamic>? product}) async {
    final _formKey = GlobalKey<FormState>();
    String? name = product?['name'];
    String? category = product?['category'];
    double? price = product?['price'];
    int? quantity = product?['quantity'];
    String? description = product?['description'];
    File? productImage;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? "Add Product" : "Edit Product"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(labelText: "Product Name"),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Enter product name" : null,
                    onChanged: (value) => name = value,
                  ),
                  TextFormField(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: "Category"),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Enter category" : null,
                    onChanged: (value) => category = value,
                  ),
                  TextFormField(
                    initialValue: price?.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Price"),
                    validator: (value) =>
                        value == null || double.tryParse(value) == null
                            ? "Enter a valid price"
                            : null,
                    onChanged: (value) => price = double.tryParse(value),
                  ),
                  TextFormField(
                    initialValue: quantity?.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Quantity"),
                    validator: (value) =>
                        value == null || int.tryParse(value) == null
                            ? "Enter a valid quantity"
                            : null,
                    onChanged: (value) => quantity = int.tryParse(value),
                  ),
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: "Description"),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Enter description" : null,
                    onChanged: (value) => description = value,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final pickedFile = await _picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        productImage = File(pickedFile.path);
                        setState(() {});
                      }
                    },
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: productImage == null
                          ? const Center(child: Text("Upload Image"))
                          : Image.file(productImage!),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveProduct(
                    productId: product?['id'],
                    name: name!,
                    category: category!,
                    price: price!,
                    quantity: quantity!,
                    description: description!,
                    image: productImage,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text(product == null ? "Add" : "Update"),
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
      appBar: AppBar(title: const Text("Product Listings")),
      body: _productList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _productList.length,
              itemBuilder: (context, index) {
                final product = _productList[index];
                return ListTile(
                  leading: product['image'] != null
                      ? Image.network(product['image'], width: 50, height: 50)
                      : const Icon(Icons.image),
                  title: Text(product['name']),
                  subtitle: Text("Price: ${product['price']} | Qty: ${product['quantity']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showProductDialog(product: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteProduct(product['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
