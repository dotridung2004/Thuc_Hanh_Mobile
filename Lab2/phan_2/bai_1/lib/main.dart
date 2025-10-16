import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/order_provider.dart';
import 'screens/order_list_screen.dart';

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
        title: 'Quản lý Đơn hàng',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          // Gợi ý màu sắc thương mại
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple).copyWith(
            secondary: Colors.orangeAccent,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        home: const OrderListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}