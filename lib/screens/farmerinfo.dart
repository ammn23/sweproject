import 'dart:io';  // Don't forget to import 'dart:io' for File.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class FarmerInfoPage extends StatefulWidget {
  final int userId; // Use user ID instead of email for identification
  const FarmerInfoPage({super.key, required this.userId});

  @override
  State<FarmerInfoPage> createState() => _FarmerInfoPageState();
}

class _FarmerInfoPageState extends State<FarmerInfoPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _name, _email, _phone, _farmName, _address, _profilePicUrl;
  XFile? _profileImage; // Change to XFile
  final ImagePicker _picker = ImagePicker();

  // Function to pick the image for the profile picture
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile;
      });
    }
  }

  // Function to update the farmer profile
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Prepare form data
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://your-api-url.com/update-profile'),
      );

      // Check if profile image is selected and add it to the request
      if (_profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          _profileImage!.path,
        ));
      }

      // Adding other form fields to the request
      request.fields['user_id'] = widget.userId.toString();
      request.fields['name'] = _name ?? '';
      request.fields['email'] = _email ?? '';
      request.fields['phone'] = _phone ?? '';
      request.fields['farm_name'] = _farmName ?? '';
      request.fields['address'] = _address ?? '';

      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully!')),
            );
          }
        } else {
          throw Exception('Failed to update profile');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error updating profile.')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileImage == null
                              ? NetworkImage(
                                  'https://your-default-image-url.com')
                              : FileImage(File(_profileImage!.path)) as ImageProvider, // Fixed here
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: _name,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            onChanged: (value) {
                              setState(() {
                                _name = value;
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            initialValue: _email,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            onChanged: (value) {
                              setState(() {
                                _email = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$").hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            initialValue: _phone,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            onChanged: (value) {
                              setState(() {
                                _phone = value;
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            initialValue: _farmName,
                            decoration: InputDecoration(
                              labelText: 'Farm Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            onChanged: (value) {
                              setState(() {
                                _farmName = value;
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            initialValue: _address,
                            decoration: InputDecoration(
                              labelText: 'Farm Address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            onChanged: (value) {
                              setState(() {
                                _address = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _updateProfile,
                            child: const Text('Save Changes'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              minimumSize: const Size(double.infinity, 50),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
