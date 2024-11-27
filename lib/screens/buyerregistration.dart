import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuyerRegistrationPage extends StatefulWidget {
  const BuyerRegistrationPage({super.key});

  @override
  State<BuyerRegistrationPage> createState() => _BuyerRegistrationPageState();
}

class _BuyerRegistrationPageState extends State<BuyerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String phoneNumber = '';
  String deliveryAddress = '';
  String paymentMethod = '';
  String errorMessage = '';
  String userName = '';
  String password = '';

  // REST API endpoint for buyer registration
  final String apiUrl = 'https://your-api-url.com/register_buyer';

  Future<void> _registerBuyer() async {
    if (_formKey.currentState!.validate()) {
      final registrationData = {
        'name': name,
        'email': email,
        'username': userName,
        'password': password,
        'phone_number': phoneNumber,
        'delivery_address': deliveryAddress,
        'payment_method': paymentMethod,
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(registrationData),
        );

        if (response.statusCode == 200) {
          if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Successful!')),
          );
          }
        } else {
          setState(() {
            errorMessage = 'Registration failed. Please try again.';
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'An error occurred. Please check your connection.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buyer Registration')),
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
                onChanged: (value) => setState(() => phoneNumber = value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onChanged: (value) => setState(() => userName = value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onChanged: (value) => setState(() => password = value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Delivery Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your delivery address';
                  }
                  return null;
                },
                onChanged: (value) => setState(() => deliveryAddress = value),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Preferred Payment Method'),
                items: ['Credit Card', 'Cash', 'PayPal','Bank Transfer',]
                    .map((method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => paymentMethod = value ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a payment method';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _registerBuyer,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

