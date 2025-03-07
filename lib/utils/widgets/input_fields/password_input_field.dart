import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppPasswordTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Color inputTextColor;
  final double fontSize;
  final Color cursorColor;
  final Color borderColor;
  final Color hintColor;
  final String? Function(String?)? validator;
  final RxBool obscureText;

  const AppPasswordTextFormField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.inputTextColor = Colors.black,
    this.fontSize = 16.0,
    this.cursorColor = Colors.black,
    this.borderColor = Colors.black,
    this.hintColor = Colors.grey,
    this.validator,
    required this.obscureText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => TextFormField(
        controller: controller,
        cursorColor: cursorColor,
        obscureText: obscureText.value,
        validator: validator,
        style: TextStyle(
          color: inputTextColor,
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
            color: hintColor,
            fontWeight: FontWeight.w400,

          ),
          suffixIcon: IconButton(
            icon: obscureText.value
                ? Icon(
              Icons.visibility,
              color: borderColor,
            )
                : Icon(
              Icons.visibility_off,
              color: borderColor,
            ),
            onPressed: () {
              obscureText.value = !obscureText.value;
            },
          ),
        ),
      ),
    );
  }
}
