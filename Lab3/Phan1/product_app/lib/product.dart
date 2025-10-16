import 'category.dart';

class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final Category category;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      category: Category.fromJson(json['category']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category_id': category.id, // gửi category_id khi tạo product
    };
  }
}
