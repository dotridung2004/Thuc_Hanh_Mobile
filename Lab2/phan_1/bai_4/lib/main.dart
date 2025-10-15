import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // file này có sau khi bạn chạy `flutterfire configure`

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _generateFakeBlogs() async {
    final faker = Faker();
    final collection = FirebaseFirestore.instance.collection('blogs');

    for (int i = 0; i < 50; i++) {
      await collection.add({
        'title': faker.lorem.sentence(),
        'content': faker.lorem.sentences(5).join(' '),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Fake Blog Generator')),
        body: Center(
          child: ElevatedButton(
            onPressed: _generateFakeBlogs,
            child: const Text('Tạo 50 bản ghi mẫu'),
          ),
        ),
      ),
    );
  }
}
