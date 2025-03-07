// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hexalyte_ams/models/assets/vehicle/vehicle_model.dart';
// import 'package:hexalyte_ams/screens/home_screen/assets_screens/view_assets_screen/vehicle_details_screen/vehicle_details_screen.dart';
// import '../../../../../controllers/vehicle_controller/load_vehicle_controller.dart';
// import '../../../../../utils/theme/responsive_size.dart';
//
// class VehicleScreen extends StatelessWidget {
//   VehicleScreen({super.key});
//
//   final loadVehicleController controller = Get.put(loadVehicleController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100], // Light background
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 2,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           "Vehicle Management",
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: ResponsiveSize.getWidth(size: 16),
//           vertical: ResponsiveSize.getHeight(size: 10),
//         ),
//         child: Obx(() {
//           if (controller.isLoading.value) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (controller.vehicles.isEmpty) {
//             return const Center(
//               child: Text(
//                 "No vehicles available",
//                 style: TextStyle(fontSize: 16, color: Colors.black54),
//               ),
//             );
//           }
//
//           return LayoutBuilder(
//             builder: (context, constraints) {
//               int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
//               return GridView.builder(
//                 padding: EdgeInsets.zero,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: crossAxisCount,
//                   childAspectRatio: 0.75,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                 ),
//                 itemCount: controller.vehicles.length,
//                 itemBuilder: (context, index) {
//                   final Vehicle vehicle = controller.vehicles[index];
//                   return VehicleCard(vehicle: vehicle);
//                 },
//               );
//             },
//           );
//         }),
//       ),
//     );
//   }
// }
//
// class VehicleCard extends StatelessWidget {
//   final Vehicle vehicle;
//
//   const VehicleCard({Key? key, required this.vehicle}) : super(key: key);
//
//   /// Get a valid image URL or fallback to a default placeholder.
//   String getValidImageUrl(String? url) {
//     return (url != null && url.isNotEmpty) ? url : 'assets/images/car.webp';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => Get.to(
//             () => VehicleDetailsScreen(asset: null, vehicle: {},),
//         arguments: _convertVehicleToMap(vehicle), // ✅ Convert Building object to Map before passing
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 6,
//               spreadRadius: 2,
//               offset: const Offset(0, 4),
//             ),
//           ],
//           color: Colors.white,
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ClipRRect(
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                 child: Image.network(
//                   getValidImageUrl(vehicle.imageURL), // ✅ Corrected model reference
//                   width: double.infinity,
//                   height: ResponsiveSize.getHeight(size: 125),
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => Image.asset(
//                     'assets/images/car.webp', // ✅ Fallback image
//                     width: double.infinity,
//                     height: ResponsiveSize.getHeight(size: 125),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       vehicle.model,
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 6),
//                     Row(
//                       children: [
//                         const Icon(Icons.directions_car, color: Colors.black54, size: 18),
//                         const SizedBox(width: 6),
//                         Text(
//                           vehicle.vrn,
//                           style: const TextStyle(
//                             color: Colors.black54,
//                             fontSize: 14,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// ✅ **Convert Vehicle Object to a Map<String, dynamic>**
//   Map<String, dynamic> _convertVehicleToMap(Vehicle vehicle) {
//     return {
//       "model": vehicle.model,
//       "vrn": vehicle.vrn,
//       "motValue": vehicle.motValue,
//       "insuranceValue": vehicle.insuranceValue,
//       "vehicleCategory": vehicle.vehicleCategory,
//       "ownerName": vehicle.ownerName,
//       "isActive": vehicle.isActive,
//       "purchasePrice": vehicle.purchasePrice,
//       "purchaseDate": vehicle.purchaseDate,
//       "motDate": vehicle.motDate,
//       "insuranceDate": vehicle.insuranceDate,
//       "imageURL": vehicle.imageURL,
//       "createdBy": vehicle.createdBy,
//       "createdDate": vehicle.createdDate,
//       "lastModifiedBy": vehicle.lastModifiedBy,
//       "lastModifiedDate": vehicle.lastModifiedDate,
//     };
//   }
// }