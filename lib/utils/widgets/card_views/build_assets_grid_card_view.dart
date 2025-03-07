import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/utils/theme/app_theme_management.dart';
import 'package:hexalyte_ams/utils/widgets/buttons/app_filled_icon_button.dart';
import 'package:hexalyte_ams/utils/widgets/buttons/filled_button.dart';
import '../../../controllers/assets_controllers/assets_controller.dart';
import '../../../routes/app_routes.dart';
import '../../theme/font_size.dart';
import '../../theme/responsive_size.dart';
import '../labels/label.dart';

class AssetGridWidget extends StatelessWidget {
  final AssetController controller;
  final AppThemeManager themeManager;

  const AssetGridWidget(
      {Key? key, required this.controller, required this.themeManager})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filteredAssets = controller.filteredAssets;
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: filteredAssets.length,
        itemBuilder: (context, index) {
          final asset = filteredAssets[index];
          return GestureDetector(
            onTap: () => _navigateToDetails(asset: asset),
            onLongPress: () => _editOrDeleteFunction(),
            child: Card(
              color: themeManager.backgroundColor.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              margin: EdgeInsets.only(
                bottom: ResponsiveSize.getHeight(size: 12),
              ),
              child: SizedBox(
                height: ResponsiveSize.getHeight(size: 124),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveSize.getWidth(size: 8),
                    vertical: ResponsiveSize.getHeight(size: 8),
                  ),
                  child: Row(
                    children: [
                      // ::::::::::::::: Asset Image ::::::::::::::: //
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          asset['image'],
                          width: ResponsiveSize.getWidth(size: 84),
                          height: ResponsiveSize.getHeight(size: 84),
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: ResponsiveSize.getWidth(size: 12)),
                      // ::::::::::::::: Asset Details :::::::::::::::
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppLabel(
                              text: asset['title'],
                              textColor: themeManager.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: FontSizes.medium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: ResponsiveSize.getHeight(size: 4)),
                            AppLabel(
                              text: asset['subtitle'],
                              textColor:
                                  themeManager.textColor.withOpacity(0.7),
                              fontSize: FontSizes.small,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: ResponsiveSize.getHeight(size: 4)),
                            AppLabel(
                              text: asset['description'],
                              textColor: themeManager.textColor,
                              fontSize: FontSizes.small,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  // ::::::::::::::: Navigates To Asset Details ::::::::::::::: //
  void _navigateToDetails({required Map<String, dynamic> asset}) {
    switch (asset['c-type']) {
      case 'Vehicle':
        Get.toNamed(AppRoutes.VEHICLE_DETAILS_SCREEN, arguments: asset);
        break;
      case 'Land':
        Get.toNamed(AppRoutes.LAND_DETAILS_SCREEN, arguments: asset);
        break;
      case 'Building':
        Get.toNamed(AppRoutes.BUILDING_DETAILS_SCREEN, arguments: asset);
        break;
      default:
        break;
    }
  }

  // ::::::::::::::: Shows Edit Or Delete Dialog ::::::::::::::: //
  void _editOrDeleteFunction() {
    Get.defaultDialog(
      title: "Asset Options",
      titleStyle: const TextStyle(
          fontSize: FontSizes.extraLarge, fontWeight: FontWeight.bold),
      backgroundColor: themeManager.backgroundColor,
      titlePadding: EdgeInsets.only(top: ResponsiveSize.getHeight(size: 16)),
      contentPadding: EdgeInsets.all(ResponsiveSize.getHeight(size: 16)),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: ResponsiveSize.getWidth(size: 110),
            child: AppFilledIconButton(
              text: 'Delete',
              icon: Icons.delete_rounded,
              iconColor: themeManager.primaryWhite,
              textColor: themeManager.primaryWhite,
              backgroundColor: themeManager.primaryRed,
              borderColor: themeManager.primaryRed,
              height: ResponsiveSize.getHeight(size: 40),
              fontSize: FontSizes.medium,
              onPressed: () => _showDeleteConfirmation(),
            ),
          ),
          SizedBox(width: ResponsiveSize.getHeight(size: 16)),
          SizedBox(
            width: ResponsiveSize.getWidth(size: 110),
            child: AppFilledIconButton(
              text: 'Edit',
              icon: Icons.edit_note_rounded,
              iconColor: themeManager.primaryWhite,
              textColor: themeManager.primaryWhite,
              backgroundColor: themeManager.primaryColor,
              borderColor: themeManager.primaryColor,
              height: ResponsiveSize.getHeight(size: 40),
              fontSize: FontSizes.medium,
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

  // ::::::::::::::: Shows Delete Confirmation Dialog ::::::::::::::: //
  void _showDeleteConfirmation() {
    Get.defaultDialog(
      title: "Confirm Delete",
      backgroundColor: themeManager.backgroundColor,
      titleStyle: const TextStyle(
          fontSize: FontSizes.extraLarge, fontWeight: FontWeight.bold),
      content: Padding(
        padding:  EdgeInsets.symmetric(horizontal: ResponsiveSize.getWidth(size: 16)),
        child: AppLabel(
          maxLines: 3,
          text: "Are you sure you want to delete this asset?",
          textColor: themeManager.textColor,
          fontSize: FontSizes.large,
          fontWeight: FontWeight.w500
        ),
      ),
      actions: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: ResponsiveSize.getWidth(size: 110),
                  child: AppFilledIconButton(
                    text: 'Delete',
                    icon: Icons.delete_rounded,
                    iconColor: themeManager.primaryWhite,
                    textColor: themeManager.primaryWhite,
                    backgroundColor: themeManager.primaryRed,
                    borderColor: themeManager.primaryRed,
                    height: ResponsiveSize.getHeight(size: 40),
                    fontSize: FontSizes.medium,
                    onPressed: () => Get.back(),
                  ),
                ),
                SizedBox(width: ResponsiveSize.getWidth(size: 10)),
                SizedBox(
                  width: ResponsiveSize.getWidth(size: 112),
                  child: AppFilledIconButton(
                    text: 'Cancel',
                    icon: Icons.cancel_rounded,
                    iconColor: themeManager.primaryWhite,
                    textColor: themeManager.primaryWhite,
                    backgroundColor: themeManager.primaryColor,
                    borderColor: themeManager.primaryColor,
                    height: ResponsiveSize.getHeight(size: 40),
                    fontSize: FontSizes.medium,
                    onPressed: () => Get.back(),
                  ),
                ),
              ],
            ),
            SizedBox(
                height: ResponsiveSize.getHeight(
              size: ResponsiveSize.getHeight(size: 20),
            )),
          ],
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hexalyte_ams/utils/theme/app_theme_management.dart';
// import '../../../controllers/assets_controllers/assets_controller.dart';
// import '../../../routes/app_routes.dart';
// import '../../theme/font_size.dart';
// import '../../theme/responsive_size.dart';
// import '../labels/label.dart';
//
//
// class AssetGridWidget extends StatelessWidget {
//   final AssetsController controller;
//   final AppThemeManager themeManager;
//
//   const AssetGridWidget({Key? key, required this.controller , required this.themeManager}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//           () {
//         final filteredAssets = controller.filteredAssets;
//         return ListView.builder(
//           padding: EdgeInsets.zero,
//           itemCount: filteredAssets.length,
//           itemBuilder: (context, index) {
//             final asset = filteredAssets[index];
//             return GestureDetector(
//               onTap:selectCategory(asset),
//               onLongPress: () => _editOrDeleteFunction(),
//               child: Card(
//                 color: themeManager.backgroundColor.withOpacity(0.9),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 2,
//                 margin: EdgeInsets.only(
//                   bottom: ResponsiveSize.getHeight(size: 12),
//                 ),
//                 child: SizedBox(
//                   height: ResponsiveSize.getHeight(size: 124),
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: ResponsiveSize.getWidth(size: 8),
//                       vertical: ResponsiveSize.getHeight(size: 8),
//                     ),
//                     child: Row(
//                       children: [
//                         //:::::::::::::::::::::::<< Asset Image >>::::::::::::::::::::::::::://
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.asset(
//                             asset['image'],
//                             width: ResponsiveSize.getWidth(size: 84),
//                             height: ResponsiveSize.getHeight(size: 84),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         SizedBox(width: ResponsiveSize.getWidth(size: 12)),
//                         //:::::::::::::::::::::::<< Asset Details >>::::::::::::::::::::::::::://
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               AppLabel(
//                                 text: asset['title'],
//                                 textColor: themeManager.primaryColor,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: FontSizes.medium,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               SizedBox(
//                                   height: ResponsiveSize.getHeight(size: 4)),
//                               AppLabel(
//                                 text: asset['subtitle'],
//                                 textColor:
//                                 themeManager.textColor.withOpacity(0.7),
//                                 fontSize: FontSizes.small,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               SizedBox(
//                                   height: ResponsiveSize.getHeight(size: 4)),
//                               AppLabel(
//                                 text: asset['description'],
//                                 textColor: themeManager.textColor,
//                                 fontSize: FontSizes.small,
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                         // :::::::::::::::::::::::::<< Edit and Delete Buttons >>:::::::::::::::::::::::: //
//                         // Column(
//                         //   children: [
//                         //     IconButton(
//                         //       icon: Icon(Icons.edit, color: themeManager.primaryBlue),
//                         //       iconSize: ResponsiveSize.getHeight(size: 24),
//                         //       onPressed: () {
//                         //         // Handle edit action
//                         //         // controller.editAsset(asset);
//                         //       },
//                         //     ),
//                         //     SizedBox(height: ResponsiveSize.getHeight(size: 16)),
//                         //     IconButton(
//                         //       icon: Icon(Icons.delete, color: themeManager.primaryRed),
//                         //       iconSize: ResponsiveSize.getHeight(size: 24),
//                         //       onPressed: () {
//                         //         // Handle delete action
//                         //         //controller.deleteAsset(asset);
//                         //       },
//                         //     ),
//                         //   ],
//                         // ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void selectCategory( Map<String, dynamic> asset){
//     if (asset['c-type'] == 'Vehicle') {
//       Get.toNamed(AppRoutes.VEHICLE_DETAILS_SCREEN,
//           arguments: asset);
//     } else if (asset['c-type'] == 'Land') {
//       Get.toNamed(AppRoutes.LAND_DETAILS_SCREEN, arguments: asset);
//     } else if (asset['c-type'] == 'Building') {
//       Get.toNamed(AppRoutes.BUILDING_DETAILS_SCREEN,
//           arguments: asset);
//     }
//   }
//
//   void _editOrDeleteFunction(){
//     Get.defaultDialog(
//       title: "Asset Options",
//       titleStyle: TextStyle(fontSize: FontSizes.medium, fontWeight: FontWeight.bold),
//       backgroundColor: themeManager.backgroundColor,
//       titlePadding: EdgeInsets.only(top: 16),
//       contentPadding: EdgeInsets.all(16),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ElevatedButton.icon(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: themeManager.primaryColor,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               padding: EdgeInsets.symmetric(vertical: ResponsiveSize.getHeight(size: 12)),
//             ),
//             icon: Icon(Icons.edit, color: Colors.white),
//             label: Text("Edit", style: TextStyle(color: Colors.white, fontSize: FontSizes.small)),
//             onPressed: () {
//               Get.back(); // Close the dialog
//               // Implement edit functionality here
//               // controller.editAsset(asset);
//             },
//           ),
//           SizedBox(height: ResponsiveSize.getHeight(size: 12)),
//           ElevatedButton.icon(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: themeManager.primaryRed,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               padding: EdgeInsets.symmetric(vertical: ResponsiveSize.getHeight(size: 12)),
//             ),
//             icon: Icon(Icons.delete, color: Colors.white),
//             label: Text("Delete", style: TextStyle(color: Colors.white, fontSize: FontSizes.small)),
//             onPressed: () {
//               Get.back(); // Close the dialog
//               Get.defaultDialog(
//                 title: "Confirm Delete",
//                 titleStyle: TextStyle(fontSize: FontSizes.medium, fontWeight: FontWeight.bold),
//                 content: Text("Are you sure you want to delete this asset?", textAlign: TextAlign.center),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Get.back(),
//                     child: Text("Cancel", style: TextStyle(color: themeManager.primaryColor)),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       Get.back(); // Close confirmation dialog
//                       // Implement delete functionality here
//                       // controller.deleteAsset(asset);
//                     },
//                     style: ElevatedButton.styleFrom(backgroundColor: themeManager.primaryRed),
//                     child: Text("Delete", style: TextStyle(color: Colors.white)),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//
// }
