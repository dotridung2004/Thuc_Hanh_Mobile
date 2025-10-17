// lib/main.dart

import 'package:flutter/material.dart';
import 'package:bai_1/data_map_screen.dart';
import 'package:bai_1/survey_station_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bản đồ nhiệt Sân trường',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _dataRefreshKey = 0; // Key để buộc màn hình DataMapScreen tải lại dữ liệu

  void _onDataRecorded() {
    // Tăng key để thông báo cho DataMapScreen rằng đã có dữ liệu mới
    setState(() {
      _dataRefreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      SurveyStationScreen(onDataRecorded: _onDataRecorded),
      DataMapScreen(refreshKey: _dataRefreshKey),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore),
            label: 'Trạm Khảo sát',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Bản đồ Dữ liệu',
          ),
        ],
      ),
    );
  }
}