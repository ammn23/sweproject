import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Reports and Analytics'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.bar_chart), text: 'Sales'),
              Tab(icon: Icon(Icons.inventory), text: 'Inventory'),
              Tab(icon: Icon(Icons.shopping_cart), text: 'Buyer'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSalesReports(context),
            _buildInventoryReports(context),
            _buildBuyerReports(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesReports(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Sales Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Generate sales report (mocked)
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Sales Report'),
                  content: Text('Sales data visualization goes here (charts, graphs).'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
                  ],
                ),
              );
            },
            child: Text('View Sales Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryReports(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Inventory Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Show inventory report
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Inventory Report'),
                  content: Text('Stock levels, restocking alerts, and turnover rates go here.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
                  ],
                ),
              );
            },
            child: Text('View Inventory Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerReports(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Buyer Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Show buyer report
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Buyer Report'),
                  content: Text('Purchasing habits and spending trends visualization.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
                  ],
                ),
              );
            },
            child: Text('View Buyer Report'),
          ),
        ],
      ),
    );
  }
}
