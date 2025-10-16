import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  static const _productsKey = 'products';

  List<Product> get products => [..._products];

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_productsKey)) {
      return;
    }
    final extractedData = json.decode(prefs.getString(_productsKey)!) as List<dynamic>;
    _products = extractedData.map((item) => Product.fromJson(item)).toList();
    notifyListeners();
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(_products.map((prod) => prod.toJson()).toList());
    await prefs.setString(_productsKey, data);
  }

  Future<List<String>> saveImageFiles(List<File> imageFiles) async {
    final appDir = await getApplicationDocumentsDirectory();
    final savedImagePaths = <String>[];
    for (var imageFile in imageFiles) {
      final fileName = p.basename(imageFile.path);
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      savedImagePaths.add(savedImage.path);
    }
    return savedImagePaths;
  }

  Future<void> addProduct(Product product, List<File> newImageFiles) async {
    final savedImagePaths = await saveImageFiles(newImageFiles);
    const uuid = Uuid();
    final newProduct = Product(
      id: uuid.v4(),
      name: product.name,
      price: product.price,
      description: product.description,
      imagePaths: savedImagePaths,
      category: product.category,
      hasDiscount: product.hasDiscount,
      promotionDate: product.promotionDate,
    );
    _products.add(newProduct);
    await _saveProducts();
    notifyListeners();
  }

  Future<void> updateProduct(String id, Product updatedProduct, List<File> newImageFiles) async {
    final prodIndex = _products.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      // Xóa ảnh cũ không còn được sử dụng
      final oldProduct = _products[prodIndex];
      for (var path in oldProduct.imagePaths) {
        if (!updatedProduct.imagePaths.contains(path)) {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

      // Lưu ảnh mới
      final savedNewImagePaths = await saveImageFiles(newImageFiles);
      updatedProduct.imagePaths.addAll(savedNewImagePaths);

      _products[prodIndex] = updatedProduct;
      await _saveProducts();
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final prodIndex = _products.indexWhere((prod) => prod.id == id);
    final product = _products[prodIndex];

    // Xóa tất cả các file ảnh liên quan
    for (var path in product.imagePaths) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }

    _products.removeAt(prodIndex);
    await _saveProducts();
    notifyListeners();
  }
}