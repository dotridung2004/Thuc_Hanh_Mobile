import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';

class OrderSuccessScreen extends StatelessWidget {
  final Order order;
  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt hàng thành công'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Quay về màn hình gốc
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Center(
            child: Icon(Icons.check_circle, color: Colors.green, size: 80),
          ),
          const SizedBox(height: 16),
          const Text(
            'Cảm ơn bạn đã đặt hàng!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Mã đơn hàng: ${order.id}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Divider(height: 30),

          _buildSectionTitle('Thông tin đơn hàng'),
          _buildInfoRow('Ngày đặt:', DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate)),
          _buildInfoRow('Trạng thái:', order.status),
          _buildInfoRow('Phương thức thanh toán:', order.paymentMethod),
          if(order.orderNotes != null && order.orderNotes!.isNotEmpty)
            _buildInfoRow('Ghi chú:', order.orderNotes!),

          const Divider(height: 30),

          _buildSectionTitle('Địa chỉ giao hàng'),
          _buildInfoRow('Người nhận:', order.recipientName),
          _buildInfoRow('Số điện thoại:', order.shippingPhone),
          _buildInfoRow('Địa chỉ:', '${order.addressDetails}, ${order.ward}, ${order.district}, ${order.province}'),

          const Divider(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              child: const Text('Tiếp tục mua sắm'),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}