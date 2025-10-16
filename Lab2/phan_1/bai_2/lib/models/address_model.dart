import 'package:google_maps_flutter/google_maps_flutter.dart';

class Address {
  final String id;
  String recipientName;
  String phoneNumber;
  String province;
  String district;
  String ward;
  String addressDetails;
  LatLng? location; // Vị trí có thể null

  Address({
    required this.id,
    required this.recipientName,
    required this.phoneNumber,
    required this.province,
    required this.district,
    required this.ward,
    required this.addressDetails,
    this.location,
  });
}