import 'package:flutter/material.dart';
import 'api_service.dart';
import 'product.dart';
import 'category.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product CRUD',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProductListScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  void loadProducts() {
    setState(() {
      futureProducts = apiService.fetchProducts();
    });
  }

  void _deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa sản phẩm này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await apiService.deleteProduct(id);
        loadProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa sản phẩm thành công')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách sản phẩm')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
          if (result == true) {
            loadProducts();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: FutureBuilder<List<Product>>(
          future: futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Lỗi: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Không có sản phẩm');
            }

            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text(
                    '${p.description ?? ''}\nDanh mục: ${p.category.name}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('\$${p.price}'),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(p.id),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final ApiService apiService = ApiService();

  List<Category> categories = [];
  Category? selectedCategory;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    final data = await apiService.fetchCategories();
    setState(() {
      categories = data;
      if (categories.isNotEmpty) {
        selectedCategory = categories.first;
      }
    });
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate() && selectedCategory != null) {
      try {
        await apiService.createProduct(
          Product(
            id: 0,
            name: _nameController.text,
            description: _descController.text,
            price: double.parse(_priceController.text),
            category: selectedCategory!,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo sản phẩm thành công')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm sản phẩm')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giá'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập giá';
                  if (double.tryParse(value) == null) return 'Giá không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Category>(
                value: selectedCategory,
                items: categories.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Danh mục'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
