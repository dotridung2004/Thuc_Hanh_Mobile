import 'package:flutter/material.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto', // Bạn có thể thêm font chữ tùy ý
      ),
      home: const RegisterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}