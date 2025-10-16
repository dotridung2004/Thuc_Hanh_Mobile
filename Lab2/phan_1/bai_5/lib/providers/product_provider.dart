import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  // Controllers và state cho bộ lọc
  final TextEditingController fromPriceController = TextEditingController();
  final TextEditingController toPriceController = TextEditingController();
  Set<String> _selectedCategories = {};
  String _selectedSortBy = 'Mới nhất';

  // Dữ liệu giả để demo
  ProductProvider() {
    _generateMockData();
    _filteredProducts = List.from(_allProducts);
  }

  // Getters
  List<Product> get filteredProducts => _filteredProducts;
  Set<String> get selectedCategories => _selectedCategories;
  String get selectedSortBy => _selectedSortBy;
  List<String> get allCategories => _allProducts.map((p) => p.category).toSet().toList();
  final List<String> sortOptions = ['Giá tăng', 'Giá giảm', 'Mới nhất'];

  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }

  void setSortBy(String option) {
    _selectedSortBy = option;
    notifyListeners();
  }

  void applyFilters() {
    List<Product> results = List.from(_allProducts);

    // 1. Lọc theo giá
    double? fromPrice = double.tryParse(fromPriceController.text);
    double? toPrice = double.tryParse(toPriceController.text);

    if (fromPrice != null) {
      results = results.where((p) => p.price >= fromPrice).toList();
    }
    if (toPrice != null) {
      results = results.where((p) => p.price <= toPrice).toList();
    }

    // 2. Lọc theo danh mục
    if (_selectedCategories.isNotEmpty) {
      results = results.where((p) => _selectedCategories.contains(p.category)).toList();
    }

    // 3. Sắp xếp
    switch (_selectedSortBy) {
      case 'Giá tăng':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Giá giảm':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Mới nhất':
        results.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
    }

    _filteredProducts = results;
    notifyListeners();
  }

  void resetFilters() {
    fromPriceController.clear();
    toPriceController.clear();
    _selectedCategories.clear();
    _selectedSortBy = 'Mới nhất';
    _filteredProducts = List.from(_allProducts);
    notifyListeners();
  }

  // Hàm tạo dữ liệu mẫu
  void _generateMockData() {
    _allProducts = [
      Product(id: '1', name: 'iPhone 15 Pro Max', price: 1299.99, category: 'Điện thoại', imageUrl: 'https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/iphone-15-pro-finish-select-202309-6-7inch-naturaltitanium?wid=5120&hei=2880&fmt=p-jpg&qlt=80&.v=1692845702708', dateAdded: DateTime.now().subtract(const Duration(days: 1))),
      Product(id: '2', name: 'Samsung Galaxy S24 Ultra', price: 1199.00, category: 'Điện thoại', imageUrl: 'https://images.samsung.com/is/image/samsung/p6pim/vn/2401/gallery/vn-galaxy-s24-ultra-s928-sm-s928bztqxxv-539572971?650_519_PNG', dateAdded: DateTime.now().subtract(const Duration(days: 5))),
      Product(id: '3', name: 'Laptop Dell XPS 15', price: 1899.50, category: 'Laptop', imageUrl: 'https://i.dell.com/is/image/DellContent/content/dam/ss2/product-images/dell-client-products/notebooks/xps-notebooks/xps-15-9530/media-gallery/touch-black/notebook-xps-15-9530-t-black-gallery-1.psd?fmt=png-alpha&pscan=auto&scl=1&hei=402&wid=666&qlt=100,1&resMode=sharp2&size=666,402&chrss=full', dateAdded: DateTime.now()),
      Product(id: '4', name: 'MacBook Air M3', price: 999.00, category: 'Laptop', imageUrl: 'https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/mba13-midnight-select-202402?wid=904&hei=840&fmt=jpeg&qlt=90&.v=1708367688034', dateAdded: DateTime.now().subtract(const Duration(days: 10))),
      Product(id: '5', name: 'Sony WH-1000XM5', price: 349.99, category: 'Tai nghe', imageUrl: 'https://www.sony.com.vn/image/5d02da5df552836db894cead8a68f5f3?fmt=pjpeg&wid=330&bgcolor=FFFFFF&bgc=FFFFFF', dateAdded: DateTime.now().subtract(const Duration(days: 2))),
      Product(id: '6', name: 'Áo thun Cotton', price: 19.99, category: 'Thời trang', imageUrl: 'https://canifa.s3.amazonaws.com/media/catalog/product/8/t/8ts22w001-sb058-2.jpg', dateAdded: DateTime.now().subtract(const Duration(days: 30))),
    ];
  }
}