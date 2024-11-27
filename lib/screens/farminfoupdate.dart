import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FarmDetailsPage extends StatefulWidget {
  final int userId; // Use user ID to link with the database.
  const FarmDetailsPage({super.key, required this.userId});

  @override
  State<FarmDetailsPage> createState() => _FarmDetailsPageState();
}

class _FarmDetailsPageState extends State<FarmDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form fields
  String? _farmSize, _location;
  List<Map<String, dynamic>> _resources = [
    {"name": "", "type": "Crops", "quantity": 0}
  ];

  // Dropdown options for resource types
  final List<String> _resourceTypes = [
    "Crops",
    "Pesticides",
    "Seeds",
    "Equipment"
  ];
/*
  // API Function to Save Farm Details
  Future<void> _saveFarmDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final apiUrl = 'https://your-api-url.com/save-farm-details'; // Replace with your API endpoint
      final payload = {
        "user_id": widget.userId,
        "farm_size": _farmSize,
        "location": _location,
        "resources": _resources,
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Farm details saved successfully!")),
            );
          }
        } else {
          throw Exception("Failed to save farm details.");
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error saving farm details.")),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
*/
  // UI Builder
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Farm Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Farm Size (in acres)",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _farmSize = value;
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? "Enter farm size"
                            : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Farm Location",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _location = value;
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? "Enter location"
                            : null,
                      ),
                      const SizedBox(height: 15),
                      const Text("Resources:"),
                      ..._resources.asMap().entries.map((entry) {
                        final index = entry.key;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    initialValue: entry.value["name"],
                                    decoration: InputDecoration(
                                      labelText: "Resource #${index + 1}",
                                    ),
                                    onChanged: (value) =>
                                        _resources[index]["name"] = value,
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? "Enter resource name"
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: DropdownButtonFormField<String>(
                                    value: entry.value["type"],
                                    items: _resourceTypes.map((type) {
                                      return DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      _resources[index]["type"] = value!;
                                      setState(() {});
                                    },
                                    decoration: const InputDecoration(
                                        labelText: "Type"),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      _resources.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue:
                                        entry.value["quantity"]?.toString(),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        labelText: "Quantity"),
                                    onChanged: (value) => _resources[index]
                                        ["quantity"] = int.tryParse(value) ?? 0,
                                    validator: (value) => value == null ||
                                            int.tryParse(value) == null
                                        ? "Enter valid quantity"
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                                thickness:
                                    1), // Optional: To visually separate each resource
                          ],
                        );
                      }),
                      ElevatedButton(
                        onPressed: () {
                          _resources.add(
                              {"name": "", "type": "Crops", "quantity": 0});
                          setState(() {});
                        },
                        child: const Text("Add Resource"),
                      ),
                      const SizedBox(height: 20),
                      /*   ElevatedButton(
                        onPressed: _saveFarmDetails,
                        child: const Text("Save Farm Details"),
                      ),*/
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
