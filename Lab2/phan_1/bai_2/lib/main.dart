import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AddressManagerScreen(),
  ));
}

class Address {
  final String name;
  final String phone;
  final String province;
  final String district;
  final String ward;
  final String detail;
  final double? lat;
  final double? lng;

  Address({
    required this.name,
    required this.phone,
    required this.province,
    required this.district,
    required this.ward,
    required this.detail,
    this.lat,
    this.lng,
  });
}

const provinceData = {
  "Hà Nội": {
    "Ba Đình": ["Phúc Xá", "Trúc Bạch"],
    "Hoàn Kiếm": ["Chương Dương", "Hàng Bạc"],
  },
  "TP.HCM": {
    "Quận 1": ["Bến Nghé", "Bến Thành"],
    "Quận 3": ["Phường 1", "Phường 2"],
  },
};

class AddressManagerScreen extends StatefulWidget {
  const AddressManagerScreen({super.key});

  @override
  State<AddressManagerScreen> createState() => _AddressManagerScreenState();
}

class _AddressManagerScreenState extends State<AddressManagerScreen> {
  List<Address> addresses = [];

  void _showAddAddressDialog({Address? address, int? index}) async {
    final result = await showDialog<Address>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: AddressFormScreen(address: address),
      ),
    );
    if (result is Address) {
      setState(() {
        if (index != null) {
          addresses[index] = result;
        } else {
          addresses.add(result);
        }
      });
    }
  }

  void _deleteAddress(int idx) {
    setState(() {
      addresses.removeAt(idx);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'My Addresses',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              icon: const Icon(Icons.add_location_alt, color: Color(0xFF6236FF)),
              tooltip: "Add New Address",
              onPressed: () => _showAddAddressDialog(),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
          child: addresses.isEmpty
              ? const Center(child: Text('No address yet'))
              : ListView.separated(
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, idx) {
              final a = addresses[idx];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 3),
                      Text(a.phone, style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 8),
                      Text(
                        "${a.detail}, ${a.ward}, ${a.district}, ${a.province}",
                        style: const TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      if (a.lat != null && a.lng != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            "Location: (${a.lat!.toStringAsFixed(5)}, ${a.lng!.toStringAsFixed(5)})",
                            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF6236FF)),
                            tooltip: "Edit",
                            onPressed: () => _showAddAddressDialog(address: a, index: idx),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            tooltip: "Delete",
                            onPressed: () => _deleteAddress(idx),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: MediaQuery.of(context).size.width > 500
          ? null
          : FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFFFFFF),
        label: const Text('Add New Address'),
        icon: const Icon(Icons.add_location_alt),
        onPressed: () => _showAddAddressDialog(),
      ),
    );
  }
}

class AddressFormScreen extends StatefulWidget {
  final Address? address;
  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();

  String? _province;
  String? _district;
  String? _ward;

  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    if (a != null) {
      _nameCtrl.text = a.name;
      _phoneCtrl.text = a.phone;
      _province = a.province;
      _district = a.district;
      _ward = a.ward;
      _detailCtrl.text = a.detail;
      _lat = a.lat;
      _lng = a.lng;
    }
  }

  List<String> get districts =>
      _province != null ? provinceData[_province!]!.keys.toList() : [];

  List<String> get wards =>
      (_province != null && _district != null)
          ? provinceData[_province!]![_district!]!
          : [];

  void _pickOnMap() async {
    final result = await showDialog<Map<String, double>?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const MapPickerDialog(),
    );
    if (result != null && result['lat'] != null && result['lng'] != null) {
      setState(() {
        _lat = result['lat'];
        _lng = result['lng'];
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final address = Address(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        province: _province!,
        district: _district!,
        ward: _ward!,
        detail: _detailCtrl.text.trim(),
        lat: _lat,
        lng: _lng,
      );
      Navigator.of(context).pop(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Add New Address",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
            const Divider(height: 28, thickness: 1),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLabel('Recipient Name'),
                  _roundedTextField(
                    controller: _nameCtrl,
                    hint: '',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Phone Number'),
                  _roundedTextField(
                    controller: _phoneCtrl,
                    hint: '',
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Required";
                      if (!RegExp(r'^\d{10,11}$').hasMatch(v)) return "Invalid phone";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Province/City'),
                  _roundedDropdown<String>(
                    value: _province,
                    hint: 'Select Province',
                    items: provinceData.keys.toList(),
                    onChanged: (v) {
                      setState(() {
                        _province = v;
                        _district = null;
                        _ward = null;
                      });
                    },
                    validator: (v) => v == null ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('District'),
                  _roundedDropdown<String>(
                    value: _district,
                    hint: 'Select District',
                    items: districts,
                    onChanged: (v) {
                      setState(() {
                        _district = v;
                        _ward = null;
                      });
                    },
                    validator: (v) => v == null ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Ward'),
                  _roundedDropdown<String>(
                    value: _ward,
                    hint: 'Select Ward',
                    items: wards,
                    onChanged: (v) => setState(() => _ward = v),
                    validator: (v) => v == null ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Address Details'),
                  _roundedTextField(
                    controller: _detailCtrl,
                    hint: '',
                    maxLines: 2,
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Location on Map'),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickOnMap,
                        icon: const Icon(Icons.map, color: Color(0xFF6236FF)),
                        label: const Text('Select on Map', style: TextStyle(color: Color(0xFF6236FF))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF6236FF)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          textStyle: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _lat != null && _lng != null
                              ? "(${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)})"
                              : "No location selected",
                          style: TextStyle(
                              color: _lat != null ? Colors.green : Colors.grey[700],
                              fontWeight: FontWeight.w500
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Cancel"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: const BorderSide(color: Colors.black12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFFFF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Save Address", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 2),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
  );

  Widget _roundedTextField({
    required TextEditingController controller,
    required String hint,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF6236FF), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
      );

  Widget _roundedDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required FormFieldValidator<T>? validator,
  }) =>
      DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF6236FF), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        items: items
            .map((e) => DropdownMenuItem<T>(
          value: e,
          child: Text(e.toString()),
        ))
            .toList(),
        onChanged: onChanged,
        validator: validator,
      );
}

// ---------- Map Picker Dialog styled like image 4 ----------
class MapPickerDialog extends StatefulWidget {
  const MapPickerDialog({super.key});

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  double _lat = 21.0285;
  double _lng = 105.8542;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 385,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Select Location on Map",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
            const Divider(height: 20, thickness: 1),
            // Map Container (fake)
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFE7EAF1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E2E7)),
              ),
              child: const Center(
                child: Text(
                  "Map would be displayed here",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: "Search for a location...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF6236FF), width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size(80, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  ),
                  onPressed: () {
                    // Giả lập: không thực hiện search thật
                  },
                  child: const Text("Search"),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop({'lat': _lat, 'lng': _lng});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "Confirm Location",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}