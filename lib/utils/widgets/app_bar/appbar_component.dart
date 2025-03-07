import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/utils/theme/font_size.dart';
import 'package:hexalyte_ams/utils/theme/responsive_size.dart';

import '../../theme/app_theme_management.dart';
import '../labels/label.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  final double screenWidth;
  final double screenHeight;
  final String appBarTitle;
  final double elevation; // New parameter
  final AppThemeManager themeManager = Get.find();

  // Constructor with elevation
  AppBarComponent({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.appBarTitle,
    this.elevation = 0.0, // Default to 0.0 if not specified
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: themeManager.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
      centerTitle: true,
      toolbarHeight: ResponsiveSize.getHeight(size: 60),
      elevation: elevation, // Apply elevation here
      title: AppLabel(
        text: appBarTitle,
        fontSize: ResponsiveSize.getHeight(size: FontSizes.title),
        fontWeight: FontWeight.w600,
        textColor: themeManager.backgroundColor,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(screenHeight * 0.08);
}
