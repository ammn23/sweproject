import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart';

class PlCreatePage extends StatefulWidget {
  final int userId;
  final String name;

  const PlCreatePage({required this.userId, super.key, required this.name});

  @override
  State<PlCreatePage> createState() => _PlCreatePageState();
}

class _PlCreatePageState extends State<PlCreatePage> {
  final _formKey = GlobalKey<FormState>();

  String? productName;
  String? category;
  double? price;
  int? quantity;
  String? description;
  List<XFile> _newImages = [];
  bool _isLoading = false;
  String _errorMessage = '';
  List<dynamic> farms = [];
  int? selectedFarm;

  final List<String> categories = [
    'Vegetables',
    'Fruits',
    'Dairy',
    'Meat',
    'Condiments',
    'Bakery'
  ];

  final ImagePicker _picker = ImagePicker();
  drive.DriveApi? _driveApi;

  @override
  void initState() {
    super.initState();
    _fetchFarmData();
    _authenticateWithGoogleDrive();
  }

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
            _errorMessage = 'No farm data found!';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load farm data!';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching farm data: $e';
      });
    }
  }

  Future<void> _createNewProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final apiUrl = 'http://10.0.2.2:8080/create_new_product/${widget.userId}';
    final newData = {
      'name': productName,
      'category': category,
      'price': price,
      'quantity': quantity,
      'description': description,
      'images': await _uploadNewImages(),
      'farmid': selectedFarm
    };

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(content: Text('Product created successfully!')),
        );
        Navigator.pop(context as BuildContext);
      } else {
        setState(() {
          _errorMessage = 'Failed to create product!';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creating product: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _authenticateWithGoogleDrive() async {
    const _scopes = [drive.DriveApi.driveFileScope];
    final clientId = ClientId(
      '1039595924767-r8o4284umhf6gd29ejj13is3i12els68.apps.googleusercontent.com',
      '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',
    );

    try {
      final authClient = await clientViaUserConsent(clientId, _scopes, (url) {
        print('Please go to the following URL and grant access: $url');
      });
      _driveApi = drive.DriveApi(authClient);
    } catch (e) {
      print('Error authenticating with Google Drive: $e');
    }
  }

  Future<List<String>> _uploadNewImages() async {
    if (_driveApi == null) return [];

    List<String> uploadedUrls = [];
    for (XFile imageFile in _newImages) {
      final file = File(imageFile.path);
      final fileName = basename(file.path);

      var driveFile = drive.File()..name = fileName;

      try {
        final result = await _driveApi!.files.create(
          driveFile,
          uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
        );
        uploadedUrls.add('https://drive.google.com/uc?id=${result.id}');
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    return uploadedUrls;
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _newImages.add(pickedImage);
      });
    }
  }

  Future<void> _removeImage(int index) async {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Product')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Image picker and display images
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _newImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Image.file(
                                    File(_newImages[index].path),
                                    fit: BoxFit.cover,
                                    width: 150,
                                    height: 150,
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _removeImage(index),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text('Add Image'),
                        ),
                        const SizedBox(height: 20),
                        
                        // Product Name
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Product Name',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => productName = value,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        
                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: categories
                              .map((cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() {
                            category = value;
                          }),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Price
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => price = double.tryParse(value),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final parsedValue = double.tryParse(value);
                            if (parsedValue == null || parsedValue < 0) {
                              return 'Price must be a non-negative number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Quantity
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => quantity = int.tryParse(value),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final parsedValue = int.tryParse(value);
                            if (parsedValue == null || parsedValue < 0) {
                              return 'Quantity must be a non-negative number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Farm Dropdown
                        DropdownButtonFormField<int>(
                          value: selectedFarm,
                          decoration: const InputDecoration(
                            labelText: 'Select Farm',
                            border: OutlineInputBorder(),
                          ),
                          items: farms.map((farm) {
                            return DropdownMenuItem<int>(
                              value: farm['id'],
                              child: Text(farm['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedFarm = value;
                            });
                          },
                          validator: (value) => value == null
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Description
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => description = value,
                        ),
                        const SizedBox(height: 20),

                        // Save Button
                        ElevatedButton(
                          onPressed: _createNewProduct,
                          child: const Text('Save Details'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
