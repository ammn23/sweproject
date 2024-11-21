import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<bool> registerBuyer({
    required int userid,
    required String email,
    required String name,
    required String phoneNumber,
    required String password,
    required String username,
    required String paymentMethod,
    required String deliveryAddress,
  }) async {
    final url = Uri.parse('$baseUrl/registerBuyer');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userid': userid,
        'email': email,
        'name': name,
        'phonenumber': phoneNumber,
        'password': password,
        'username': username,
        'paymentmethod': paymentMethod,
        'deliveryaddress': deliveryAddress,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true; // Registration successful
    } else {
      // Handle error (e.g., log the response body)
      print('Error: ${response.body}');
      return false; // Registration failed
    }
  }
}
