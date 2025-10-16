import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/address_model.dart';

class AddressProvider with ChangeNotifier {
  final List<Address> _addresses = [];

  List<Address> get addresses => [..._addresses];

  void addAddress(Address address) {
    const uuid = Uuid();
    final newAddress = Address(
      id: uuid.v4(),
      recipientName: address.recipientName,
      phoneNumber: address.phoneNumber,
      province: address.province,
      district: address.district,
      ward: address.ward,
      addressDetails: address.addressDetails,
      location: address.location,
    );
    _addresses.add(newAddress);
    notifyListeners();
  }

  void updateAddress(String id, Address newAddress) {
    final addressIndex = _addresses.indexWhere((addr) => addr.id == id);
    if (addressIndex >= 0) {
      _addresses[addressIndex] = newAddress;
      notifyListeners();
    }
  }

  void deleteAddress(String id) {
    _addresses.removeWhere((addr) => addr.id == id);
    notifyListeners();
  }
}