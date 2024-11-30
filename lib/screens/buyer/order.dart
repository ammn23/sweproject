import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateOrderPage extends StatefulWidget {
  final int userId;

  const CreateOrderPage({required this.userId, super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  List<Map<String, dynamic>> cartItems = [];
  double totalCost = 0.0;
  double deliveryCost = 0.0;
  String selectedDeliveryMethod = "Home Delivery";
  String deliveryAddress = "";
  String paymentMethod = "";
  bool isLoading = true;

  final deliveryPrices = {
    "Home Delivery": 3.0,
    "Pick-Up Points": 0.0,
    "Third-Party Delivery": 5.0,
  };

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      final cartResponse = await http.get(
        Uri.parse('http://10.0.2.2:8080/cart_items?user_id=${widget.userId}'),
      );

      final buyerResponse = await http.get(
        Uri.parse(
            'http://10.0.2.2:8080/buyer_details?user_id=${widget.userId}'),
      );

      if (cartResponse.statusCode == 200 && buyerResponse.statusCode == 200) {
        final cartData =
            List<Map<String, dynamic>>.from(jsonDecode(cartResponse.body));
        final buyerData =
            Map<String, dynamic>.from(jsonDecode(buyerResponse.body));

        double cartTotal = cartData.fold(
          0.0,
          (sum, item) => sum + item['total_price'],
        );

        setState(() {
          cartItems = cartData;
          totalCost = cartTotal;
          deliveryAddress = buyerData['delivery_address'];
          paymentMethod = buyerData['payment_method'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void updateDeliveryDetails(String method) {
    setState(() {
      selectedDeliveryMethod = method;
      deliveryCost = deliveryPrices[method]!;
      deliveryAddress = method == "Pick-Up Points"
          ? cartItems[0]['farm_location'] // Assuming one farm location
          : deliveryAddress;
    });
  }

  Future<void> createOrder() async {
    try {
      final paymentResponse = await http.post(
        Uri.parse('http://10.0.2.2:8080/create_payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'buyer_id': widget.userId,
          'date': DateTime.now().toIso8601String(),
          'amount': totalCost + deliveryCost,
          'method': paymentMethod,
          'status': 'Successful',
        }),
      );

      if (paymentResponse.statusCode == 201) {
        final paymentId = jsonDecode(paymentResponse.body)['payment_id'];

        final orderResponse = await http.post(
          Uri.parse('http://10.0.2.2:8080/create_order'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'buyer_id': widget.userId,
            'date_ordered': DateTime.now().toIso8601String(),
            'date_shipped': null,
            'address': deliveryAddress,
            'payment_id': paymentId,
          }),
        );

        if (orderResponse.statusCode == 201) {
          final estimatedDeliveryDate =
              DateTime.now().add(const Duration(days: 3));
          final orderId = jsonDecode(orderResponse.body)['order_id'];

          // Navigate to Order Confirmation Page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderConfirmationPage(
                orderId: orderId,
                deliveryAddress: deliveryAddress,
                totalCost: totalCost + deliveryCost,
                estimatedDeliveryDate: estimatedDeliveryDate,
                deliveryMethod: selectedDeliveryMethod,
              ),
            ),
          );
        } else {
          throw Exception('Failed to create order');
        }
      } else {
        throw Exception('Failed to create payment');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Order')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        leading: const Icon(Icons.shopping_cart),
                        title: Text(item['product_name']),
                        subtitle: Text(
                          'Quantity: ${item['selected_quantity']} | Price: \$${item['total_price'].toStringAsFixed(2)}',
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Method:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<String>(
                        value: selectedDeliveryMethod,
                        items: deliveryPrices.keys
                            .map((method) => DropdownMenuItem(
                                  value: method,
                                  child: Text(method),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) updateDeliveryDetails(value);
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Delivery Address: $deliveryAddress',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Total Cost: \$${(totalCost + deliveryCost).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: createOrder,
                        child: const Text('Confirm Order'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class OrderConfirmationPage extends StatelessWidget {
  final int orderId;
  final String deliveryAddress;
  final double totalCost;
  final DateTime estimatedDeliveryDate;
  final String deliveryMethod;

  const OrderConfirmationPage({
    required this.orderId,
    required this.deliveryAddress,
    required this.totalCost,
    required this.estimatedDeliveryDate,
    required this.deliveryMethod,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: $orderId',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Delivery Address: $deliveryAddress',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Delivery Method: $deliveryMethod',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Cost: \$${totalCost.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Estimated Delivery Date: ${estimatedDeliveryDate.toLocal()}'
                  .split(' ')[0],
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Go to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

