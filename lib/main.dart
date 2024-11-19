import 'package:flutter/material.dart';
import 'screens/buyerlogin.dart';  // Updated import path
import 'screens/buyerregistration.dart';  // Updated import path

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buyer Auth',
      initialRoute: '/buyerlogin',
      routes: {
        '/buyerlogin': (context) => const BuyerLogin(),
        '/buyerregistration': (context) => const BuyerRegistrationPage(),
      },
    );
  }
}
