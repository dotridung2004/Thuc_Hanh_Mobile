class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl; // Thêm ảnh để hiển thị
  final DateTime dateAdded;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.dateAdded,
  });
}