class Product {
  final String id;
  String name;
  double price;
  String description;
  List<String> imagePaths; // Lưu đường dẫn file ảnh đã lưu trong máy
  String category;
  bool hasDiscount;
  DateTime? promotionDate;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imagePaths,
    required this.category,
    this.hasDiscount = false,
    this.promotionDate,
  });

  // Chuyển đổi từ Map (JSON) sang Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      imagePaths: List<String>.from(json['imagePaths']),
      category: json['category'],
      hasDiscount: json['hasDiscount'],
      promotionDate: json['promotionDate'] != null
          ? DateTime.parse(json['promotionDate'])
          : null,
    );
  }

  // Chuyển đổi từ Product sang Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imagePaths': imagePaths,
      'category': category,
      'hasDiscount': hasDiscount,
      'promotionDate': promotionDate?.toIso8601String(),
    };
  }
}