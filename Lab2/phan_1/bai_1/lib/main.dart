import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RegisterScreen(),
  ));
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  DateTime? _birthDate;
  String? _gender = 'Nam';
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _saveAndGoToOtp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameCtrl.text.trim());
    await prefs.setString('email', _emailCtrl.text.trim());
    await prefs.setString('phone', _phoneCtrl.text.trim());
    await prefs.setString('birthDate', _birthDate!.toIso8601String());
    await prefs.setString('gender', _gender!);
    await prefs.setString('password', _passwordCtrl.text);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OtpScreen()),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f8fd),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.only(top: 36, bottom: 20, left: 16, right: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6236FF),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Đăng Ký Tài Khoản",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Tạo tài khoản để bắt đầu trải nghiệm",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.person_add_alt_1,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFieldLabel('Họ & tên'),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: _inputDecoration('Nguyễn Văn A'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildFieldLabel('Email'),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: _inputDecoration('example@email.com'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                          final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailReg.hasMatch(v)) return 'Email không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildFieldLabel('Số điện thoại'),
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: _inputDecoration('0987654321'),
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Vui lòng nhập SĐT';
                          if (!RegExp(r'^\d{10}$').hasMatch(v)) return 'Số điện thoại phải đủ 10 số';
                          return null;
                        },
                      ),
                      const SizedBox(height: 0),
                      _buildFieldLabel('Mật khẩu'),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration('Ít nhất 6 ký tự').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(() {
                              _obscurePassword = !_obscurePassword;
                            }),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                          if (v.length < 6) return 'Mật khẩu ít nhất 6 ký tự';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildFieldLabel('Xác nhận mật khẩu'),
                      TextFormField(
                        controller: _confirmPasswordCtrl,
                        obscureText: _obscureConfirmPassword,
                        decoration: _inputDecoration('Nhập lại mật khẩu').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            }),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Vui lòng nhập lại mật khẩu';
                          if (v != _passwordCtrl.text) return 'Mật khẩu không khớp';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildFieldLabel('Ngày sinh'),
                      GestureDetector(
                        onTap: () async {
                          final now = DateTime.now();
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(now.year - 18, 1, 1),
                            firstDate: DateTime(1900),
                            lastDate: now,
                          );
                          if (picked != null) {
                            setState(() {
                              _birthDate = picked;
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: _inputDecoration('dd/mm/yyyy').copyWith(
                              suffixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
                            ),
                            controller: TextEditingController(
                              text: _birthDate == null
                                  ? ''
                                  : "${_birthDate!.day.toString().padLeft(2, '0')}/"
                                  "${_birthDate!.month.toString().padLeft(2, '0')}/"
                                  "${_birthDate!.year}",
                            ),
                            validator: (_) => _birthDate == null ? 'Vui lòng chọn ngày sinh' : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFieldLabel('Giới tính'),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Nam',
                            groupValue: _gender,
                            onChanged: (v) => setState(() => _gender = v),
                            activeColor: const Color(0xFF6236FF),
                          ),
                          const Text('Nam'),
                          Radio<String>(
                            value: 'Nữ',
                            groupValue: _gender,
                            onChanged: (v) => setState(() => _gender = v),
                            activeColor: const Color(0xFF6236FF),
                          ),
                          const Text('Nữ'),
                          Radio<String>(
                            value: 'Khác',
                            groupValue: _gender,
                            onChanged: (v) => setState(() => _gender = v),
                            activeColor: const Color(0xFF6236FF),
                          ),
                          const Text('Khác'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                            activeColor: const Color(0xFF6236FF),
                          ),
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                text: 'Tôi đồng ý với ',
                                style: const TextStyle(color: Colors.black87, fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: 'điều khoản',
                                    style: const TextStyle(
                                      color: Color(0xFF6236FF),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const TextSpan(text: ' sử dụng'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!_acceptTerms)
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0, bottom: 6),
                          child: Text(
                            'Bạn phải đồng ý với điều khoản để đăng ký',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6236FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            bool isValid = _formKey.currentState?.validate() ?? false;
                            if (!_acceptTerms) isValid = false;
                            if (isValid) {
                              _saveAndGoToOtp();
                            }
                          },
                          child: const Text(
                            'Đăng Ký',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 2),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFD6D6D6), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF6236FF), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
  );
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrl = TextEditingController();
  bool _otpError = false;
  bool _success = false;

  void _verifyOtp() {
    if (_otpCtrl.text == '123456') {
      setState(() {
        _success = true;
        _otpError = false;
      });
    } else {
      setState(() {
        _otpError = true;
        _success = false;
      });
    }
  }

  void _backToRegister() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
          (route) => false,
    );
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác minh OTP')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _success
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text('Đăng ký thành công!',
                  style: TextStyle(fontSize: 22, color: Colors.green)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _backToRegister,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại Đăng ký'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6236FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          )
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nhập mã OTP (6 chữ số):',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  errorText: _otpError ? 'Mã OTP không đúng' : null,
                  counterText: "",
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _verifyOtp,
                child: const Text('Xác minh'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}