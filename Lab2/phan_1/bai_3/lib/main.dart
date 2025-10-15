import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'product_db.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProductListScreen(),
  ));
}

const categories = [
  "Electronics",
  "Fashion",
  "Home",
  "Beauty",
  "Books",
];

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  final dbHelper = ProductDatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    products = await dbHelper.getAllProducts();
    setState(() {});
  }

  void _addOrEditProduct({Product? product}) async {
    final result = await showDialog<Product>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ProductFormScreen(product: product),
      ),
    );
    if (result is Product) {
      if (result.id == null) {
        await dbHelper.insertProduct(result);
      } else {
        await dbHelper.updateProduct(result);
      }
      _loadProducts();
    }
  }

  void _viewProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ProductDetailScreen(product: product),
      ),
    );
  }

  void _deleteProduct(Product p) async {
    if (p.id != null) {
      await dbHelper.deleteProduct(p.id!);
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Product List',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              icon: const Icon(Icons.add_box_rounded, color: Color(0xFF6236FF)),
              tooltip: "Add Product",
              onPressed: () => _addOrEditProduct(),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
          child: products.isEmpty
              ? const Center(child: Text('No products yet'))
              : ListView.separated(
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, idx) {
              final p = products[idx];
              final firstImg = p.imagePaths.split(';').where((e) => e.isNotEmpty).toList();
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  leading: firstImg.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(firstImg[0]),
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, obj, st) =>
                      const Icon(Icons.image_not_supported, size: 45),
                    ),
                  )
                      : Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: Colors.grey, size: 36),
                  ),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF6236FF))),
                      Text(p.category, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye, color: Color(0xFF6236FF)),
                        onPressed: () => _viewProduct(p),
                        tooltip: "View details",
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _addOrEditProduct(product: p),
                        tooltip: "Edit",
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(p),
                        tooltip: "Delete",
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: MediaQuery.of(context).size.width > 600
          ? null
          : FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFFFFFF),
        label: const Text('Add Product'),
        icon: const Icon(Icons.add_box_rounded),
        onPressed: () => _addOrEditProduct(),
      ),
    );
  }
}

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  List<String> _imagePaths = [];
  String? _category;
  bool _discount = false;
  DateTime? _discountTime;
  int? _productId;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _productId = p.id;
      _nameCtrl.text = p.name;
      _priceCtrl.text = p.price.toString();
      _descCtrl.text = p.description;
      _imagePaths = p.imagePaths.split(';').where((e) => e.isNotEmpty).toList();
      _category = p.category;
      _discount = p.hasDiscount;
      _discountTime = p.discountTime != null ? DateTime.tryParse(p.discountTime!) : null;
    }
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked != null && picked.isNotEmpty) {
      setState(() {
        _imagePaths.addAll(picked.map((e) => e.path));
      });
    }
  }

  Future<void> _takePhoto() async {
    final img = await _picker.pickImage(source: ImageSource.camera);
    if (img != null) {
      setState(() {
        _imagePaths.add(img.path);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  void _pickDiscountTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _discountTime ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
    );
    if (pickedDate == null) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_discountTime ?? now),
    );
    if (pickedTime == null) return;
    setState(() {
      _discountTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: _productId,
        name: _nameCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text.replaceAll(',', '')) ?? 0.0,
        description: _descCtrl.text.trim(),
        imagePaths: _imagePaths.join(';'),
        category: _category!,
        hasDiscount: _discount,
        discountTime: _discount && _discountTime != null ? _discountTime!.toIso8601String() : null,
      );
      Navigator.of(context).pop(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Add/Edit Product",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.save_as_outlined, color: Color(0xFF6236FF)),
                  tooltip: "Save",
                  onPressed: _save,
                )
              ],
            ),
            const Divider(height: 26, thickness: 1),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLabel("Product Name"),
                  _roundedTextField(
                    controller: _nameCtrl,
                    hint: '',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildLabel("Price"),
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Required";
                      final n = num.tryParse(v.replaceAll(',', ''));
                      if (n == null) return "Invalid price";
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixText: "\$ ",
                      hintText: "0.00",
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
                  ),
                  const SizedBox(height: 14),
                  _buildLabel("Description"),
                  _roundedTextField(
                    controller: _descCtrl,
                    hint: "",
                    maxLines: 3,
                    validator: (v) => null,
                  ),
                  const SizedBox(height: 14),
                  _buildLabel("Product Images"),
                  _buildImagePicker(context),
                  const SizedBox(height: 14),
                  _buildLabel("Category"),
                  _roundedDropdown<String>(
                    value: _category,
                    hint: 'Select a category',
                    items: categories,
                    onChanged: (v) => setState(() => _category = v),
                    validator: (v) => v == null ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Discount Offer", style: TextStyle(fontWeight: FontWeight.w600)),
                      Switch(
                        value: _discount,
                        activeColor: const Color(0xFF6236FF),
                        onChanged: (v) => setState(() => _discount = v),
                      ),
                    ],
                  ),
                  if (_discount)
                    InkWell(
                      onTap: _pickDiscountTime,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 20, color: Color(0xFF6236FF)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _discountTime != null
                                    ? "${_discountTime!.day.toString().padLeft(2, '0')}/"
                                    "${_discountTime!.month.toString().padLeft(2, '0')}/"
                                    "${_discountTime!.year} "
                                    "${_discountTime!.hour.toString().padLeft(2, '0')}:"
                                    "${_discountTime!.minute.toString().padLeft(2, '0')}"
                                    : "Select discount time",
                                style: TextStyle(
                                  color: _discountTime != null
                                      ? Colors.black87
                                      : Colors.black38,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                          child: const Text("Save Product", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
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

  Widget _buildImagePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_imagePaths.isNotEmpty)
          SizedBox(
            height: 65,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _imagePaths.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_imagePaths[idx]),
                        width: 65,
                        height: 65,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, obj, st) => Container(
                          width: 65,
                          height: 65,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 36),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeImage(idx),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.close, size: 18, color: Colors.red),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.photo_library, color: Color(0xFF6236FF)),
              label: const Text('Upload Images', style: TextStyle(color: Color(0xFF6236FF))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF6236FF)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt, color: Color(0xFF6236FF)),
              label: const Text('Take Photo', style: TextStyle(color: Color(0xFF6236FF))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF6236FF)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final imgs = product.imagePaths.split(';').where((e) => e.isNotEmpty).toList();
    return Container(
      width: 400,
      padding: const EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Product Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),
            if (imgs.isNotEmpty)
              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imgs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(imgs[idx]),
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, obj, st) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 36),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Name: ${product.name}", style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Category: ${product.category}"),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Price: \$${product.price.toStringAsFixed(2)}"),
            ),
            if (product.hasDiscount && product.discountTime != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Discount to: ${DateTime.parse(product.discountTime!).day.toString().padLeft(2, '0')}/"
                      "${DateTime.parse(product.discountTime!).month.toString().padLeft(2, '0')}/"
                      "${DateTime.parse(product.discountTime!).year} "
                      "${DateTime.parse(product.discountTime!).hour.toString().padLeft(2, '0')}:"
                      "${DateTime.parse(product.discountTime!).minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 10, bottom: 2),
                child: Text("Description:", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(product.description, style: const TextStyle(fontSize: 15)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}