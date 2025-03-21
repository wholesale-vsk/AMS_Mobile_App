import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme_management.dart';

class AppFilledButton extends StatelessWidget {
  static final AppThemeManager themeManager = Get.find<AppThemeManager>();

  final String text;
  final VoidCallback onPressed;
  final double fontSize;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double width;
  final double borderRadius;
  final double borderWidth;
  final Color? borderColor;

  AppFilledButton({
    Key? key,
    Color? borderColor,
    Color? backgroundColor,
    Color? textColor,
    required this.text,
    required this.onPressed,
    this.fontSize = 16.0,
    this.height = 48.0,
    this.width = double.infinity,
    this.borderRadius = 6.0,
    this.borderWidth = 1.0, required TextStyle textStyle, required bool showShadow,
  })  : borderColor = borderColor ?? themeManager.primaryColor,
        backgroundColor = backgroundColor ?? themeManager.primaryColor,
        textColor = textColor ?? themeManager.backgroundColor,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(backgroundColor),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(color: borderColor!, width: borderWidth),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
