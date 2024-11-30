import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BuyerInfoPage extends StatefulWidget {
  final int userId;

  const BuyerInfoPage({required this.userId, super.key});

  @override
  State<BuyerInfoPage> createState() => _BuyerInfoPageState();
}

class _BuyerInfoPageState extends State<BuyerInfoPage> {
  Map<String, dynamic>? buyerInfo;

  @override
  void initState() {
    super.initState();
    _fetchBuyerInfo();
  }

  Future<void> _fetchBuyerInfo() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/buyer?userId=${widget.userId}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          buyerInfo = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load buyer info');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: buyerInfo == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${buyerInfo!['name']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Payment Method: ${buyerInfo!['payment_method']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Delivery Address: ${buyerInfo!['delivery_address']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'User ID: ${buyerInfo!['userid']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
      ),
    );
  }
}
