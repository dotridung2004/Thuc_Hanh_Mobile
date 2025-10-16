import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/order_provider.dart';
import 'screens/checkout_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => OrderProvider(),
      child: MaterialApp(
        title: 'Checkout Stepper',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const CheckoutScreen(), // Bắt đầu với màn hình checkout
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}