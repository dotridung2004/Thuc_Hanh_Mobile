// lib/survey_station_screen.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:bai_1/data_service.dart';

class SurveyStationScreen extends StatefulWidget {
  final VoidCallback onDataRecorded;

  const SurveyStationScreen({super.key, required this.onDataRecorded});

  @override
  State<SurveyStationScreen> createState() => _SurveyStationScreenState();
}

class _SurveyStationScreenState extends State<SurveyStationScreen> {
  final DataService _dataService = DataService();

  // Dữ liệu cảm biến trực tiếp
  double _lux = 0.0; // Giả lập
  double _dynamismMagnitude = 0.0;
  double _magneticMagnitude = 0.0;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _startSensorStreams();
  }

  void _startSensorStreams() {
    // Gia tốc kế (Dynamism)
    accelerometerEventStream(samplingPeriod: const Duration(milliseconds: 100)).listen((AccelerometerEvent event) {
      setState(() {
        _dynamismMagnitude = _dataService.calculateMagnitude(event.x, event.y, event.z);
      });
    });

    // Từ kế (Magnetic Field)
    magnetometerEventStream(samplingPeriod: const Duration(milliseconds: 100)).listen((MagnetometerEvent event) {
      setState(() {
        _magneticMagnitude = _dataService.calculateMagnitude(event.x, event.y, event.z);
      });
    });

    // Ánh sáng (Lux) - GIẢ LẬP (Thay thế bằng code native nếu cần)
    // Cứ mỗi 0.5s tạo một giá trị ngẫu nhiên để mô phỏng sự thay đổi
    Stream.periodic(const Duration(milliseconds: 500)).listen((_) {
      setState(() {
        // Lux dao động quanh 1000 +/- 500
        _lux = 1000.0 + (Random().nextDouble() - 0.5) * 1000.0;
        if (_lux < 0) _lux = 0;
      });
    });
  }

  Future<void> _recordData() async {
    if (_isRecording) return;

    setState(() {
      _isRecording = true;
    });

    final record = await _dataService.collectData();

    setState(() {
      _isRecording = false;
    });

    if (record != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã ghi dữ liệu thành công!')),
      );
      widget.onDataRecorded(); // Thông báo cho màn hình chính cập nhật bản đồ
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Lỗi khi ghi dữ liệu. Kiểm tra quyền GPS.')),
      );
    }
  }

  Widget _buildSensorCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: color, size: 36),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trạm Khảo sát')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('DỮ LIỆU TRỰC TIẾP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildSensorCard(
              'Cường độ Ánh sáng (Lux)',
              '${_lux.toStringAsFixed(2)} lux',
              Icons.light_mode,
              Colors.orange.shade800,
            ),
            _buildSensorCard(
              'Độ "Năng động" (m/s²)',
              '${_dynamismMagnitude.toStringAsFixed(2)} m/s²',
              Icons.directions_run,
              Colors.red.shade800,
            ),
            _buildSensorCard(
              'Cường độ Từ trường (µT)',
              '${_magneticMagnitude.toStringAsFixed(2)} µT',
              Icons.compass_calibration,
              Colors.blue.shade800,
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: _isRecording
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.gps_fixed),
              label: Text(_isRecording ? 'Đang Ghi...' : 'Ghi Dữ liệu tại Điểm này',
                  style: const TextStyle(fontSize: 18)),
              onPressed: _recordData,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}