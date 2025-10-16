import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/address_model.dart';
import '../providers/address_provider.dart';
import 'map_picker_screen.dart';

class AddAddressScreen extends StatefulWidget {
  final Address? address;

  const AddAddressScreen({super.key, this.address});

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _detailsController;

  // Mock data for Dropdowns
  final List<String> _provinces = ['Hà Nội', 'TP. Hồ Chí Minh', 'Đà Nẵng'];
  final Map<String, List<String>> _districts = {
    'Hà Nội': ['Ba Đình', 'Hoàn Kiếm', 'Hai Bà Trưng'],
    'TP. Hồ Chí Minh': ['Quận 1', 'Quận 3', 'Bình Thạnh'],
    'Đà Nẵng': ['Hải Châu', 'Sơn Trà', 'Ngũ Hành Sơn'],
  };
  final Map<String, List<String>> _wards = {
    // Hà Nội
    'Ba Đình': ['Phúc Xá', 'Trúc Bạch', 'Vĩnh Phúc'],
    'Hoàn Kiếm': ['Hàng Bạc', 'Hàng Buồm', 'Trần Hưng Đạo'],
    'Hai Bà Trưng': ['Bách Khoa', 'Bạch Đằng', 'Cầu Dền'],
    // TP. Hồ Chí Minh
    'Quận 1': ['Bến Nghé', 'Tân Định', 'Đa Kao'],
    'Quận 3': ['Phường 1', 'Phường 2', 'Phường 3'],
    'Bình Thạnh': ['Phường 1', 'Phường 2', 'Phường 3'],
    // Đà Nẵng
    'Hải Châu': ['Bình Hiên', 'Hòa Cường Bắc', 'Thanh Bình'],
    'Sơn Trà': ['An Hải Bắc', 'An Hải Đông', 'Phước Mỹ'],
    'Ngũ Hành Sơn': ['Mỹ An', 'Hòa Hải', 'Hòa Quý'],
  };

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.recipientName);
    _phoneController = TextEditingController(text: widget.address?.phoneNumber);
    _detailsController = TextEditingController(text: widget.address?.addressDetails);

    if (widget.address != null) {
      _selectedProvince = widget.address!.province;
      _selectedDistrict = widget.address!.district;
      _selectedWard = widget.address!.ward;
      _selectedLocation = widget.address!.location;
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newAddress = Address(
        id: widget.address?.id ?? '',
        recipientName: _nameController.text,
        phoneNumber: _phoneController.text,
        province: _selectedProvince!,
        district: _selectedDistrict!,
        ward: _selectedWard!,
        addressDetails: _detailsController.text,
        location: _selectedLocation,
      );

      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      if (widget.address == null) {
        addressProvider.addAddress(newAddress);
      } else {
        addressProvider.updateAddress(widget.address!.id, newAddress);
      }
      Navigator.of(context).pop();
    }
  }

  void _openMapPicker() async {
    final pickedLocation = await showDialog<LatLng>(
      context: context,
      builder: (ctx) => const MapPickerScreen(),
    );

    if (pickedLocation != null) {
      setState(() {
        _selectedLocation = pickedLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Add New Address' : 'Edit Address'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(label: 'Recipient Name', controller: _nameController),
              _buildTextField(label: 'Phone Number', controller: _phoneController, keyboardType: TextInputType.phone),
              _buildDropdown(
                label: 'Province/City',
                hint: 'Select Province',
                value: _selectedProvince,
                items: _provinces,
                onChanged: (value) {
                  setState(() {
                    _selectedProvince = value;
                    _selectedDistrict = null;
                    _selectedWard = null;
                  });
                },
              ),
              _buildDropdown(
                label: 'District',
                hint: 'Select District',
                value: _selectedDistrict,
                // *** FIX HERE: Use ?? [] instead of ! ***
                items: _districts[_selectedProvince] ?? [],
                onChanged: (value) {
                  setState(() {
                    _selectedDistrict = value;
                    _selectedWard = null;
                  });
                },
              ),
              _buildDropdown(
                label: 'Ward',
                hint: 'Select Ward',
                value: _selectedWard,
                // *** FIX HERE: Use ?? [] instead of ! ***
                items: _wards[_selectedDistrict] ?? [],
                onChanged: (value) {
                  setState(() {
                    _selectedWard = value;
                  });
                },
              ),
              _buildTextField(label: 'Address Details', controller: _detailsController, maxLines: 4),
              const SizedBox(height: 16),
              const Text('Location on Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _openMapPicker,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Select on Map'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedLocation == null
                          ? 'No location selected'
                          : 'Location Picked!',
                      style: TextStyle(
                        color: _selectedLocation == null ? Colors.grey : Colors.green,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save Address'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            isExpanded: true,
            hint: Text(hint),
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: items.isEmpty ? null : onChanged,
            validator: (value) => value == null ? '$label is required' : null,
          ),
        ],
      ),
    );
  }
}