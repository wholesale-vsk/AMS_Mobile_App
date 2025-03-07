
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme_management.dart';

class AppTextFormField extends StatelessWidget {
  final AppThemeManager themeManager = Get.find();
  final TextEditingController controller;
  final String hintText;
  final double fontSize;
  final Color inputTextColor;
  final Color cursorColor;
  final Color borderColor;
  final Color hintColor;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  int? minLine;
  int? maxLine;

  AppTextFormField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.inputTextColor = Colors.black,
    this.fontSize = 16.0,
    this.cursorColor = Colors.black,
    this.borderColor = Colors.black,
    this.hintColor = Colors.grey,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.minLine = 1,
    this.maxLine = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(

      controller: controller,
      validator: validator,
      cursorColor: cursorColor,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(
        color: themeManager.textColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: borderColor,
            width: 2,
          ),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: fontSize,
          color: themeManager.primaryCoolGrey,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
