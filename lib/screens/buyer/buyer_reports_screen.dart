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

  Future<void> _fetchBuyerReport() async {
    final apiUrl = 'https://your-api-url.com/reports?userId=${widget.userId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _reportData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load report.';
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
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Top Product: ${_reportData['topProduct'] ?? 'N/A'}'),
                      const SizedBox(height: 20),
                      Text(
                          'Total Purchases: ${_reportData['totalPurchases'] ?? 'N/A'}'),
                    ],
                  ),
                ),
    );
  }
}
