import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/utils/theme/font_size.dart';
import 'package:hexalyte_ams/utils/theme/responsive_size.dart';
import 'package:hexalyte_ams/utils/widgets/labels/label.dart';
import '../../../routes/app_routes.dart';
import '../../theme/app_theme_management.dart';

class HomeCardView extends StatelessWidget {
  final AppThemeManager themeManager = Get.find();

  final IconData icon;
  final String label;
  final int index;

  HomeCardView({required this.icon, required this.label, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
           Get.toNamed(AppRoutes.DASHBOARD_SCREEN); // Example for View Assets
            break;
          case 1:
            Get.toNamed(AppRoutes.VIEW_ALL_ASSETS_SCREEN); // Example for Update Asset
            break;
          case 2:
            Get.toNamed(AppRoutes.ADD_ASSET_SCREEN); // Add Asset Screen
            break;
          case 3:
            Get.toNamed(AppRoutes.USERS_SCREEN); // Users Screen
            break;
          case 6:
            Get.toNamed(AppRoutes.HELP_AND_SUPPORT_SCREEN); // Help and Support
            break;
            case 7:
            Get.toNamed(AppRoutes.APP_CHAT_SCREEN); // App chat screen
            break;
          case 8:
            Get.toNamed(AppRoutes.APP_SETTINGS_SCREEN); // App settings screen
            break;
            case 5:
            Get.toNamed(AppRoutes.ASSETS_SELECT_FOR_REPORT_SCREEN); // Select assets for reports Screen
            break;
          case 10:
            Get.toNamed(AppRoutes.APP_SETTINGS_SCREEN); // Building report screen
            break;
          case 4:
            Get.toNamed(AppRoutes.NOTIFICATION_SCREEN); // notifitionsscreen
            break;
        // Add other cases as needed
          default:
            Get.snackbar('Info', 'This feature is not implemented yet!');
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 2,
        color: themeManager.backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: ResponsiveSize.getHeight(size: 40),
                color: themeManager.primaryColor,
              ),
              SizedBox(height: ResponsiveSize.getHeight(size: 10)),
              AppLabel(
                text: label,
                fontSize: ResponsiveSize.getHeight(size: FontSizes.medium),
                fontWeight: FontWeight.w600,
                textColor: themeManager.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
