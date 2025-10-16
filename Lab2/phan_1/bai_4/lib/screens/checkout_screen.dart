import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;

  // Keys for form validation
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  // Step 1: Customer Info Controllers
  final _customerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Step 2: Shipping Address Controllers
  final _recipientNameController = TextEditingController();
  final _shippingPhoneController = TextEditingController();
  final _addressDetailsController = TextEditingController();
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;

  // Step 3: Payment Controllers
  final _notesController = TextEditingController();
  String _paymentMethod = 'Tiền mặt';

  // Mock data for dropdowns
  final List<String> _provinces = ['Hà Nội', 'TP. Hồ Chí Minh', 'Đà Nẵng'];
  final Map<String, List<String>> _districts = {
    'Hà Nội': ['Ba Đình', 'Hoàn Kiếm', 'Hai Bà Trưng'],
    'TP. Hồ Chí Minh': ['Quận 1', 'Quận 3', 'Bình Thạnh'],
    'Đà Nẵng': ['Hải Châu', 'Sơn Trà', 'Ngũ Hành Sơn'],
  };
  final Map<String, List<String>> _wards = {
    'Hoàn Kiếm': ['Hàng Bạc', 'Hàng Buồm'], 'Quận 1': ['Bến Nghé', 'Tân Định'],
    'Hải Châu': ['Bình Hiên', 'Thanh Bình'], 'Ba Đình': ['Phúc Xá', 'Trúc Bạch'],
  };

  @override
  void dispose() {
    _customerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _recipientNameController.dispose();
    _shippingPhoneController.dispose();
    _addressDetailsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitOrder() {
    // Validate the last step before submitting
    if (!_step3Key.currentState!.validate()) {
      return;
    }

    final newOrder = Order(
      id: const Uuid().v4(),
      orderDate: DateTime.now(),
      customerName: _customerNameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      recipientName: _recipientNameController.text,
      shippingPhone: _shippingPhoneController.text,
      province: _selectedProvince!,
      district: _selectedDistrict!,
      ward: _selectedWard!,
      addressDetails: _addressDetailsController.text,
      paymentMethod: _paymentMethod,
      orderNotes: _notesController.text,
    );

    Provider.of<OrderProvider>(context, listen: false).addOrder(newOrder);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => OrderSuccessScreen(order: newOrder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          bool isLastStep = _currentStep == getSteps().length - 1;

          if (isLastStep) {
            _submitOrder();
          } else {
            // Validate current step before proceeding
            final currentFormKey = [_step1Key, _step2Key, _step3Key][_currentStep];
            if (currentFormKey.currentState!.validate()) {
              setState(() => _currentStep += 1);
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        onStepTapped: (step) => setState(() => _currentStep = step),
        steps: getSteps(),
        controlsBuilder: (context, details) {
          bool isLastStep = _currentStep == getSteps().length - 1;
          return Container(
            margin: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(isLastStep ? 'Xác nhận đơn' : 'Tiếp theo'),
                  ),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  Expanded(
                    child: TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Quay lại'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Step> getSteps() => [
    Step(
      title: const Text('Thông tin khách hàng'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _step1Key,
        child: Column(
          children: [
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
              validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value!.isEmpty || !value.contains('@') ? 'Email không hợp lệ' : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
            ),
          ],
        ),
      ),
    ),
    Step(
      title: const Text('Địa chỉ giao hàng'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _step2Key,
        child: Column(
          children: [
            TextFormField(
                controller: _recipientNameController,
                decoration: const InputDecoration(labelText: 'Tên người nhận'),
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null
            ),
            TextFormField(
                controller: _shippingPhoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại người nhận'),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null
            ),
            _buildDropdown(hint: 'Chọn Tỉnh/Thành phố', value: _selectedProvince, items: _provinces, onChanged: (val) {
              setState(() { _selectedProvince = val; _selectedDistrict = null; _selectedWard = null; });
            }),
            _buildDropdown(hint: 'Chọn Quận/Huyện', value: _selectedDistrict, items: _districts[_selectedProvince] ?? [], onChanged: (val) {
              setState(() { _selectedDistrict = val; _selectedWard = null; });
            }),
            _buildDropdown(hint: 'Chọn Phường/Xã', value: _selectedWard, items: _wards[_selectedDistrict] ?? [], onChanged: (val) {
              setState(() => _selectedWard = val);
            }),
            TextFormField(
                controller: _addressDetailsController,
                decoration: const InputDecoration(labelText: 'Địa chỉ chi tiết (số nhà, tên đường...)'),
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null
            ),
          ],
        ),
      ),
    ),
    Step(
      title: const Text('Thanh toán & Xác nhận'),
      isActive: _currentStep >= 2,
      content: Form(
        key: _step3Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chọn phương thức thanh toán:', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<String>(
              title: const Text('Thanh toán khi nhận hàng (Tiền mặt)'),
              value: 'Tiền mặt',
              groupValue: _paymentMethod,
              onChanged: (val) => setState(() => _paymentMethod = val!),
            ),
            RadioListTile<String>(
              title: const Text('Thanh toán qua thẻ'),
              value: 'Thẻ',
              groupValue: _paymentMethod,
              onChanged: (val) => setState(() => _paymentMethod = val!),
            ),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Ghi chú đơn hàng (tùy chọn)'),
              maxLines: 3,
            ),
          ],
        ),
      ),
    ),
  ];

  Widget _buildDropdown({required String hint, String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      hint: Text(hint),
      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 10)),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: items.isEmpty ? null : onChanged,
      validator: (val) => val == null ? 'Vui lòng chọn' : null,
    );
  }
}