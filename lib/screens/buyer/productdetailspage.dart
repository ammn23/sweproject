import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductDetailsPage extends StatelessWidget {
  final int productId;

  const ProductDetailsPage({required this.productId, super.key});

  Future<Map<String, dynamic>> fetchProductDetails() async {
    // API call for product details
    final productResponse =
        await http.get(Uri.parse('http://10.0.2.2:8080/product/$productId'));
    if (productResponse.statusCode != 200) {
      throw Exception('Failed to load product details');
    }

    // API call for product images
    final imagesResponse = await http
        .get(Uri.parse('http://10.0.2.2:8080/product_images/$productId'));
    if (imagesResponse.statusCode != 200) {
      throw Exception('Failed to load product images');
    }

    final productData = jsonDecode(productResponse.body);
    final imagesData = List<String>.from(jsonDecode(imagesResponse.body));

    return {
      'product': productData,
      'images': imagesData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchProductDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final product = snapshot.data!['product'];
            final images = snapshot.data!['images'] as List<String>;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Image Carousel
                  if (images.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            images[index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Product Details
                  Text(
                    product['name'],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Price: \$${product['price']}'),
                  Text('Quantity: ${product['quantity']}'),
                  const SizedBox(height: 20),
                  Text(
                    product['description'] ?? 'No description available',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
