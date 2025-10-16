import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Details UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins', // Bạn có thể dùng font Poppins hoặc một font tương tự
      ),
      home: const ProductDetailsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  int _selectedColorIndex = 0;
  bool _isLiked = false;

  final Color _backgroundColor = const Color(0xFF3D82AE);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Details', style: TextStyle(color: Colors.white)),
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Xử lý sự kiện quay lại
          },
        ),
      ),
      body: Stack(
        children: [
          // Phần thông tin trên nền xanh
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aristocratic Hand Bag',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Text(
                  'Office Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Price',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Text(
                  '\$234',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.1), // Dành không gian cho ảnh
              ],
            ),
          ),
          // Phần thẻ trắng ở dưới
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.55,
              padding: EdgeInsets.only(
                top: size.height * 0.12, // Đẩy nội dung xuống dưới ảnh
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildColorAndSizeSelector(),
                  const SizedBox(height: 20),
                  const Text(
                    'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since. When an unknown printer took a galley.',
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),
                  const Spacer(),
                  _buildQuantityAndLike(),
                  const Spacer(),
                  _buildBottomBar(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Ảnh sản phẩm
          Positioned(
            top: size.height * 0.15,
            right: 20,
            child: Hero(
              tag: 'product_image',
              // Thay 'assets/images/handbag.png' bằng đường dẫn ảnh của bạn
              child: Image.asset(
                'assets/images/tuix.png',
                height: size.height * 0.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorAndSizeSelector() {
    return Row(
      children: [
        // Phần chọn màu
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Color', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildColorDot(const Color(0xFF3D82AE), 0),
                const SizedBox(width: 8),
                _buildColorDot(const Color(0xFFF8C078), 1),
                const SizedBox(width: 8),
                _buildColorDot(const Color(0xFFa29b9b), 2),
              ],
            ),
          ],
        ),
        const Spacer(),
        // Phần kích thước
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Size', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text('12 cm',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(width: 50), // Để căn chỉnh
      ],
    );
  }

  Widget _buildColorDot(Color color, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColorIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColorIndex == index
                ? color
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 8,
          backgroundColor: color,
        ),
      ),
    );
  }

  Widget _buildQuantityAndLike() {
    return Row(
      children: [
        // Bộ chọn số lượng
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (_quantity > 1) {
                    setState(() => _quantity--);
                  }
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 16),
              Text(
                _quantity.toString().padLeft(2, '0'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() => _quantity++);
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const Spacer(),
        // Nút yêu thích
        GestureDetector(
          onTap: () {
            setState(() {
              _isLiked = !_isLiked;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFF6464),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Row(
      children: [
        // Nút thêm vào giỏ hàng
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _backgroundColor.withOpacity(0.5)),
          ),
          child: Icon(Icons.shopping_cart_outlined, color: _backgroundColor),
        ),
        const SizedBox(width: 16),
        // Nút Mua ngay
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _backgroundColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('BUY NOW', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}