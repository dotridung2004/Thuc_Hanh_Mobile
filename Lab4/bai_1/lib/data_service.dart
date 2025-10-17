// lib/data_service.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:bai_1/data_model.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class DataService {
  static const String _fileName = 'schoolyard_map_data.json';
  final Location _location = Location();

  // Hàm tiện ích: Tính độ lớn vector (Magnitude)
  double calculateMagnitude(double x, double y, double z) {
    return sqrt(x * x + y * y + z * z);
  }

  // -------------------------
  // QUẢN LÝ FILE
  // -------------------------

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  // Đọc tất cả bản ghi từ file
  Future<List<SurveyRecord>> loadRecords() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((e) => SurveyRecord.fromJson(e)).toList();
    } catch (e) {
      print('Lỗi khi đọc file: $e');
      return [];
    }
  }

  // Lưu bản ghi mới vào file
  Future<void> saveRecord(SurveyRecord record) async {
    try {
      final file = await _localFile;
      final currentRecords = await loadRecords();
      currentRecords.add(record);

      final List<Map<String, dynamic>> jsonList =
      currentRecords.map((e) => e.toJson()).toList();

      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      print('Lỗi khi ghi file: $e');
    }
  }

  // -------------------------
  // THU THẬP DỮ LIỆU
  // -------------------------

  // Xin quyền vị trí
  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  // Thu thập tất cả dữ liệu
  Future<SurveyRecord?> collectData() async {
    // 1. Kiểm tra và lấy vị trí
    if (!await requestLocationPermission()) {
      return null;
    }
    LocationData? locationData;
    try {
      locationData = await _location.getLocation();
    } catch (e) {
      print('Lỗi khi lấy vị trí: $e');
      return null;
    }

    // 2. Lấy dữ liệu cảm biến
    // Chú ý: Các luồng cảm biến không đồng bộ, nên ta chỉ lấy một mẫu đầu tiên.

    // Gia tốc kế (Dynamism)
    final accelerometerEvent = await accelerometerEventStream(samplingPeriod: const Duration(milliseconds: 100))
        .first;
    final dynamism = calculateMagnitude(
        accelerometerEvent.x, accelerometerEvent.y, accelerometerEvent.z);

    // Từ kế (Magnetic Field)
    final magnetometerEvent = await magnetometerEventStream(samplingPeriod: const Duration(milliseconds: 100))
        .first;
    final magnetic = calculateMagnitude(
        magnetometerEvent.x, magnetometerEvent.y, magnetometerEvent.z);

    // Ánh sáng (Lux) - GIẢ LẬP
    final lux = Random().nextDouble() * (2000.0 - 100.0) + 100.0; // Lux từ 100 đến 2000

    // 3. Gói dữ liệu
    if (locationData.latitude != null && locationData.longitude != null) {
      final record = SurveyRecord(
        latitude: locationData.latitude!,
        longitude: locationData.longitude!,
        lux: lux,
        dynamismMagnitude: dynamism,
        magneticMagnitude: magnetic,
        timestamp: DateTime.now(),
      );
      await saveRecord(record);
      return record;
    }
    return null;
  }
}