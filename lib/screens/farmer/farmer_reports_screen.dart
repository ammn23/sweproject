import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FarmerReportsScreen extends StatelessWidget {
  Future<Map<String, dynamic>> _fetchSalesReport() async {
    try {
      final response = await http.get(
        Uri.parse('https://your-api-url.com/reports/farmer/sales?farmerId=$farmerId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load sales report');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchInventoryReport() async {
    try {
      final response = await http.get(
        Uri.parse('https://your-api-url.com/reports/farmer/inventory?farmerId=FARMER_ID'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load inventory report');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Farmer Reports'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.bar_chart), text: 'Sales'),
              Tab(icon: Icon(Icons.inventory), text: 'Inventory'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSalesReports(context),
            _buildInventoryReports(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesReports(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchSalesReport(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final data = snapshot.data!;
          return Center(
            child: Text('Total Sales: ${data['totalSales']}'),
          );
        }
      },
    );
  }

  Widget _buildInventoryReports(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchInventoryReport(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final data = snapshot.data!;
          return Center(
            child: Text('Low Stock Alerts: ${data['lowStockCount']} items'),
          );
        }
      },
    );
  }
}
