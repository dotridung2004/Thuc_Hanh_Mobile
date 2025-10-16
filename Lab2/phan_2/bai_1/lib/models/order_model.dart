import 'product_model.dart';

class Order {
  final String id;
  String customerName;
  String phoneNumber;
  String shippingAddress;
  String? notes;
  DateTime deliveryDate;
  String paymentMethod;
  List<Product> products;

  Order({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.shippingAddress,
    this.notes,
    required this.deliveryDate,
    required this.paymentMethod,
    required this.products,
  });

  // Chuyển đổi từ Order sang Map (JSON) để lưu trữ
  Map<String, dynamic> toJson() => {
    'id': id,
    'customerName': customerName,
    'phoneNumber': phoneNumber,
    'shippingAddress': shippingAddress,
    'notes': notes,
    'deliveryDate': deliveryDate.toIso8601String(),
    'paymentMethod': paymentMethod,
    'products': products.map((p) => p.toJson()).toList(),
  };

  // Chuyển đổi từ Map (JSON) về lại Order
  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'],
    customerName: json['customerName'],
    phoneNumber: json['phoneNumber'],
    shippingAddress: json['shippingAddress'],
    notes: json['notes'],
    deliveryDate: DateTime.parse(json['deliveryDate']),
    paymentMethod: json['paymentMethod'],
    products: (json['products'] as List)
        .map((p) => Product.fromJson(p))
        .toList(),
  );
}