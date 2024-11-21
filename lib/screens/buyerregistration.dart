import 'package:flutter/material.dart';
import 'package:farmersmarketflutter/service.dart';

class BuyerRegistrationPage extends StatefulWidget {
  const BuyerRegistrationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BuyerRegistrationPageState createState() => _BuyerRegistrationPageState();
}

class _BuyerRegistrationPageState extends State<BuyerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();
  final TextEditingController _deliveryAddressController = TextEditingController();

  // Assuming userid is fetched from authenticated user session or context
  int userid = 123; // Example, this should come from user context/authentication

  // Form submission function
  Future<void> _submitForm() async{
    if (_formKey.currentState?.validate() ?? false) {
      final ApiService apiService = ApiService(baseUrl: 'https://yourapi.com');

      final success = await apiService.registerBuyer(
              userid: 123,
              email: _emailController.text,
              name: _nameController.text,
              phoneNumber: _phoneNumberController.text,
              password: _passwordController.text,
              username: _usernameController.text,
              paymentMethod: _paymentMethodController.text,
              deliveryAddress: _deliveryAddressController.text,
            );

      
      if (success){
        // Clear the form
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration completed.Wait for approval'))
        );
        _emailController.clear();
        _nameController.clear();
        _phoneNumberController.clear();
        _passwordController.clear();
        _usernameController.clear();
        _paymentMethodController.clear();
        _deliveryAddressController.clear();
      } else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Phone Number Field
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Payment Method Field
                TextFormField(
                  controller: _paymentMethodController,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a payment method';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Delivery Address Field
                TextFormField(
                  controller: _deliveryAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a delivery address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


