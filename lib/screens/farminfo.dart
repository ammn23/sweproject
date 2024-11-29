import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FarmInfoPage extends StatefulWidget {
  final int farmId; // Pass the user ID to fetch farm data
  const FarmInfoPage({super.key, required this.farmId});

  @override
  State<FarmInfoPage> createState() => _FarmInfoPageState();
}

class _FarmInfoPageState extends State<FarmInfoPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _farmData;

  Future<void> _fetchFarmInfo() async {
    try {
      final response = await http.get(
        Uri.parse('https://your-api-url.com/get-farm-info?user_id=${widget.farmId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _farmData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch farm info.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching farm info: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFarmInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farm Information')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _farmData == null
              ? const Center(child: Text('No farm data available.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Farm Name: ${_farmData!['farm_name']}',//['name of column]
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Size: ${_farmData!['size']} acres',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Location: ${_farmData!['location']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Resources:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: (_farmData!['resources'] as List).length,
                          itemBuilder: (context, index) {
                            final resource = _farmData!['resources'][index];
                            return ListTile(
                              title: Text('${resource['type']}: ${resource['name']}'),
                              subtitle: Text('Quantity: ${resource['quantity']}'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
