import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme_management.dart';

class AppLabel extends StatelessWidget {
  static final AppThemeManager themeManager = Get.find<AppThemeManager>();

  final TextOverflow overflow;
  final String text;
  final int maxLines;
  final Color? textColor;
  final FontWeight? fontWeight;
  final double fontSize;
  final FontStyle? fontStyle;
  final TextAlign? textAlign;

  AppLabel({
    Key? key,
    required this.text,
    this.overflow = TextOverflow.ellipsis,
    Color? textColor,
    this.maxLines = 1,
    this.fontSize = 16.0,
    this.fontStyle,
    this.textAlign,
    this.fontWeight = FontWeight.normal,
  })  : textColor = textColor ?? themeManager.primaryColor,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: 'Poppins-Regular',
        color: textColor,
        overflow: TextOverflow.ellipsis,
        fontWeight: fontWeight,
        fontSize: fontSize,
        fontStyle: fontStyle,
      ),
    );
  }
}
