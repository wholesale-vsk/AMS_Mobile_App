// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:hexalyte_ams/models/assets/building/building_model.dart';
// // import 'package:hexalyte_ams/screens/home_screen/assets_screens/view_assets_screen/building_details_screen/building_details_screen.dart';
// // import '../../../../../controllers/Building_Controller/load_Building_controller..dart';
// // import '../../../../../utils/theme/responsive_size.dart';
// //
// // class buildingScreen extends StatelessWidget {
// //   buildingScreen({super.key});
// //
// //   final LoadBuildingController controller = Get.put(LoadBuildingController());
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[100], // Light background
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 2,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back, color: Colors.black),
// //           onPressed: () => Get.back(),
// //         ),
// //         title: const Text(
// //           "Building Management",
// //           style: TextStyle(
// //             color: Colors.black,
// //             fontSize: 18,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         centerTitle: true,
// //       ),
// //       body: Padding(
// //         padding: EdgeInsets.symmetric(
// //           horizontal: ResponsiveSize.getWidth(size: 16),
// //           vertical: ResponsiveSize.getHeight(size: 10),
// //         ),
// //         child: Obx(() {
// //           if (controller.isLoading.value) {
// //             return const Center(child: CircularProgressIndicator());
// //           }
// //
// //           if (controller.buildings.isEmpty) {
// //             return const Center(
// //               child: Text(
// //                 "No buildings available",
// //                 style: TextStyle(fontSize: 16, color: Colors.black54),
// //               ),
// //             );
// //           }
// //
// //           return LayoutBuilder(
// //             builder: (context, constraints) {
// //               int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
// //               return GridView.builder(
// //                 padding: EdgeInsets.zero,
// //                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //                   crossAxisCount: crossAxisCount,
// //                   childAspectRatio: 0.75,
// //                   crossAxisSpacing: 12,
// //                   mainAxisSpacing: 12,
// //                 ),
// //                 itemCount: controller.buildings.length,
// //                 itemBuilder: (context, index) {
// //                   final Building building = controller.buildings[index];
// //                   return BuildingCard(building: building);
// //                 },
// //               );
// //             },
// //           );
// //         }),
// //       ),
// //     );
// //   }
// // }
// //
// // class BuildingCard extends StatelessWidget {
// //   final Building building;
// //
// //   const BuildingCard({Key? key, required this.building}) : super(key: key);
// //
// //   /// Get a valid image URL or fallback to a default placeholder.
// //   String getValidImageUrl(String? url) {
// //     return (url != null && url.isNotEmpty)
// //         ? url
// //         : 'assets/images/building.jpg'; // Default image
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: () => Get.to(
// //             () => BuildingDetailsScreen(asset: null,),
// //         arguments: _convertBuildingToMap(building), // ✅ Convert Building object to Map before passing
// //       ),
// //       child: Container(
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(16),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.1),
// //               blurRadius: 6,
// //               spreadRadius: 2,
// //               offset: const Offset(0, 4),
// //             ),
// //           ],
// //           color: Colors.white,
// //         ),
// //         child: ClipRRect(
// //           borderRadius: BorderRadius.circular(16),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               ClipRRect(
// //                 borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
// //                 child: Image.network(
// //                   getValidImageUrl(building.imageURL), // ✅ Fixed reference
// //                   width: double.infinity,
// //                   height: ResponsiveSize.getHeight(size: 125),
// //                   fit: BoxFit.cover,
// //                   errorBuilder: (context, error, stackTrace) => Image.asset(
// //                     'assets/images/building.jpg', // Fallback image
// //                     width: double.infinity,
// //                     height: ResponsiveSize.getHeight(size: 125),
// //                     fit: BoxFit.cover,
// //                   ),
// //                 ),
// //               ),
// //               Padding(
// //                 padding: const EdgeInsets.all(12),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       building.name,
// //                       style: const TextStyle(
// //                         color: Colors.black,
// //                         fontWeight: FontWeight.bold,
// //                         fontSize: 16,
// //                       ),
// //                       maxLines: 1,
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                     const SizedBox(height: 6),
// //                     Row(
// //                       children: [
// //                         const Icon(Icons.location_city, color: Colors.black54, size: 18),
// //                         const SizedBox(width: 6),
// //                         Text(
// //                           building.city,
// //                           style: const TextStyle(
// //                             color: Colors.black54,
// //                             fontSize: 14,
// //                           ),
// //                           maxLines: 1,
// //                           overflow: TextOverflow.ellipsis,
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
//   /// ✅ **Convert `Building` Object to a `Map<String, dynamic>`**
//   Map<String, dynamic> _convertBuildingToMap(Building building) {
//     return {
//       "name": building.name,
//       "buildingType": building.buildingType,
//       "numberOfFloors": building.numberOfFloors,
//       "totalArea": building.totalArea,
//       "city": building.city,
//       "address": building.address,
//       "province": building.province,
//       "ownerName": building.ownerName,
//       "purchaseDate": building.purchaseDate,
//       "constructionType": building.constructionType,
//       "constructionCost": building.constructionCost,
//       "imageURL": building.imageURL, // ✅ Pass correct image key
//     };
//   }
// }
