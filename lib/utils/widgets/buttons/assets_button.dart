import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/utils/theme/app_theme_management.dart';
import 'package:hexalyte_ams/utils/theme/responsive_size.dart';
import 'package:hexalyte_ams/utils/widgets/labels/label.dart';

class AssetButton extends StatelessWidget {
  final AppThemeManager themeManager = Get.find();
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  AssetButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding:
            EdgeInsets.symmetric(vertical: ResponsiveSize.getHeight(size: 16)),
      ),
      onPressed: onTap,
      child: Row(
        children: [
          SizedBox(width: ResponsiveSize.getWidth(size: 16)),
          //::::::::::::::::::::::::> Icon <::::::::::::::::::::::::://
          Icon(
            icon,
            color: iconColor,
            size: ResponsiveSize.getWidth(size: 36),
          ),
          SizedBox(width: ResponsiveSize.getWidth(size: 16)),
          //::::::::::::::::::::::::> Label <::::::::::::::::::::::::://
          AppLabel(
            text: label,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            textColor: themeManager.primaryColor,
          ),
        ],
      ),
    );
  }
}
