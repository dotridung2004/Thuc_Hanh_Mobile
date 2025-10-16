class Product {
  final String id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});

  // Cần thiết cho việc lưu trữ dưới dạng JSON
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};

  factory Product.fromJson(Map<String, dynamic> json) =>
      Product(id: json['id'], name: json['name'], price: json['price']);
}