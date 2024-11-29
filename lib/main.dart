import 'package:farmersmarketflutter/screens/buyerdashboard.dart';
import 'package:flutter/material.dart';
import 'screens/login.dart';  // Import LoginPage
import 'screens/buyerregistration.dart';  // Import BuyerRegistrationPage
import 'screens/farmerregistration.dart';  // Import FarmerRegistrationPage
import 'screens/farmerdashboard.dart'; 
import 'screens/farmerpoductlisting.dart';
import 'screens/buyerproductlisting.dart';

void main() {
  runApp(const FarmersMarketApp());
}

class FarmersMarketApp extends StatelessWidget {
  const FarmersMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmers Market App',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/farmerregistration': (context) => const FarmerRegistrationPage(),
        '/buyerregistration': (context) => const BuyerRegistrationPage(),
        '/farmer_dashboard': (context) => const FarmerDashboard(),
        '/farmerproductlisting':(context) => const ProductListingPage (),
        '/buyerproductlisting':(context) => const BuyerInterface (),
        '/buyer_dashboard':(context) => const BuyerDashboard (),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmers Market App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Farmers Market App!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 40),
            const Text(
              'Are you a farmer or buyer?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/farmerregistration'); // Navigate to Farmer Registration
              },
              child: const Text('Farmer Registration'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/buyerregistration'); // Navigate to Buyer Registration
              },
              child: const Text('Buyer Registration'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Already have an account?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login'); // Navigate to LoginPage
              },
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/farmerdashboard'); // Navigate to Farmer Registration
              },
              child: const Text('Farmer dashboards'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/farmerproductlisting'); // Navigate to Farmer Registration
              },
              child: const Text('Farmer product listing'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/buyerproductlisting'); // Navigate to Farmer Registration
              },
              child: const Text('Buyer product listing'),
            ),
          ],
        ),
      ),
    );
  }
}



