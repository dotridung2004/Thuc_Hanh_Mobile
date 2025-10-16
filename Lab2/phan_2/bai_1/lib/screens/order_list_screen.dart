import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import 'add_edit_order_screen.dart';
import 'order_details_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Provider.of<OrderProvider>(context, listen: false).loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Đơn hàng'),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Tìm theo tên khách hàng',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Danh sách đơn hàng
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (ctx, orderProvider, child) {
                final orders = orderProvider.orders
                    .where((order) => order.customerName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                    .toList();

                if (orders.isEmpty) {
                  return child!; // Hiển thị nội dung rỗng
                }

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (ctx, i) {
                    final order = orders[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text((i + 1).toString()),
                        ),
                        title: Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Ngày giao: ${DateFormat('dd/MM/yyyy').format(order.deliveryDate)}\nThanh toán: ${order.paymentMethod}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(context, order.id),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => OrderDetailsScreen(order: order),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              child: const Center(
                child: Text(
                  'Không có đơn hàng nào.\nHãy tạo một đơn hàng mới!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const AddEditOrderScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa đơn hàng này không?'),
        actions: [
          TextButton(
            child: const Text('Không'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Có'),
            onPressed: () {
              Provider.of<OrderProvider>(context, listen: false).deleteOrder(orderId);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}