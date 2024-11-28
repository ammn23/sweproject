import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String identifier = '';
  String password = '';
  String role = 'Farmer'; // Default role
  String errorMessage = '';

  // REST API endpoint for authentication
  final String apiUrl = 'http://10.0.2.2:8080/login';

  Future<void> _authenticateUser() async {
    if (_formKey.currentState!.validate()) {
      final loginData = {
        'identifier': identifier,
        'password': password,
        'role': role,
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(loginData),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final userId = responseData['userId'];
          final isVerified = responseData['is_active'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', userId);

          if (role == 'Farmer' && !isVerified) {
            // If the user is a farmer and not verified
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'User not verified. Please wait for verification.')),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login Successful!')),
              );
              Navigator.pushNamed(
                context,
                role == 'Farmer' ? '/farmer_dashboard' : '/buyer_dashboard',
              );
            }
          }
        } else if (response.statusCode == 401) {
          setState(() {
            errorMessage = 'Incorrect email/username, password, or role.';
          });
        } else {
          setState(() {
            errorMessage = 'An error occurred. Please try again.';
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
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Email or Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email or username';
                  }
                  return null;
                },
                onChanged: (value) => setState(() => identifier = value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onChanged: (value) => setState(() => password = value),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                value: role,
                items: ['Farmer', 'Buyer']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => role = value ?? 'Farmer'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _authenticateUser,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
