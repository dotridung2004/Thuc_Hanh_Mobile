import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/address_provider.dart';
import 'screens/address_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => AddressProvider(),
      child: MaterialApp(
        title: 'Address Management',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AddressListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}