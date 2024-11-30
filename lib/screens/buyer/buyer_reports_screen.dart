import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuyerReportsScreen extends StatelessWidget {
  Future<Map<String, dynamic>> _fetchBuyerReport() async {
    try {
      final response = await http.get(
        Uri.parse('https://your-api-url.com/reports/buyer?buyerId=7'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load buyer report');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buyer Reports'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchBuyerReport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Top Product: ${data['topProduct']}'),
                  SizedBox(height: 20),
                  Text('Total Purchases: ${data['totalPurchases']}'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
