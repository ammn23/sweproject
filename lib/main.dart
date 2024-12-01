import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/login.dart';  // Import LoginPage
import 'screens/buyer/buyerregistration.dart';  // Import BuyerRegistrationPage
import 'screens/farmer/farmerregistration.dart';  // Import FarmerRegistrationPage
import 'screens/farmer/farmerdashboard.dart';  // Import FarmerDashboardPage
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/chat_screen.dart';
import 'screens/buyer/buyer_chat_list.dart';
import 'screens/farmer/farmer_chat_list.dart';
import 'screens/farmer/farmer_reports_screen.dart';
import 'screens/buyer/buyer_reports_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize local notifications plugin
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Check if user is logged in by checking SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // Get FCM token only if the user is logged in
  if (isLoggedIn) {
    messaging.getToken().then((token) {
      print("FCM Token: $token");
      // Save token to your backend for future use (make sure to associate it with the user)
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.title}');
      showNotification(message, flutterLocalNotificationsPlugin);
    });

    // Handle messages when the app is opened from a background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked!');
      // You can navigate to a specific screen when the user taps the notification
    });

    // Handle notifications when the app is in the background or terminated (needs to be configured in AndroidManifest.xml for Android)
    FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
  }

  runApp(const FarmersMarketApp());
}

Future<void> backgroundMessageHandler(RemoteMessage message) async {
  // This is the background handler for FCM messages
  print("Background message received: ${message.notification?.title}");
  // You can show notifications or do other tasks here
}

class FarmersMarketApp extends StatelessWidget {
  const FarmersMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmers Market App',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',  // Start with login page
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/farmerregistration': (context) => const FarmerRegistrationPage(),
        '/buyerregistration': (context) => const BuyerRegistrationPage(),
        '/chatscreen':(context)=> const ChatScreen(chatId: 3,userId:7) ,
        '/farmer_chat_list':(context)=> FarmerChatsList(userId:7) ,
        '/buyer_chat_list':(context)=> BuyerChatsList(userId:8) ,
        '/farmer_reports_screen':(context)=>FarmerReportsScreen(userId:7),
        '/buyer_reports_screen':(context)=>BuyerReportsScreen(userId:8),
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
                Navigator.pushNamed(context, '/chatscreen'); // Navigate to LoginPage
              },
              child: const Text('Chatscreen'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/farmer_reports_screen'); // Navigate to LoginPage
              },
              child: const Text('Farmer reports screen'),
            ),
            
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/buyer_reports_screen'); // Navigate to LoginPage
              },
              child: const Text('Buyer reports screen'),
            ),
          ],
        ),
      ),
    );
  }
}

// Function to show local notifications when a message is received
void showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  const notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'order_notifications',
      'Order Status Notifications',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title,
    message.notification?.body,
    notificationDetails,
  );
}




