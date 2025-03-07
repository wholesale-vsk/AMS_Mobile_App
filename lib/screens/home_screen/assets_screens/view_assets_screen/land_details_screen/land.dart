// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:hexalyte_ams/models/assets/land/land_model.dart';
// // import '../../../../../controllers/land_controller/load_land_controller.dart';
// // import '../../../../../utils/theme/responsive_size.dart';
// // import 'land_details_screen.dart';
// //
// // class landScreen extends StatelessWidget {
// //   landScreen({super.key});
// //
// //   final LoadLandController controller = Get.put(LoadLandController());
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[100],
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 2,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back, color: Colors.black),
// //           onPressed: () => Get.back(),
// //         ),
// //         title: const Text(
// //           "Land Management",
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
// //           if (controller.lands.isEmpty) {
// //             return const Center(
// //               child: Text(
// //                 "No land available",
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
// //                 itemCount: controller.lands.length,
// //                 itemBuilder: (context, index) {
// //                   final land asset = controller.lands[index];
// //                   return LandCard(asset: asset);
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
// // class LandCard extends StatelessWidget {
// //   final land asset;
// //
// //   const LandCard({Key? key, required this.asset}) : super(key: key);
// //
// //   String getValidImageUrl(String? url) {
// //     return (url != null && url.isNotEmpty)
// //         ? url
// //         : 'assets/images/land.jpg'; // Default image
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: () => Get.to(
// //             () => LandDetailsScreen(asset: null, land: {},),
// //         arguments: _convertLandToMap(asset), // ✅ Convert Building object to Map before passing
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
// //                   getValidImageUrl(asset.imageURL),
// //                   width: double.infinity,
// //                   height: ResponsiveSize.getHeight(size: 125),
// //                   fit: BoxFit.cover,
// //                   errorBuilder: (context, error, stackTrace) => Image.asset(
// //                     'assets/images/land.jpg',
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
// //                       asset.name,
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
// //                           asset.city,
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
//   /// ✅ Convert `Land` Object to `Map<String, dynamic>`
//   Map<String, dynamic> _convertLandToMap(land land) {
//     return {
//       "name": land.name,
//       "type": land.type,
//       "size": land.size,
//       "address": land.address,
//       "city": land.city,
//       "province": land.province,
//       "purchaseDate": land.purchaseDate,
//       "purchasePrice": land.purchasePrice,
//       "imageURL": land.imageURL,
//     };
//   }
// }
