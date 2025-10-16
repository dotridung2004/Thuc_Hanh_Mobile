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
      title: 'Rich Text Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const RichTextExampleScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RichTextExampleScreen extends StatefulWidget {
  const RichTextExampleScreen({super.key});

  @override
  _RichTextExampleScreenState createState() => _RichTextExampleScreenState();
}

class _RichTextExampleScreenState extends State<RichTextExampleScreen> {
  // Biến trạng thái để quản lý việc mở rộng/thu gọn văn bản
  bool _isExpanded = true;

  // Hàm helper để mở URL
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      // Hiển thị thông báo lỗi nếu không mở được link
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở được link: $urlString')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Rich Text Example'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: RichText(
            text: buildTextSpan(),
          ),
        ),
      ),
    );
  }

  // Hàm xây dựng cây TextSpan dựa trên trạng thái _isExpanded
  TextSpan buildTextSpan() {
    const String fullText =
        'Flutter is an open-source UI software development kit created by Google. It is used to develop cross platform applications for Android, iOS, Linux, macOS, Windows, Google Fuchsia, and the web from a single codebase. First described in 2015, Flutter was released in May 2017.';
    const String contactInfo =
        '\nContact on +910000210056. Our email address is test@exampleemail.org. For more details check https://www.google.com';

    // Chỉ hiển thị một phần văn bản nếu không được mở rộng
    final String visibleText =
    _isExpanded ? fullText : '${fullText.substring(0, 150)}...';

    return TextSpan(
      style: TextStyle(
        color: Colors.grey[800],
        fontSize: 16.0,
        height: 1.5,
      ),
      children: [
        // Phần văn bản chính
        TextSpan(text: visibleText),

        // Hiển thị thông tin liên hệ chỉ khi mở rộng
        if (_isExpanded)
          TextSpan(
            children: [
              const TextSpan(text: '\nContact on '),
              // Số điện thoại có thể nhấn
              TextSpan(
                text: '+910000210056',
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    _launchUrl('tel:+910000210056');
                  },
              ),
              const TextSpan(text: '. Our email address is '),
              // Email có thể nhấn
              TextSpan(
                text: 'test@exampleemail.org',
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    _launchUrl('mailto:test@exampleemail.org');
                  },
              ),
              const TextSpan(text: '. For more details check '),
              // Website có thể nhấn
              TextSpan(
                text: 'https://www.google.com',
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    _launchUrl('https://www.google.com');
                  },
              ),
            ],
          ),

        // Nút Read more/Read less
        TextSpan(
          text: _isExpanded ? '\nRead less' : ' Read more',
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              // Cập nhật lại trạng thái và rebuild UI
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
        ),
      ],
    );
  }
}