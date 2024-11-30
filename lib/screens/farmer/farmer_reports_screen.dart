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
    _fetchSalesReport();
    _fetchInventoryReport();
  }

  // Fetch Sales Report
  Future<void> _fetchSalesReport() async {
    final apiUrl = 'https://your-api-url.com/reports/farmer/sales?userId=${widget.userId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _salesReportData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load sales report.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching sales report: $e';
        _isLoading = false;
      });
    }
  }

  // Fetch Inventory Report
  Future<void> _fetchInventoryReport() async {
    final apiUrl = 'https://your-api-url.com/reports/farmer/inventory?userId=${widget.userId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _inventoryReportData = json.decode(response.body);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load inventory report.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching inventory report: $e';
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
              : Column(
                  children: [
                    _buildSalesReportSection(),
                    _buildInventoryReportSection(),
                  ],
                ),
    );
  }

  // Sales Report Section
  Widget _buildSalesReportSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sales Report', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Total Sales: ${_salesReportData['totalSales'] ?? 'N/A'}'),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Trigger download report functionality
              _downloadReport('sales');
            },
            child: const Text('Download Sales Report'),
          ),
        ],
      ),
    );
  }

  // Inventory Report Section
  Widget _buildInventoryReportSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Inventory Report', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Low Stock Alerts: ${_inventoryReportData['lowStockCount'] ?? 'N/A'} items'),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Trigger download report functionality
              _downloadReport('inventory');
            },
            child: const Text('Download Inventory Report'),
          ),
        ],
      ),
    );
  }

  // Function to simulate report download
  void _downloadReport(String reportType) {
    // Placeholder for download logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading $reportType report...')),
    );
  }
}
