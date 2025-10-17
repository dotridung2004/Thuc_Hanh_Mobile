import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

// --- CÁC HẰNG SỐ CỦA GAME ---
const double BALL_SIZE = 50.0;
const double TARGET_SIZE = 50.0;
// Hệ số điều chỉnh tốc độ, càng lớn bi lăn càng nhanh
const double SPEED_FACTOR = 4.0;
// Ngưỡng va chạm: Khoảng cách giữa tâm hai vật thể để được coi là chạm
const double COLLISION_THRESHOLD = 25.0;

void main() {
  // Đảm bảo Flutter binding đã được khởi tạo trước khi chạy ứng dụng
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lăn Bi Thăng Bằng',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        // Cài đặt font Inter (giả định)
        fontFamily: 'Inter',
      ),
      home: const BalanceGameScreen(),
    );
  }
}

class BalanceGameScreen extends StatefulWidget {
  const BalanceGameScreen({super.key});

  @override
  State<BalanceGameScreen> createState() => _BalanceGameScreenState();
}

class _BalanceGameScreenState extends State<BalanceGameScreen> {
  // --- VỊ TRÍ VÀ TRẠNG THÁI GAME ---
  double _ballX = 0.0;
  double _ballY = 0.0;
  double _targetX = 0.0;
  double _targetY = 0.0;
  bool _isWin = false;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  // Biến lưu kích thước màn hình để tính giới hạn
  double _screenWidth = 0.0;
  double _screenHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  // Khởi tạo trạng thái game: đặt bi ở giữa, đặt đích ngẫu nhiên
  void _initGame() {
    // Đảm bảo rằng việc lắng nghe cảm biến chỉ diễn ra sau khi game được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _screenWidth = MediaQuery.of(context).size.width;
      _screenHeight = MediaQuery.of(context).size.height;

      setState(() {
        // Đặt bi ở giữa màn hình
        _ballX = (_screenWidth / 2) - (BALL_SIZE / 2);
        _ballY = (_screenHeight / 2) - (BALL_SIZE / 2);
        _setRandomTarget();
        _isWin = false;
      });

      _startListeningToAccelerometer();
    });
  }

  // Đặt đích (target) tại một vị trí ngẫu nhiên trên màn hình
  void _setRandomTarget() {
    final random = Random();

    // Đảm bảo đích không nằm sát mép màn hình
    _targetX = random.nextDouble() * (_screenWidth - TARGET_SIZE - 20) + 10;
    _targetY = random.nextDouble() * (_screenHeight - TARGET_SIZE - 20) + 10;

    // Tạm thời dừng lắng nghe để tránh cập nhật vị trí bi trong lúc đặt đích
    _accelerometerSubscription.pause();
    setState(() {});
    _accelerometerSubscription.resume();
  }

  // Bắt đầu lắng nghe Gia tốc kế
  void _startListeningToAccelerometer() {
    // Lắng nghe Gia tốc kế
    _accelerometerSubscription = accelerometerEvents.listen(
          (AccelerometerEvent event) {
        if (_isWin) return; // Không di chuyển bi khi đã thắng

        // Cập nhật tọa độ trong setState
        setState(() {
          // Cập nhật vị trí X: event.x là độ nghiêng theo chiều ngang
          // Dấu cộng (+) cho event.x thường làm bi di chuyển theo hướng nghiêng tự nhiên
          _ballX += event.x * SPEED_FACTOR;

          // Cập nhật vị trí Y: event.y là độ nghiêng theo chiều dọc (trước/sau)
          // Dấu trừ (-) đảo ngược hướng để khi nghiêng về trước (âm) bi đi lên
          _ballY -= event.y * SPEED_FACTOR;

          // --- Logic Giới Hạn Tốc Độ & Biên Độ ---
          // Clamping để bi không lăn ra ngoài màn hình
          _ballX = _ballX.clamp(0.0, _screenWidth - BALL_SIZE);
          _ballY = _ballY.clamp(0.0, _screenHeight - BALL_SIZE);

          // Kiểm tra điều kiện thắng sau mỗi lần cập nhật vị trí
          _checkWinCondition();
        });
      },
      onError: (e) {
        // Xử lý lỗi nếu không có cảm biến
        print('Accelerometer Error: $e');
        // Có thể hiện SnackBar báo lỗi
      },
      cancelOnError: true,
    );
  }

  // Kiểm tra xem Quả bi đã chạm vào Đích chưa
  void _checkWinCondition() {
    // Tính toán tâm của Quả bi
    final ballCenterX = _ballX + BALL_SIZE / 2;
    final ballCenterY = _ballY + BALL_SIZE / 2;

    // Tính toán tâm của Đích
    final targetCenterX = _targetX + TARGET_SIZE / 2;
    final targetCenterY = _targetY + TARGET_SIZE / 2;

    // Tính khoảng cách Euclidean giữa hai tâm
    final distance = sqrt(
        pow(ballCenterX - targetCenterX, 2) +
            pow(ballCenterY - targetCenterY, 2)
    );

    // Nếu khoảng cách nhỏ hơn ngưỡng va chạm (25.0), game kết thúc
    if (distance < COLLISION_THRESHOLD && !_isWin) {
      _isWin = true;
      _showWinDialog();
    }
  }

  // Hiển thị hộp thoại chiến thắng
  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: const Text('🎉 Chúc mừng Chiến thắng! 🎉', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          content: const Text('Bạn đã đưa quả bi vào đích thành công! Sẵn sàng cho vòng tiếp theo?', style: TextStyle(color: Colors.black87)),
          actions: <Widget>[
            TextButton(
              child: const Text('Vòng mới', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
                _resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  // Đặt lại trò chơi (reset trạng thái thắng và đặt lại đích)
  void _resetGame() {
    setState(() {
      _isWin = false;
      _setRandomTarget(); // Đặt đích ở vị trí ngẫu nhiên mới
    });
    // Bi vẫn giữ nguyên vị trí, người chơi phải tiếp tục lăn
    _accelerometerSubscription.resume();
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cập nhật kích thước màn hình trong build
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lăn Bi Thăng Bằng',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Container(
        // Thiết lập giao diện thân thiện với thiết bị di động
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFB3E5FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // --- 1. Đích (Target) ---
            Positioned(
              left: _targetX,
              top: _targetY,
              child: Container(
                width: TARGET_SIZE,
                height: TARGET_SIZE,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300, // Màu nền sáng
                  border: Border.all(color: Colors.grey.shade700, width: 4), // Viền đậm
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade500.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.star, color: Colors.green, size: 30),
                ),
              ),
            ),

            // --- 2. Quả bi (Ball) ---
            Positioned(
              left: _ballX,
              top: _ballY,
              child: Container(
                width: BALL_SIZE,
                height: BALL_SIZE,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Bi đổi màu khi thắng để có phản hồi thị giác
                  color: _isWin ? Colors.green.shade600 : Colors.blue.shade600,
                  gradient: LinearGradient(
                    colors: [
                      _isWin ? Colors.greenAccent : Colors.blueAccent,
                      _isWin ? Colors.green.shade800 : Colors.blue.shade800,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(5, 5),
                    ),
                  ],
                ),
              ),
            ),

            // --- 3. Hiển thị Trạng thái (Tùy chọn) ---
            if (_isWin)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ĐÃ CHẠM ĐÍCH!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}