import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuyerReportsScreen extends StatefulWidget {
  final int userId;

  const BuyerReportsScreen({required this.userId, super.key});

  @override
  State<BuyerReportsScreen> createState() => _BuyerReportsScreenState();
}

class _BuyerReportsScreenState extends State<BuyerReportsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic> _reportData = {};

  @override
  void initState() {
    super.initState();
    _fetchBuyerReport();
  }

  // Fetch Buyer Report
  Future<void> _fetchBuyerReport() async {
    final apiUrl = 'https://your-api-url.com/reports/buyer?userId=${widget.userId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _reportData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load buyer report.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching report: $e';
        _isLoading = false;
      });
    }
  }

  // Function to simulate report download
  void _downloadReport() {
    // Placeholder for download logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading Buyer Report...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Reports'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Buyer Purchase Trends', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('Total Purchases: ${_reportData['totalPurchases'] ?? 'N/A'}'),
                      const SizedBox(height: 20),
                      Text('Total Spent: \$${_reportData['totalSpent'] ?? 'N/A'}'),
                      const SizedBox(height: 20),
                      Text('Preferred Products:'),
                      for (var product in _reportData['preferredProducts'] ?? [])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text('- ${product['productName']}'),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _downloadReport,
                        child: const Text('Download Report'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
