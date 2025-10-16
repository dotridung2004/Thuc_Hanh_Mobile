import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import 'add_edit_order_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết Đơn hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushReplacement( // Dùng pushReplacement để không quay lại màn hình chi tiết cũ
                MaterialPageRoute(builder: (ctx) => AddEditOrderScreen(order: order)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, order.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoCard('Mã đơn hàng', order.id, Icons.vpn_key),
          _buildInfoCard('Tên khách hàng', order.customerName, Icons.person),
          _buildInfoCard('Số điện thoại', order.phoneNumber, Icons.phone),
          _buildInfoCard('Địa chỉ giao hàng', order.shippingAddress, Icons.location_on),
          if (order.notes != null && order.notes!.isNotEmpty)
            _buildInfoCard('Ghi chú', order.notes!, Icons.notes),
          _buildInfoCard(
            'Ngày giao dự kiến',
            DateFormat('dd/MM/yyyy').format(order.deliveryDate),
            Icons.calendar_today,
          ),
          _buildInfoCard('Thanh toán', order.paymentMethod, Icons.payment),
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Danh sách sản phẩm:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...order.products.map(
                        (p) => ListTile(
                      leading: const Icon(Icons.shopping_bag, color: Colors.deepPurple),
                      title: Text(p.name),
                      trailing: Text('${p.price.toStringAsFixed(2)} \$'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              Navigator.of(ctx).pop(); // Đóng dialog
              Navigator.of(context).pop(); // Quay về danh sách
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}