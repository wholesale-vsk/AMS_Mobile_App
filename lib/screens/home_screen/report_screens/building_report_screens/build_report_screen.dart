// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../../controllers/assets_controllers/assets_controller.dart';
//
// import '../../../../services/local/pdf_service/pdf_generate_for_single_asset.dart';
// import '../../../../utils/theme/font_size.dart';
//
// class BuildingReportScreen extends StatefulWidget {
//   const BuildingReportScreen({super.key});
//
//   @override
//   _BuildingReportScreenState createState() => _BuildingReportScreenState();
// }
//
// class _BuildingReportScreenState extends State<BuildingReportScreen>
//     with AutomaticKeepAliveClientMixin {
//   final AssetController assetsController = Get.find<AssetController>();
//
//   @override
//   bool get wantKeepAlive => true;
//
//   Future<void> _refreshData() async {
//     assetsController.fetchAssets(); // Refresh the data
//   }
//
//   Widget _buildSummaryCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [color.withOpacity(0.7), color.withOpacity(0.9)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: Colors.white, size: 24),
//                 const SizedBox(width: 10),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBuildingCard(Map<String, dynamic> building, BuildContext context) {
//     final name = building['name']?.toString() ?? 'N/A';
//     final buildingType = building['buildingType']?.toString() ?? 'N/A';
//     final size = building['size']?.toString() ?? 'N/A';
//     final address = building['address']?.toString() ?? 'N/A';
//     final city = building['city']?.toString() ?? 'N/A';
//     final province = building['province']?.toString() ?? 'N/A';
//     final purchaseDate = building['purchaseDate']?.toString() ?? 'N/A';
//
//     double value = 0.0;
//     if (building['purchasePrice'] != null) {
//       String valueString = building['purchasePrice'].toString().replaceAll(',', '');
//       value = double.tryParse(valueString) ?? 0.0;
//     }
//
//     return Card(
//       elevation: 3,
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: ExpansionTile(
//         tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         expandedCrossAxisAlignment: CrossAxisAlignment.start,
//         childrenPadding: const EdgeInsets.all(16),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade100,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(
//                 Icons.business,
//                 color: Colors.blue,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     buildingType,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         children: [
//           Divider(color: Colors.grey.shade300),
//           Row(
//             children: [
//               _buildInfoItem(Icons.square_foot, 'Size', size),
//               _buildInfoItem(Icons.location_on, 'Location', "$city, $province"),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               _buildInfoItem(Icons.calendar_today, 'Purchase Date', purchaseDate),
//               _buildInfoItem(Icons.monetization_on, 'Value', 'LKR ${value.toStringAsFixed(2)}'),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Icon(Icons.home_work, color: Colors.blueGrey),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Address',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         address,
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               TextButton.icon(
//                 onPressed: () {
//                   // View detailed report
//                 },
//                 icon: const Icon(Icons.visibility, size: 20),
//                 label: const Text('View Details'),
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.blue,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               TextButton.icon(
//                 onPressed: () async {
//                   try {
//                     final buildingData = [building];
//                     await ModernPdfGenerator.generateReport(
//                         context,
//                         'Building',
//                         data: buildingData,
//                         companyName: 'Hexalyte Technology'
//                     );
//                     Get.snackbar(
//                         "Success",
//                         "PDF generated for $name",
//                         backgroundColor: Colors.green.shade700,
//                         colorText: Colors.white,
//                         borderRadius: 10,
//                         margin: const EdgeInsets.all(8),
//                         icon: const Icon(Icons.check_circle, color: Colors.white)
//                     );
//                   } catch (e) {
//                     Get.snackbar(
//                         "Error",
//                         "Failed to generate PDF: $e",
//                         backgroundColor: Colors.red.shade700,
//                         colorText: Colors.white,
//                         borderRadius: 10,
//                         margin: const EdgeInsets.all(8),
//                         icon: const Icon(Icons.error, color: Colors.white)
//                     );
//                   }
//                 },
//                 icon: const Icon(Icons.picture_as_pdf, size: 20),
//                 label: const Text('Generate PDF'),
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.red,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoItem(IconData icon, String label, String value) {
//     return Expanded(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 18, color: Colors.blueGrey),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterChip(String label, bool isSelected, Function() onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(right: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue : Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: isSelected ? Colors.white : Colors.black87,
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.grey.shade50,
//         appBar: AppBar(
//           title: const Text(
//             'Building Reports',
//             style: TextStyle(
//               color: Colors.black87,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           centerTitle: true,
//           elevation: 0,
//           backgroundColor: Colors.white,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.black87),
//             onPressed: () => Get.back(),
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.refresh, color: Colors.black87),
//               onPressed: _refreshData,
//             ),
//             IconButton(
//               icon: const Icon(Icons.filter_list, color: Colors.black87),
//               onPressed: () {
//                 // Open filter options
//               },
//             ),
//           ],
//         ),
//         body: RefreshIndicator(
//           onRefresh: _refreshData,
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               return Obx(() {
//                 if (assetsController.isLoading.value) {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }
//
//                 final buildingAssets = assetsController.filteredAssets
//                     .where((asset) => asset['category'] == 'Building')
//                     .toList();
//
//                 if (buildingAssets.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.domain_disabled,
//                           size: 64,
//                           color: Colors.grey.shade400,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No Buildings Available',
//                           style: TextStyle(
//                             fontSize: FontSizes.medium,
//                             color: Colors.grey.shade600,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         ElevatedButton.icon(
//                           onPressed: _refreshData,
//                           icon: const Icon(Icons.refresh),
//                           label: const Text('Refresh Data'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue,
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//
//                 final int totalBuildings = assetsController.totalBuildings.value;
//                 double totalValue = 0.0;
//                 for (var building in buildingAssets) {
//                   if (building['purchasePrice'] != null) {
//                     String valueString = building['purchasePrice'].toString().replaceAll(',', '');
//                     totalValue += double.tryParse(valueString) ?? 0.0;
//                   }
//                 }
//
//                 return SingleChildScrollView(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: constraints.maxWidth * 0.04,
//                     vertical: 16,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Summary Cards
//                       SizedBox(
//                         height: 120,
//                         child: ListView(
//                           scrollDirection: Axis.horizontal,
//                           children: [
//                             SizedBox(
//                               width: constraints.maxWidth * 0.45,
//                               child: _buildSummaryCard(
//                                 title: 'Total Buildings',
//                                 value: totalBuildings.toString(),
//                                 icon: Icons.home_work,
//                                 color: Colors.blue,
//                               ),
//                             ),
//                             SizedBox(
//                               width: constraints.maxWidth * 0.45,
//                               child: _buildSummaryCard(
//                                 title: 'Total Value',
//                                 value: ' ${totalValue.toStringAsFixed(2)}',
//                                 icon: Icons.monetization_on,
//                                 color: Colors.green,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 20),
//
//                       // Filters
//                       Container(
//                         padding: const EdgeInsets.symmetric(vertical: 8),
//                         width: double.infinity,
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: Row(
//                             children: [
//                               _buildFilterChip('All', true, () {}),
//                               _buildFilterChip('Commercial', false, () {}),
//                               _buildFilterChip('Residential', false, () {}),
//                               _buildFilterChip('Industrial', false, () {}),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       // Section Title
//                       Padding(
//                         padding: const EdgeInsets.only(left: 4, bottom: 8),
//                         child: Text(
//                           'Building List',
//                           style: TextStyle(
//                             fontSize: FontSizes.medium,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ),
//
//                       // Building Cards
//                       ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: buildingAssets.length,
//                         itemBuilder: (context, index) {
//                           return _buildBuildingCard(buildingAssets[index], context);
//                         },
//                       ),
//                     ],
//                   ),
//                 );
//               });
//             },
//           ),
//         ),
//         floatingActionButton: FloatingActionButton.extended(
//           onPressed: () async {
//             try {
//               final buildingsData = assetsController.filteredAssets
//                   .where((asset) => asset['category'] == 'Building')
//                   .toList();
//
//               await ModernPdfGenerator.generateReport(
//                   context,
//                   'Buildings Inventory',
//                   data: buildingsData,
//                   companyName: 'Hexalyte Technology'
//               );
//
//               Get.snackbar(
//                   "Success",
//                   "PDF report generated successfully!",
//                   backgroundColor: Colors.green.shade700,
//                   colorText: Colors.white,
//                   margin: const EdgeInsets.all(8),
//                   borderRadius: 10,
//                   icon: const Icon(Icons.check_circle, color: Colors.white)
//               );
//             } catch (e) {
//               Get.snackbar(
//                   "Error",
//                   "Failed to generate PDF: $e",
//                   backgroundColor: Colors.red.shade700,
//                   colorText: Colors.white,
//                   margin: const EdgeInsets.all(8),
//                   borderRadius: 10,
//                   icon: const Icon(Icons.error, color: Colors.white)
//               );
//             }
//           },
//           label: const Text("Generate Full Report", style: TextStyle(color: Colors.white)),
//           icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
//           backgroundColor: Colors.blue.shade700,
//           elevation: 4,
//         ),
//       ),
//     );
//   }
// }