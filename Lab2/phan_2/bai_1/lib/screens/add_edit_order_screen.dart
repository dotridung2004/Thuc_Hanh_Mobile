import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../providers/order_provider.dart';

class AddEditOrderScreen extends StatefulWidget {
  final Order? order;

  const AddEditOrderScreen({super.key, this.order});

  @override
  _AddEditOrderScreenState createState() => _AddEditOrderScreenState();
}

class _AddEditOrderScreenState extends State<AddEditOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  late TextEditingController _dateController;

  // State variables
  DateTime _deliveryDate = DateTime.now();
  String _paymentMethod = 'Tiền mặt';
  List<Product> _selectedProducts = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị nếu đang ở chế độ chỉnh sửa
    _nameController = TextEditingController(text: widget.order?.customerName);
    _phoneController = TextEditingController(text: widget.order?.phoneNumber);
    _addressController = TextEditingController(text: widget.order?.shippingAddress);
    _notesController = TextEditingController(text: widget.order?.notes);
    if (widget.order != null) {
      _deliveryDate = widget.order!.deliveryDate;
      _paymentMethod = widget.order!.paymentMethod;
      _selectedProducts = List.from(widget.order!.products);
    }
    _dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(_deliveryDate)
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _deliveryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _deliveryDate) {
      setState(() {
        _deliveryDate = pickedDate;
        _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  void _showProductSelectionDialog() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) {
        // Sử dụng một stateful builder để quản lý trạng thái bên trong dialog
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Chọn sản phẩm'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: orderProvider.availableProducts.length,
                  itemBuilder: (context, index) {
                    final product = orderProvider.availableProducts[index];
                    final isSelected = _selectedProducts.any((p) => p.id == product.id);
                    return CheckboxListTile(
                      title: Text(product.name),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            _selectedProducts.add(product);
                          } else {
                            _selectedProducts.removeWhere((p) => p.id == product.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Xong'),
                  onPressed: () {
                    setState(() {}); // Cập nhật lại UI chính
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveForm() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một sản phẩm!')),
      );
      return;
    }

    _formKey.currentState!.save();
    final orderData = Order(
      id: widget.order?.id ?? '', // ID cũ nếu sửa, rỗng nếu tạo mới
      customerName: _nameController.text,
      phoneNumber: _phoneController.text,
      shippingAddress: _addressController.text,
      notes: _notesController.text,
      deliveryDate: _deliveryDate,
      paymentMethod: _paymentMethod,
      products: _selectedProducts,
    );

    final provider = Provider.of<OrderProvider>(context, listen: false);
    if (widget.order == null) {
      provider.addOrder(orderData);
    } else {
      provider.updateOrder(widget.order!.id, orderData);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'Tạo Đơn Hàng Mới' : 'Chỉnh Sửa Đơn Hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Thông tin khách hàng'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên khách hàng'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value!.isEmpty) return 'Vui lòng nhập số điện thoại';
                  if (value.length != 10) return 'Số điện thoại phải có 10 chữ số';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Địa chỉ giao hàng'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Ghi chú (tùy chọn)'),
                maxLines: 2,
              ),
              const Divider(height: 32),
              _buildSectionTitle('Thông tin đơn hàng'),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Ngày giao dự kiến',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _selectDate,
              ),
              const SizedBox(height: 12),
              const Text('Phương thức thanh toán:', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Tiền mặt'),
                      value: 'Tiền mặt',
                      groupValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Chuyển khoản'),
                      value: 'Chuyển khoản',
                      groupValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Sản phẩm đã chọn:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _selectedProducts.isEmpty
                      ? [const Text('Chưa chọn sản phẩm nào')]
                      : _selectedProducts.map((p) => Chip(label: Text(p.name))).toList(),
                ),
              ),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Thêm / Sửa sản phẩm'),
                  onPressed: _showProductSelectionDialog,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Lưu Đơn Hàng'),
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor),
      ),
    );
  }
}