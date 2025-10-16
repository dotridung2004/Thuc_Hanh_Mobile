import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http; // For API simulation

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  const OTPScreen({super.key, required this.phoneNumber});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final String _correctOtp = "123456"; // Mã OTP giả lập

  late Timer _timer;
  int _start = 60;
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    _sendOtp(); // Gửi OTP lần đầu
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  // Giả lập việc gọi API để gửi OTP
  Future<void> _sendOtp() async {
    // URL của server giả lập (bạn có thể dùng localhost hoặc một dịch vụ mock)
    // Ví dụ: var url = Uri.parse('http://10.0.2.2:3000/send-otp');
    // Vì không có server thật, chúng ta chỉ giả lập độ trễ
    print('Đang giả lập gửi OTP tới số: ${widget.phoneNumber}...');
    await Future.delayed(const Duration(seconds: 2));
    print('OTP giả lập đã được gửi!');

    // Hiển thị thông báo (tùy chọn)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mã OTP (123456) đã được gửi (giả lập).')),
    );
  }

  void startTimer() {
    setState(() {
      _start = 60;
      _isResendEnabled = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isResendEnabled = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      if (_otpController.text == _correctOtp) {
        // Correct OTP
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thành công'),
            content: const Text('Tài khoản của bạn đã được đăng ký thành công!'),
            actions: [
              TextButton(
                onPressed: () {
                  // Điều hướng về màn hình chính hoặc login
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Incorrect OTP
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã OTP không chính xác. Vui lòng thử lại.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, color: Colors.black),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác minh OTP"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nhập mã xác minh',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Một mã gồm 6 chữ số đã được gửi đến số điện thoại ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Pinput(
                length: 6,
                controller: _otpController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: Colors.deepPurple),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập mã OTP";
                  }
                  if (value.length < 6) {
                    return "Mã OTP phải có 6 chữ số";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _verifyOtp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Xác Minh', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chưa nhận được mã? "),
                  TextButton(
                    onPressed: _isResendEnabled
                        ? () {
                      _sendOtp(); // Gọi lại API giả lập
                      startTimer(); // Bắt đầu đếm ngược lại
                    }
                        : null,
                    child: Text(
                      _isResendEnabled ? 'Gửi lại OTP' : 'Gửi lại sau ($_start s)',
                      style: TextStyle(
                        color: _isResendEnabled ? Colors.deepPurple : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}