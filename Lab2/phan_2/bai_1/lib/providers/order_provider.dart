import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  static const _ordersKey = 'orders_data';

  // Dữ liệu giả cho sản phẩm
  final List<Product> availableProducts = [
    Product(id: 'p1', name: 'iPhone 15 Pro Max', price: 1299.99),
    Product(id: 'p2', name: 'MacBook Air M3', price: 999.00),
    Product(id: 'p3', name: 'Sony WH-1000XM5', price: 349.99),
    Product(id: 'p4', name: 'Dell XPS 15', price: 1899.50),
    Product(id: 'p5', name: 'Áo thun Cotton', price: 19.99),
  ];

  List<Order> get orders => [..._orders];

  Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_ordersKey)) {
      return;
    }
    try {
      final extractedData = json.decode(prefs.getString(_ordersKey)!) as List<dynamic>;
      _orders = extractedData.map((item) => Order.fromJson(item)).toList();
      notifyListeners();
    } catch (error) {
      // Xử lý lỗi nếu dữ liệu không hợp lệ
      print("Lỗi khi tải đơn hàng: $error");
    }
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(_orders.map((order) => order.toJson()).toList());
    await prefs.setString(_ordersKey, data);
  }

  Future<void> addOrder(Order order) async {
    const uuid = Uuid();
    final newOrder = Order(
      id: uuid.v4(),
      customerName: order.customerName,
      phoneNumber: order.phoneNumber,
      shippingAddress: order.shippingAddress,
      notes: order.notes,
      deliveryDate: order.deliveryDate,
      paymentMethod: order.paymentMethod,
      products: order.products,
    );
    _orders.add(newOrder);
    await _saveOrders();
    notifyListeners();
  }

  Future<void> updateOrder(String id, Order newOrder) async {
    final orderIndex = _orders.indexWhere((order) => order.id == id);
    if (orderIndex >= 0) {
      _orders[orderIndex] = newOrder;
      await _saveOrders();
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String id) async {
    _orders.removeWhere((order) => order.id == id);
    await _saveOrders();
    notifyListeners();
  }
}