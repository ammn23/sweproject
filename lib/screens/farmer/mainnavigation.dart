import 'package:flutter/material.dart';
import 'farmershowpl.dart';
import 'farmercreatepl.dart';
import '../buyer/chat.dart';
import 'farmerdashboard.dart';
import 'farmer_chat_list.dart';

class MainNavigationPage extends StatefulWidget {
  final int userId;
  final String name;

  const MainNavigationPage({super.key, required this.userId, required this.name});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          FarmerDashboard(userId: widget.userId, name: widget.name),
          ProductListPage(userId: widget.userId, name: widget.name),
          PlCreatePage(userId: widget.userId, name: widget.name), // Replace with your create product page
          FarmerChatsListScreen(userId: widget.userId), // Replace with your chat page
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
    );
  }
}
