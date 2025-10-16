import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import để định dạng số

// Một lớp Model đơn giản để chứa dữ liệu sản phẩm
class Product {
  final String imageUrl;
  final String title;
  final double price;
  final double rating;
  final String views;

  Product({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.rating,
    required this.views,
  });
}

class ProductListScreen extends StatelessWidget {
  ProductListScreen({super.key});

  // Dữ liệu giả để hiển thị
  final List<Product> products = [
    Product(
      imageUrl: 'assets/images/vinam.jpg',
      title: 'Ví nam mini đựng thẻ VS22 chất da Saffiano bền đẹp chố...',
      price: 255000,
      rating: 4.0,
      views: '12 views',
    ),
    Product(
      imageUrl: 'assets/images/tuideocheo.jpg',
      title: 'Túi đeo chéo LEACAT polyester chống thấm nước thời trang c...',
      price: 315000,
      rating: 5.0,
      views: '1.3k views',
    ),
    Product(
      imageUrl: 'assets/images/cafe.jpg',
      title: 'Phin cafe Trung Nguyên - Phin nhôm cá nhân cao cấp',
      price: 28000,
      rating: 4.5,
      views: '12.2k views',
    ),
    Product(
      imageUrl: 'assets/images/vida.webp',
      title: 'Ví da cầm tay mềm mại cỡ lớn thiết kế thời trang cho nam',
      price: 610000,
      rating: 5.0,
      views: '56 views',
    ),
    Product(
      imageUrl: 'assets/images/depnu.jpg',
      title: 'Dép nữ đế xuồng siêu nhẹ tăng chiều cao 7cm',
      price: 189000,
      rating: 4.8,
      views: '2.5k views',
    ),
    Product(
      imageUrl: 'assets/images/tainghe.jpg',
      title: 'Tai nghe Bluetooth M10 TWS không dây cao cấp',
      price: 99000,
      rating: 4.9,
      views: '15k views',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DANH SÁCH SẢN PHẨM'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 cột
          crossAxisSpacing: 8.0, // Khoảng cách ngang
          mainAxisSpacing: 8.0, // Khoảng cách dọc
          childAspectRatio: 0.65, // Tỷ lệ chiều rộng/chiều cao của mỗi item
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _ProductItemCard(product: products[index]);
        },
      ),
    );
  }
}

// Widget riêng cho mỗi sản phẩm trong lưới
class _ProductItemCard extends StatelessWidget {
  final Product product;
  const _ProductItemCard({required this.product});

  @override
  Widget build(BuildContext context) {
    // Dùng để định dạng giá tiền có dấu phẩy ngăn cách
    final priceFormatter = NumberFormat("#,##0", "vi_VN");

    // Widget để hiển thị ảnh, có thể là từ mạng hoặc từ asset
    Widget imageWidget;
    if (product.imageUrl.startsWith('http')) {
      // Nếu là URL, dùng Image.network
      imageWidget = Image.network(
        product.imageUrl,
        fit: BoxFit.cover,
        height: 180,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 180,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } else {
      // Nếu không phải URL, dùng Image.asset
      imageWidget = Image.asset(
        product.imageUrl,
        fit: BoxFit.cover,
        height: 180,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            color: Colors.grey[200],
            child: const Icon(Icons.error, color: Colors.red), // Icon lỗi cho asset
          );
        },
      );
    }

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias, // Bo tròn cả ảnh bên trong
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh sản phẩm
          imageWidget, // <-- Sử dụng widget ảnh đã được xác định ở trên

          // Phần thông tin bên dưới ảnh
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),

                // Tag và đánh giá
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'HÒA HỒNG XTRA',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(
                      ' ${product.rating}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Giá và lượt xem
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${priceFormatter.format(product.price)} VND',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      product.views,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}