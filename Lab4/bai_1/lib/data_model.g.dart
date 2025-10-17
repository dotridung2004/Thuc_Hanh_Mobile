// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurveyRecord _$SurveyRecordFromJson(Map<String, dynamic> json) => SurveyRecord(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  lux: (json['lux'] as num).toDouble(),
  dynamismMagnitude: (json['dynamismMagnitude'] as num).toDouble(),
  magneticMagnitude: (json['magneticMagnitude'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$SurveyRecordToJson(SurveyRecord instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'lux': instance.lux,
      'dynamismMagnitude': instance.dynamismMagnitude,
      'magneticMagnitude': instance.magneticMagnitude,
      'timestamp': instance.timestamp.toIso8601String(),
    };
