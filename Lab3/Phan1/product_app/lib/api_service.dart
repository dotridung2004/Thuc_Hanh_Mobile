import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product.dart';
import 'category.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Lấy danh sách sản phẩm
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Lấy danh sách danh mục
  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Category.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Tạo sản phẩm
  Future<void> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Lỗi khi tạo sản phẩm');
    }
  }

  // Xóa sản phẩm
  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));

    if (response.statusCode != 204) {
      throw Exception('Xóa sản phẩm thất bại');
    }
  }
}
