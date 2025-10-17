// lib/data_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'data_model.g.dart'; // File sẽ được tạo bởi build_runner

@JsonSerializable()
class SurveyRecord {
  final double latitude;
  final double longitude;
  final double lux; // Cường độ ánh sáng
  final double dynamismMagnitude; // Độ lớn vector gia tốc
  final double magneticMagnitude; // Độ lớn vector từ trường
  final DateTime timestamp;

  SurveyRecord({
    required this.latitude,
    required this.longitude,
    required this.lux,
    required this.dynamismMagnitude,
    required this.magneticMagnitude,
    required this.timestamp,
  });

  factory SurveyRecord.fromJson(Map<String, dynamic> json) =>
      _$SurveyRecordFromJson(json);

  Map<String, dynamic> toJson() => _$SurveyRecordToJson(this);
}