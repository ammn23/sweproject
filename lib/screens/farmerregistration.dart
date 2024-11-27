import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const FarmersMarketApp());
}

class FarmersMarketApp extends StatelessWidget {
  const FarmersMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer Registration',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const FarmerRegistrationPage(),
    );
  }
}

class FarmerRegistrationPage extends StatefulWidget {
  const FarmerRegistrationPage({super.key});

  @override
  State<FarmerRegistrationPage> createState() => _FarmerRegistrationPageState();
}

class _FarmerRegistrationPageState extends State<FarmerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  int phoneNumber = 0;              // need to change type
  String location = '';              // need to change name of var to location
  double farmSize = 0.0;
  String govid = '';             // change name to govid
  String errorMessage = '';
  String userName = '';

  // REST API endpoint for registration
  final String apiUrl = 'http://localhost:8080/register_farmer';

  Future<void> _registerFarmer() async {
    if (_formKey.currentState!.validate()) {
      // Prepare the registration data as a Map
      final registrationData = {
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'location': location,
        'farm_size': farmSize.toString(),
        'govid': govid,
        'username': userName,
      };
      try {
        // Send POST request to the backend
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(registrationData),
        );

        // Check the response from the backend
        if (response.statusCode == 200) {
          if(mounted){
          // Success: show confirmation message
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration Successful!')));
        } }else {
          // Error: show error message from API
          setState(() {
            errorMessage = 'Registration failed. Please try again.';
          });
        }
      } catch (e) {
        // Handle network or API error
        setState(() {
          errorMessage = 'An error occurred. Please check your connection and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onChanged: (value) => setState(() => name = value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onChanged: (value) => setState(() => email = value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
                onChanged: (value) => setState(() => phoneNumber = int.parse(value)),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Farm Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the farm address';
                  }
                  return null;
                },
                onChanged: (value) => setState(() => location = value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Farm Size (acres)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter farm size';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid farm size';
                  }
                  return null;
                },
                onChanged: (value) => setState(() => farmSize = double.parse(value)),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Government Issued ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your government ID';
                  }
                  return null;
                },
                onChanged: (value) => setState(() => govid = value),
              ),
              const SizedBox(height: 20),
              if (errorMessage.isNotEmpty) 
                Text(errorMessage, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _registerFarmer,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

