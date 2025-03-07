import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/utils/theme/app_theme_management.dart';
import 'package:hexalyte_ams/utils/widgets/labels/label.dart';
import '../../../controllers/assets_controllers/assets_controller.dart';
import '../../theme/font_size.dart';
import '../../theme/responsive_size.dart';

class CategorySelectorWidget extends StatelessWidget {
  final AssetController controller;
  final AppThemeManager themeManager;

  const CategorySelectorWidget(
      {Key? key, required this.controller, required this.themeManager})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: controller.categories
                .map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        controller.changeCategory(category);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveSize.getWidth(size: 16),
                          vertical: ResponsiveSize.getHeight(size: 8),
                        ),
                        decoration: BoxDecoration(
                          color: controller.selectedCategory.value == category
                              ? themeManager.primaryColor
                              : themeManager.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: themeManager.primaryColor),
                        ),
                        child: AppLabel(
                          text: category,
                          textColor:
                              controller.selectedCategory.value == category
                                  ? Colors.white
                                  : themeManager.primaryColor,
                          fontSize: FontSizes.small,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
