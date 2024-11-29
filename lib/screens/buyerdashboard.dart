import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'buyerproductlisting.dart'; 
import 'buyerinfo.dart'; 

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<BuyerDashboard> {
  int? userId;
  String? name;
  bool _isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getEmail();
  }

  // Retrieve the saved username from SharedPreferences
  Future<void> _getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedUserId = prefs.getInt('userId');
    String? storedName=prefs.getString('name');

    if (storedUserId != null) {
      setState(() {
        userId = storedUserId;
        name=storedName;
        _isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = 'No user is logged in!';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buyer Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome, $name!', style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => BuyerInfoPage(userId:userId!)),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.only(bottom: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Text(
                            'Farmer Info',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}