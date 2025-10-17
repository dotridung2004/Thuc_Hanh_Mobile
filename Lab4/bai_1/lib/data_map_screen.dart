// lib/data_map_screen.dart

import 'package:flutter/material.dart';
import 'package:bai_1/data_model.dart';
import 'package:bai_1/data_service.dart';
import 'package:intl/intl.dart'; // Thêm dependency intl vào pubspec.yaml nếu muốn format ngày tháng

class DataMapScreen extends StatefulWidget {
  final int refreshKey; // Dùng để buộc refresh khi có dữ liệu mới

  const DataMapScreen({super.key, required this.refreshKey});

  @override
  State<DataMapScreen> createState() => _DataMapScreenState();
}

class _DataMapScreenState extends State<DataMapScreen> {
  final DataService _dataService = DataService();
  List<SurveyRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant DataMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Tải lại dữ liệu khi refreshKey thay đổi
    if (widget.refreshKey != oldWidget.refreshKey) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    final records = await _dataService.loadRecords();
    setState(() {
      _records = records.reversed.toList(); // Hiển thị bản ghi mới nhất trước
      _isLoading = false;
    });
  }

  // Hàm chuyển đổi giá trị cảm biến thành màu sắc
  Color _mapValueToColor(double value, double min, double max, Color lowColor, Color highColor) {
    if (value.isNaN) return lowColor;
    final normalized = ((value - min) / (max - min)).clamp(0.0, 1.0);
    return Color.lerp(lowColor, highColor, normalized)!;
  }

  Widget _buildSensorVisualization(String title, double value, IconData icon, double min, double max, Color lowColor, Color highColor, String unit) {
    final color = _mapValueToColor(value, min, max, lowColor, highColor);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 4),
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          Text(unit, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  // Card trực quan hóa dữ liệu
  Widget _buildRecordCard(SurveyRecord record, int index) {
    // Giá trị chuẩn hóa (cần điều chỉnh min/max thực tế)
    const double luxMax = 2500.0;
    const double dynamismMax = 15.0; // Khoảng 9.8 (trọng lực) + rung động
    const double magneticMax = 100.0; // Micro Tesla

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ĐIỂM KHẢO SÁT #${_records.length - index}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                Text(
                  DateFormat('dd/MM HH:mm:ss').format(record.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 10),
            Text('GPS: Lat ${record.latitude.toStringAsFixed(4)}, Lon ${record.longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Ánh sáng (Mặt trời, Vàng nhạt -> Vàng đậm)
                _buildSensorVisualization(
                  'Ánh sáng',
                  record.lux,
                  Icons.wb_sunny,
                  100.0, luxMax,
                  Colors.yellow.shade200, Colors.yellow.shade900,
                  'lux',
                ),
                // Năng động (Bước chân, Xanh -> Đỏ)
                _buildSensorVisualization(
                  'Năng động',
                  record.dynamismMagnitude,
                  Icons.directions_walk,
                  9.0, dynamismMax, // 9.8 là giá trị tĩnh
                  Colors.green.shade200, Colors.red.shade800,
                  'm/s²',
                ),
                // Từ trường (Nam châm, Trắng -> Xanh dương)
                _buildSensorVisualization(
                  'Từ trường',
                  record.magneticMagnitude,
                  Icons.compass_calibration,
                  20.0, magneticMax,
                  Colors.blue.shade100, Colors.blue.shade900,
                  'µT',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bản đồ Dữ liệu')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
          ? const Center(child: Text('Chưa có dữ liệu nào được ghi!'))
          : ListView.builder(
        itemCount: _records.length,
        itemBuilder: (context, index) {
          return _buildRecordCard(_records[index], index);
        },
      ),
    );
  }
}