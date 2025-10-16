import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final BoxDecoration decoration;
  final TextStyle textStyle;
  final bool isDisabled;

  // Constructor chính, ẩn đi để ưu tiên các named constructor
  const AppButton._({
    super.key,
    required this.text,
    required this.onPressed,
    required this.decoration,
    required this.textStyle,
    this.isDisabled = false,
  });

  // 1. Primary Button
  factory AppButton.primary(
      String text, {
        Key? key,
        VoidCallback? onPressed,
        bool isDisabled = false,
      }) {
    return AppButton._(
      key: key,
      text: text,
      onPressed: isDisabled ? null : onPressed,
      isDisabled: isDisabled,
      decoration: BoxDecoration(
        color: isDisabled ? const Color(0xFFB3B3E6) : const Color(0xFF5C5CFF),
        // borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  // 2. Outlined Button
  factory AppButton.outlined(
      String text, {
        Key? key,
        VoidCallback? onPressed,
      }) {
    return AppButton._(
      key: key,
      text: text,
      onPressed: onPressed,
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF5C5CFF), width: 1.5),
      ),
      textStyle: const TextStyle(
        color: Color(0xFF5C5CFF),
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  // 3. Blue Gradient Button
  factory AppButton.gradient(
      String text, {
        Key? key,
        VoidCallback? onPressed,
      }) {
    return AppButton._(
      key: key,
      text: text,
      onPressed: onPressed,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5C5CFF), Color(0xFF2E2EB8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        // borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  // 4. Green Accent Gradient Button
  factory AppButton.accentGradient(
      String text, {
        Key? key,
        VoidCallback? onPressed,
      }) {
    return AppButton._(
      key: key,
      text: text,
      onPressed: onPressed,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF50E3C2), Color(0xFF21B899)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        // borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: decoration.borderRadius as BorderRadius?,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            alignment: Alignment.center,
            child: Text(
              text,
              style: isDisabled
                  ? textStyle.copyWith(color: Colors.white70)
                  : textStyle,
            ),
          ),
        ),
      ),
    );
  }
}

// Widget cho Text Button
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDisabled;

  const AppTextButton(
      this.text, {
        super.key,
        this.onPressed,
        this.isDisabled = false,
      });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF5C5CFF),
        disabledForegroundColor: Colors.grey.shade400,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      child: Text(text),
    );
  }
}