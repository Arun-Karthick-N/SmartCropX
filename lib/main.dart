import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Providers
import 'providers/cart_provider.dart';

// Pages
import 'screens/splash_screen.dart';
import 'screens/login_page.dart';
import 'screens/farmer_home_page.dart';
import 'screens/consumer_home_page.dart';
import 'pages/cart_page.dart';
import 'pages/checkout_page.dart';
import 'pages/payment_page.dart';
import 'pages/order_confirmation_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Debugging - Print loaded environment variables
  print("🔍 SUPABASE_URL: ${dotenv.env['SUPABASE_URL']}");
  print("🔍 SUPABASE_ANON_KEY: ${dotenv.env['SUPABASE_ANON_KEY']}");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCropX',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // Set SplashScreen as the home screen
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginPage(),
        '/farmer_home': (context) => FarmerHomePage(),
        '/consumer_home': (context) => ConsumerHomePage(),
        '/cart': (context) => CartPage(),
        '/checkout': (context) {
          final cartProvider =
          Provider.of<CartProvider>(context, listen: false);
          return CheckoutPage(
            cartItems: cartProvider.items,
            subtotal: cartProvider.subtotal,
            deliveryFee: cartProvider.deliveryFee,
            total: cartProvider.total,
          );
        },
        '/payment': (context) {
          final cartProvider =
          Provider.of<CartProvider>(context, listen: false);
          return PaymentPage(
            cartItems: cartProvider.items,
            deliveryInfo: {
              'name': 'Unknown', // Placeholder, updated in CheckoutPage
              'phone': '',
              'address': '',
              'city': '',
              'zipCode': '',
              'deliveryMethod': 'Standard Delivery',
            },
            total: cartProvider.total,
          );
        },
        '/order_confirmation': (context) {
          final cartProvider =
          Provider.of<CartProvider>(context, listen: false);
          return OrderConfirmationPage(
            orderId: "ORD123456",
            total: cartProvider.total,
            deliveryInfo: {
              'name': 'Unknown', // Placeholder, updated in PaymentPage
              'phone': '',
              'address': '',
              'city': '',
              'zipCode': '',
              'deliveryMethod': 'Standard Delivery',
            },
          );
        },
      },
    );
  }
}
