import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For REST API calls
import 'package:image_picker/image_picker.dart'; // For image picking
import 'dart:io';

class FarmerInfoPage extends StatefulWidget {
  final int userId;
  const FarmerInfoPage({required this.userId, super.key});

  @override
  State<FarmerInfoPage> createState() => _FarmerInfoPageState();
}

class _FarmerInfoPageState extends State<FarmerInfoPage> {
  final _formKey = GlobalKey<FormState>();

  // Farmer details
  String? name;
  String? email;
  String? phoneNumber;
  String? profilePictureUrl;


  bool _isLoading = true;
  String _errorMessage = '';

  // Image Picker
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  // Fetch farmer and farm details from the backend
  Future<void> _fetchDetails() async {
    const String apiUrl = 'http://10.0.2.2:8080/get_farmerinfo';

    try {
      final response = await http.get(Uri.parse('$apiUrl/${widget.userId}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          name = data['name'];
          email = data['email'];
          phoneNumber = data['phoneNumber'];
          profilePictureUrl = data['profilePicture'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load details!';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching details: $e';
        _isLoading = false;
      });
    }
  }

  // Save updated details to the backend
  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;

    const String apiUrl = 'http://10.0.2.2:8080/update_farmerinfo';
    final updatedData = {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': _selectedImage != null
          ? base64Encode(await _selectedImage!.readAsBytes())
          : profilePictureUrl,
    };

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Details updated successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update details!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating details: $e')),
        );
      }
    }
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer and Farm Details')),
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
                        // Profile picture
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: _selectedImage != null
                                  ? FileImage(
                                      File(_selectedImage!.path),
                                    )
                                  : (profilePictureUrl != null
                                      ? NetworkImage(profilePictureUrl!)
                                      : null) as ImageProvider?,
                              child: _selectedImage == null &&
                                      profilePictureUrl == null
                                  ? const Icon(Icons.camera_alt, size: 50)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Name
                        TextFormField(
                          initialValue: name,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => name = value,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Email
                        TextFormField(
                          initialValue: email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => email = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                                    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Phone number
                        TextFormField(
                          initialValue: phoneNumber,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => phoneNumber = value,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Save button
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
