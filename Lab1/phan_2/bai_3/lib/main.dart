import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RichText Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const RichTextScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RichTextScreen extends StatelessWidget {
  const RichTextScreen({super.key});

  // Hàm helper để mở URL
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      // Có thể thêm thông báo lỗi ở đây nếu muốn
      print('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RichText'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng "Hello World" đầu tiên
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 24, color: Colors.black),
                children: [
                  TextSpan(
                    text: 'Hello ',
                    style: TextStyle(color: Color(0xFF26A69A)), // Teal color
                  ),
                  TextSpan(
                    text: 'World',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dòng "Hello World" thứ hai với emoji
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'Hello ',
                    style: TextStyle(color: Color(0xFF26A69A)), // Teal color
                  ),
                  TextSpan(
                    text: 'World 👋',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Dòng Email
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 18, color: Colors.black87),
                children: [
                  const TextSpan(text: 'Contact me via: 📧 '),
                  TextSpan(
                    text: 'Email',
                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _launchUrl('mailto:example@email.com');
                      },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dòng Số điện thoại
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 18, color: Colors.black87),
                children: [
                  const TextSpan(text: 'Call Me: '),
                  TextSpan(
                    text: '+1234987654321',
                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _launchUrl('tel:+1234987654321');
                      },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dòng Blog
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 18, color: Colors.black87),
                children: [
                  const TextSpan(text: 'Read My Blog '),
                  TextSpan(
                    text: 'HERE',
                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _launchUrl('https://flutter.dev');
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}