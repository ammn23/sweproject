import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For REST API calls
import 'package:image_picker/image_picker.dart'; // For image picking
import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path/path.dart';

class PlEditPage extends StatefulWidget {
  final int productId;

  const PlEditPage({required this.productId, super.key});

  @override
  State<PlEditPage> createState() => _PlEditPageState();
}

class _PlEditPageState extends State<PlEditPage> {
  final _formKey = GlobalKey<FormState>();

  // Product details
  String? productName;
  String? category;
  double? price;
  int? quantity;
  String? description;
  List<String> imageUrls = [];
  List<XFile> _newImages = [];

  bool _isLoading = true;
  String _errorMessage = '';

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
    _fetchProductDetails();
    _authenticateWithGoogleDrive();
  }

  Future<void> _fetchProductDetails() async {
    final apiUrl = 'http://10.0.2.2:8080/get_product_info/${widget.productId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          productName = data['name'];
          category = data['category'];
          price = data['price']?.toDouble();
          quantity = data['quantity'];
          description = data['description'];
          imageUrls = List<String>.from(data['images'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load product details!';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching product details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;

    final apiUrl = 'http://10.0.2.2:8080/update_product_info/${widget.productId}';
    final updatedData = {
      'name': productName,
      'category': category,
      'price': price,
      'quantity': quantity,
      'description': description,
      'images': [...imageUrls, ...await _uploadNewImages()],
    };

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(content: Text('Failed to update product!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    }
  }

  Future<void> _authenticateWithGoogleDrive() async {
    const _scopes = [drive.DriveApi.driveFileScope];
    final clientId = ClientId(
      '1039595924767-r8o4284umhf6gd29ejj13is3i12els68.apps.googleusercontent.com.apps.googleusercontent.com',
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
    if (index < imageUrls.length) {
      final imageUrl = imageUrls[index];
      const apiUrl = 'http://10.0.2.2:8080/delete_product_image';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'imageUrl': imageUrl}),
        );

        if (response.statusCode == 200) {
          setState(() {
            imageUrls.removeAt(index);
          });
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            const SnackBar(content: Text('Image removed successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            const SnackBar(content: Text('Failed to remove image.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text('Error removing image: $e')),
        );
      }
    } else {
      setState(() {
        _newImages.removeAt(index - imageUrls.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            itemCount: imageUrls.length + _newImages.length,
                            itemBuilder: (context, index) {
                              if (index < imageUrls.length) {
                                return Stack(
                                  children: [
                                    Image.network(imageUrls[index],
                                        fit: BoxFit.cover),
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
                              } else {
                                final fileIndex = index - imageUrls.length;
                                return Stack(
                                  children: [
                                    Image.file(File(_newImages[fileIndex].path),
                                        fit: BoxFit.cover),
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
                              }
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text('Add Image'),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          initialValue: productName,
                          decoration: const InputDecoration(
                            labelText: 'Product Name',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => productName = value,
                          validator: (value) =>
                              value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: category,
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
                          onChanged: (value) => setState(() => category = value),
                          validator: (value) =>
                              value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          initialValue: price?.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => price = double.tryParse(value),
                          validator: (value) =>
                              value == null || double.tryParse(value) == null
                                  ? 'Enter a valid number'
                                  : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          initialValue: quantity?.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => quantity = int.tryParse(value),
                          validator: (value) =>
                              value == null || int.tryParse(value) == null
                                  ? 'Enter a valid number'
                                  : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          initialValue: description,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => description = value,
                          validator: (value) =>
                              value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saveDetails,
                          child: const Text('Save Details'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

