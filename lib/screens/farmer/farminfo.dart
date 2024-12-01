import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FarmInfoPage extends StatefulWidget {
  final int farmId; // Pass the farm ID to fetch farm data
  const FarmInfoPage({super.key, required this.farmId});

  @override
  State<FarmInfoPage> createState() => _FarmInfoPageState();
}

class _FarmInfoPageState extends State<FarmInfoPage> {
  bool _isLoading = true;
  bool _isEditing = false;
  Map<String, dynamic>? _farmData;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _farmNameController;
  late TextEditingController _sizeController;
  late TextEditingController _locationController;

  Future<void> _fetchFarmInfo() async {
    String apiUrl = 'http://10.0.2.2:8080/get_farm_info/${widget.farmId}';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          _farmData = jsonDecode(response.body);
          _isLoading = false;

          // Initialize controllers with fetched data
          _farmNameController =
              TextEditingController(text: _farmData!['farm_name']);
          _sizeController =
              TextEditingController(text: _farmData!['size'].toString());
          _locationController =
              TextEditingController(text: _farmData!['location']);
        });
      } else {
        throw Exception('Failed to fetch farm info.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching farm info: $e')),
        );
      }
    }
  }

  Future<void> _updateFarmInfo() async {
    String apiUrl = 'http://10.0.2.2:8080/update_farm_info/${widget.farmId}';
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'farm_name': _farmNameController.text,
          'size': double.tryParse(_sizeController.text),
          'location': _locationController.text,
          'resources': _farmData!['resources'],
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isEditing = false;
          _farmData = jsonDecode(response.body);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Farm info updated successfully!')),
        );
      } else {
        throw Exception('Failed to update farm info.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating farm info: $e')),
      );
    }
  }

  void _editResource(int index) {
    final resource = _farmData!['resources'][index];
    final TextEditingController typeController =
        TextEditingController(text: resource['type']);
    final TextEditingController nameController =
        TextEditingController(text: resource['name']);
    final TextEditingController quantityController =
        TextEditingController(text: resource['quantity'].toString());


    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Resource'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final int? quantity = int.tryParse(quantityController.text);

                if (quantity == null || quantity < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quantity must be 0 or more')),
                  );
                  return;
                }


                setState(() {
                  resource['type'] = typeController.text;
                  resource['name'] = nameController.text;
                  resource['quantity'] = quantity;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchFarmInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Information'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _farmData == null
              ? const Center(child: Text('No farm data available.'))
              : _isEditing
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _farmNameController,
                              decoration: const InputDecoration(
                                labelText: 'Farm Name',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the farm name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _sizeController,
                              decoration: const InputDecoration(
                                labelText: 'Size (acres)',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the size';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Location',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the location';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Resources:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount:
                                    (_farmData!['resources'] as List).length,
                                itemBuilder: (context, index) {
                                  final resource =
                                      _farmData!['resources'][index];
                                  return ListTile(
                                    title: Text(
                                        '${resource['type']}: ${resource['name']}'),
                                    subtitle: Text(
                                        'Quantity: ${resource['quantity']}'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editResource(index),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _updateFarmInfo();
                                    }
                                  },
                                  child: const Text('Save'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = false;
                                    });
                                  },
                                  child: const Text('Cancel'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Farm Name: ${_farmData!['farm_name']}',
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
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount:
                                  (_farmData!['resources'] as List).length,
                              itemBuilder: (context, index) {
                                final resource =
                                    _farmData!['resources'][index];
                                return ListTile(
                                  title: Text(
                                       '${resource['type']}: ${resource['name']}'),
                                  subtitle: Text(
                                      'Quantity: ${resource['quantity']} '),
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
