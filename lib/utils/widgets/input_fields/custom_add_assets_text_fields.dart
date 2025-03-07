import 'package:flutter/material.dart';
import 'package:hexalyte_ams/utils/theme/app_theme_management.dart';
import 'package:hexalyte_ams/utils/theme/font_size.dart';
import 'package:hexalyte_ams/utils/theme/responsive_size.dart';

class CustomAssetTextField extends StatelessWidget {
  final String label;
  final bool isDate;
  final AppThemeManager themeManager;

  const CustomAssetTextField({
    Key? key,
    required this.label,
    this.isDate = false,
    required this.themeManager, required TextEditingController controller, required bool isNumeric,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: ResponsiveSize.getHeight(size: 8)),
      child: TextField(
        cursorColor: themeManager.primaryColor,
        readOnly: isDate,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: themeManager.primaryColor,
            fontSize: FontSizes.small,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: themeManager.primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: themeManager.primaryColor),
          ),
        ),
        onTap: isDate
            ? () {
                print("Select date for $label");
              }
            : null,
      ),
    );
  }
}
