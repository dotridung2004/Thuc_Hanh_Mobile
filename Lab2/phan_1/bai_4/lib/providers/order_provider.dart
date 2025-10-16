import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  static const _ordersKey = 'orders';

  List<Order> get orders => [..._orders];

  Future<void> addOrder(Order order) async {
    _orders.add(order);
    await _saveOrders();
    notifyListeners();
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(_orders.map((order) => order.toJson()).toList());
    await prefs.setString(_ordersKey, data);
  }

  Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_ordersKey)) return;
    final extractedData = json.decode(prefs.getString(_ordersKey)!) as List<dynamic>;
    _orders = extractedData.map((item) => Order.fromJson(item)).toList();
    notifyListeners();
  }
}