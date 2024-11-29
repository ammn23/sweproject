import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For making REST API calls
import 'farminfo.dart';  
import 'farmerinfo.dart'; 

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  int? userId;
  String? name;
  String? farmName;
  int? farmId;
  bool _isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Initialize user info and fetch farm data
  Future<void> _initializeData() async {
    await _getUserInfo();
    if (userId != null) {
      await _fetchFarmData();
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Retrieve the saved user info from SharedPreferences
  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedUserId = prefs.getInt('userId');
    String? storedName = prefs.getString('name');

    if (storedUserId != null) {
      setState(() {
        userId = storedUserId;
        name = storedName;
      });
    } else {
      setState(() {
        errorMessage = 'No user is logged in!';
      });
    }
  }

  // Fetch the farm data (farmName and farmId) using a REST API
  Future<void> _fetchFarmData() async {
    const String apiUrl = 'http://10.0.2.2:8080/farmer_dashboard'; // Replace with your API endpoint

    try {
      final response = await http.get(Uri.parse('$apiUrl/$userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          farmName = data['farmName'] ?? 'Unknown Farm';
          farmId = data['farmId'];
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load farm data!';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching farm data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Dashboard')),
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

                      // Heading for Farmer Info
                      const Text(
                        'My Data',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FarmerInfoPage(userId: userId!)),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.only(bottom: 20.0),
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

                      // Heading for Farm Info
                      const Text(
                        'My Farm',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FarmInfoPage(farmId: farmId!)),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.only(bottom: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            farmName != null && farmId != null
                                ? 'Farm Info: $farmName (ID: $farmId)'
                                : 'Farm Info',
                            style: const TextStyle(color: Colors.white, fontSize: 18),
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
