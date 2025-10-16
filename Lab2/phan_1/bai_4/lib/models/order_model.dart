class Order {
  final String id;
  final DateTime orderDate;
  final String status;

  // Customer Info
  final String customerName;
  final String email;
  final String phoneNumber;

  // Shipping Address
  final String recipientName;
  final String shippingPhone;
  final String province;
  final String district;
  final String ward;
  final String addressDetails;

  // Payment
  final String paymentMethod;
  final String? orderNotes;

  Order({
    required this.id,
    required this.orderDate,
    this.status = 'Processing',
    required this.customerName,
    required this.email,
    required this.phoneNumber,
    required this.recipientName,
    required this.shippingPhone,
    required this.province,
    required this.district,
    required this.ward,
    required this.addressDetails,
    required this.paymentMethod,
    this.orderNotes,
  });

  // Functions to convert to/from JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'orderDate': orderDate.toIso8601String(),
    'status': status,
    'customerName': customerName,
    'email': email,
    'phoneNumber': phoneNumber,
    'recipientName': recipientName,
    'shippingPhone': shippingPhone,
    'province': province,
    'district': district,
    'ward': ward,
    'addressDetails': addressDetails,
    'paymentMethod': paymentMethod,
    'orderNotes': orderNotes,
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'],
    orderDate: DateTime.parse(json['orderDate']),
    status: json['status'],
    customerName: json['customerName'],
    email: json['email'],
    phoneNumber: json['phoneNumber'],
    recipientName: json['recipientName'],
    shippingPhone: json['shippingPhone'],
    province: json['province'],
    district: json['district'],
    ward: json['ward'],
    addressDetails: json['addressDetails'],
    paymentMethod: json['paymentMethod'],
    orderNotes: json['orderNotes'],
  );
}