import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FarmerReportsScreen extends StatefulWidget {
  final int userId;

  const FarmerReportsScreen({required this.userId, super.key});

  @override
  State<FarmerReportsScreen> createState() => _FarmerReportsScreenState();
}

class _FarmerReportsScreenState extends State<FarmerReportsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic> _salesReportData = {};
  Map<String, dynamic> _inventoryReportData = {};

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    final salesApiUrl = 'https://your-api-url.com/reports/farmer/sales?userId=${widget.userId}';
    final inventoryApiUrl = 'https://your-api-url.com/reports/farmer/inventory?userId=${widget.userId}';

    try {
      final salesResponse = await http.get(Uri.parse(salesApiUrl));
      final inventoryResponse = await http.get(Uri.parse(inventoryApiUrl));

      if (salesResponse.statusCode == 200 && inventoryResponse.statusCode == 200) {
        setState(() {
          _salesReportData = json.decode(salesResponse.body);
          _inventoryReportData = json.decode(inventoryResponse.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load reports.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching reports: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Reports'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text('Total Sales: ${_salesReportData['totalSales'] ?? 'N/A'}'),
                      const SizedBox(height: 20),
                      Text('Low Stock Alerts: ${_inventoryReportData['lowStockCount'] ?? 'N/A'} items'),
                    ],
                  ),
                ),
    );
  }
}
