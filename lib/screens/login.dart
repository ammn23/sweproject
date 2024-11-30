import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'buyerdashboard.dart';

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
          final name = responseData['name'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', userId);
          await prefs.setString('name', name);

          // Get FCM token after login
          FirebaseMessaging messaging = FirebaseMessaging.instance;
          messaging.getToken().then((token) {
            print("FCM Token: $token");
            sendFCMTokenToServer(userId, token);
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login Successful!')),
            );

            if (role == 'Farmer') {
              Navigator.pushNamed(context, '/farmer_dashboard');
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuyerDashboard(userId: userId, name: name),
                ),
              );
            }
          }
        } else {
          // Handle different errors (similar to your current code)
        }
      } catch (e) {
        setState(() {
          errorMessage = 'An error occurred. Please check your connection.';
        });
      }
    }
  }

  Future<void> sendFCMTokenToServer(int userId, String? token) async {
    final response = await http.post(
      Uri.parse('https://your-backend.com/save-token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId, 'token': token}),
    );

    if (response.statusCode == 200) {
      print('Token sent to server successfully');
    } else {
      print('Failed to send token to server');
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
                decoration: const InputDecoration(labelText: 'Email or Username'),
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
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
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


