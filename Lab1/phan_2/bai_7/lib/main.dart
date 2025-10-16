import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gradient Buttons Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GradientButtonsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Widget màn hình chính
class GradientButtonsScreen extends StatelessWidget {
  const GradientButtonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gradient Buttons'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          // Căn chỉnh các nút cách đều nhau
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GradientButton(
              text: 'Click me 1',
              onPressed: () {
                print('Button 1 clicked');
              },
              gradient: const LinearGradient(
                colors: [Color(0xFF69F0AE), Color(0xFF00C853)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            GradientButton(
              text: 'Click me 2',
              onPressed: () {
                print('Button 2 clicked');
              },
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8A80), Color(0xFFFF5252)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            GradientButton(
              text: 'Click me 3',
              onPressed: () {
                print('Button 3 clicked');
              },
              gradient: const LinearGradient(
                colors: [Color(0xFF40C4FF), Color(0xFF0091EA)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            GradientButton(
              text: 'Click me 4',
              onPressed: () {
                print('Button 4 clicked');
              },
              gradient: LinearGradient(
                colors: [Colors.grey[800]!, Colors.grey[400]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget tùy chỉnh cho Gradient Button
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Gradient gradient;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(30.0), // Bo tròn góc
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30.0),
          child: Container(
            // Kích thước và căn chỉnh cho button
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}