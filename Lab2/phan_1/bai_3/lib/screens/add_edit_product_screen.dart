import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  _AddEditProductScreenState createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _promoDateController;

  List<String> _imagePaths = []; // Lưu đường dẫn ảnh đã tồn tại
  List<File> _newImageFiles = []; // Lưu file ảnh mới chọn
  String? _selectedCategory;
  bool _hasDiscount = false;
  DateTime? _promotionDate;

  final List<String> _categories = ['Electronics', 'Clothing', 'Books', 'Home Goods'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _priceController = TextEditingController(text: widget.product?.price.toString());
    _descriptionController = TextEditingController(text: widget.product?.description);
    _selectedCategory = widget.product?.category;
    _hasDiscount = widget.product?.hasDiscount ?? false;
    _promotionDate = widget.product?.promotionDate;
    _imagePaths = widget.product?.imagePaths ?? [];

    _promoDateController = TextEditingController(
        text: _promotionDate != null ? DateFormat('dd/MM/yyyy').format(_promotionDate!) : ''
    );
  }

  Future<void> _pickImages() async {
    final imagePicker = ImagePicker();
    final pickedFiles = await imagePicker.pickMultiImage();
    setState(() {
      _newImageFiles.addAll(pickedFiles.map((file) => File(file.path)).toList());
    });
  }

  Future<void> _takePhoto() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _newImageFiles.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _selectPromoDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _promotionDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _promotionDate = pickedDate;
        _promoDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final productData = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text,
        price: double.parse(_priceController.text),
        description: _descriptionController.text,
        imagePaths: _imagePaths, // Chỉ truyền các ảnh đã có
        category: _selectedCategory!,
        hasDiscount: _hasDiscount,
        promotionDate: _hasDiscount ? _promotionDate : null,
      );

      final provider = Provider.of<ProductProvider>(context, listen: false);
      if (widget.product == null) {
        provider.addProduct(productData, _newImageFiles);
      } else {
        provider.updateProduct(widget.product!.id, productData, _newImageFiles);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
            actions: [
              TextButton.icon(
                onPressed: _saveForm,
                icon: const Icon(Icons.save_alt_rounded, color: Colors.white),
                label: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(label: 'Product Name', controller: _nameController),
                    _buildTextField(label: 'Price', controller: _priceController, keyboardType: TextInputType.numberWithOptions(decimal: true), prefixText: '\$ '),
                    _buildTextField(label: 'Description', controller: _descriptionController, maxLines: 4),
                    _buildImagePicker(),
                    _buildDropdown(),
                    _buildDiscountSwitch(),
                    if (_hasDiscount) _buildPromoDatePicker(),
                    const SizedBox(height: 30),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Các widget con để code gọn gàng hơn
  Widget _buildTextField({required String label, required TextEditingController controller, int maxLines = 1, TextInputType? keyboardType, String? prefixText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              prefixText: prefixText,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              if (keyboardType != null && keyboardType.toString().contains('number') && double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Product Images', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Hiển thị ảnh đã có
            ..._imagePaths.map((path) => _buildImageThumbnail(File(path), () {
              setState(() => _imagePaths.remove(path));
            })),
            // Hiển thị ảnh mới chọn
            ..._newImageFiles.map((file) => _buildImageThumbnail(file, () {
              setState(() => _newImageFiles.remove(file));
            })),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.photo_library),
              label: const Text('Upload Images'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black87),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildImageThumbnail(File imageFile, VoidCallback onRemove) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(imageFile, width: 80, height: 80, fit: BoxFit.cover),
        ),
        Positioned(
          top: -10, right: -10,
          child: IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select a category'),
            value: _selectedCategory,
            items: _categories.map((String category) {
              return DropdownMenuItem<String>(value: category, child: Text(category));
            }).toList(),
            onChanged: (newValue) {
              setState(() => _selectedCategory = newValue);
            },
            validator: (value) => value == null ? 'Please select a category' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSwitch() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Discount Offer'),
      value: _hasDiscount,
      onChanged: (bool value) {
        setState(() => _hasDiscount = value);
      },
    );
  }

  Widget _buildPromoDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _promoDateController,
        readOnly: true,
        decoration: const InputDecoration(
          labelText: 'Promotion End Date',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        onTap: _selectPromoDate,
        validator: (value) {
          if (_hasDiscount && (value == null || value.isEmpty)) {
            return 'Please select a promotion date';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _saveForm,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
          child: const Text('Save Product'),
        ),
      ],
    );
  }
}