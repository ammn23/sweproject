import 'package:farmersmarketflutter/screens/farmer/farmershowpl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For making REST API calls
import 'dart:convert'; // For JSON decoding
import 'farminfo.dart';
import 'farmerinfo.dart';
import 'farmereditpl.dart';
import 'farmer_reports_screen.dart';

class FarmerDashboard extends StatefulWidget {
  final int userId;
  final String name;

  const FarmerDashboard({super.key, required this.userId, required this.name});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  late int userId; // Use late to initialize in initState
  late String name; // Use late to initialize in initState
  List<dynamic> farms = []; // List to hold multiple farms
  bool _isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    userId = widget.userId; // Use the passed userId
    name = widget.name; // Use the passed name
    _fetchFarmData(); // Fetch farm data immediately using passed parameters
  }

  // Fetch the farm data (farmName and farmId) using a REST API
  Future<void> _fetchFarmData() async {
    const String apiUrl =
        'http://10.0.2.2:8080/farmer_dashboard'; // Replace with your API endpoint

    try {
      final response = await http.get(Uri.parse('$apiUrl/${widget.userId}'));
      if (response.statusCode == 200) {
        final List<dynamic> data =
            jsonDecode(response.body); // Decode as a List

        if (data.isNotEmpty) {
          setState(() {
            farms = data; // Store the list of farms
            _isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'No farm data found!';
          });
        }
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
                      Text('Welcome, $name!',
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 20),

                      // Heading for Farmer Info
                      const Text(
                        'My Data',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    FarmerInfoPage(userId: userId)),
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
                        'My Farms',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),

                      // Display list of farms dynamically
                      Expanded(
                        child: ListView.builder(
                          itemCount: farms.length, // Number of farms
                          itemBuilder: (context, index) {
                            var farmData =
                                farms[index]; // Get farm data at index
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FarmInfoPage(
                                        farmId: farmData['farmid']),
                                  ),
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
                                  'Farm Info: ${farmData['name']}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FarmerReportsScreen(userId: widget.userId)),
                          );
                        },
                        child: Text('Go to Second Page'),
                      ),
                    ],
                  )
                : Center(
                    child: Text(errorMessage,
                        style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
