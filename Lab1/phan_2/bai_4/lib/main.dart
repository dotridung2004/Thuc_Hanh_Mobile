import 'package:flutter/material.dart';
import 'widgets/app_button.dart'; // Import file button của bạn

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Buttons Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AppButtonsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppButtonsScreen extends StatelessWidget {
  const AppButtonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Buttons'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          AppButton.primary(
            'AppButton.primary()',
            onPressed: () {},
          ),
          const SizedBox(height: 16),
          AppButton.primary(
            'AppButton.primary() - disabled',
            onPressed: () {}, // onPressed vẫn có thể có, nhưng isDisabled sẽ vô hiệu hóa nó
            isDisabled: true,
          ),
          const SizedBox(height: 16),
          AppButton.outlined(
            'AppButton.outlined()',
            onPressed: () {},
          ),
          const SizedBox(height: 16),
          AppButton.gradient(
            'AppButton.gradient()',
            onPressed: () {},
          ),
          const SizedBox(height: 16),
          AppButton.accentGradient(
            'AppButton.accentGradient()',
            onPressed: () {},
          ),
          const SizedBox(height: 32),
          AppTextButton(
            'AppTextButton()',
            onPressed: () {},
          ),
          const SizedBox(height: 8),
          const AppTextButton(
            'disabled AppTextButton()',
            isDisabled: true,
          ),
        ],
      ),
    );
  }
}