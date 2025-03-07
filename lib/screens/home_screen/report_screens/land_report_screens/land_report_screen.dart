import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/assets_controllers/assets_controller.dart';
import '../../../../services/local/pdf_service/pdf_generate_for_single_asset.dart';
import '../../../../utils/theme/responsive_size.dart';
import '../../../../utils/widgets/app_bar/appbar_component.dart';
import 'package:hexalyte_ams/utils/theme/font_size.dart';

class LandReportScreen extends StatelessWidget {
  LandReportScreen({super.key});

  final AssetController assetsController = Get.put(AssetController());

  Widget buildTable({required String title, required List<String> headers, required List<List<String>> rows}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table Title
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: FontSizes.large,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Divider(thickness: 1.2, color: Colors.grey.withOpacity(0.5)),
            // Table Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: headers.map((header) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      header,
                      style: TextStyle(
                        fontSize: FontSizes.medium,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            ),
            Divider(thickness: 1.2, color: Colors.grey.withOpacity(0.5)),
            // Table Rows
            ...rows.map((row) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: row.map((cell) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          cell,
                          style: TextStyle(
                            fontSize: FontSizes.small,
                            color: Colors.black.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Land Reports',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white, // ✅ No header color
          automaticallyImplyLeading: false, // ✅ Removes back button
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveSize.getWidth(size: 18),
            vertical: ResponsiveSize.getHeight(size: 10),
          ),
          child: Obx(() {
            if (assetsController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final landAssets = assetsController.filteredAssets
                .where((asset) => asset['category'] == 'Land')
                .toList();

            if (landAssets.isEmpty) {
              return Center(
                child: Text(
                  'No Land Available.',
                  style: TextStyle(
                    fontSize: ResponsiveSize.getHeight(size: 16),
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            // 📌 Show Total Lands Count at the Top
            final int totalLands = assetsController.totalLands.value;

            // Prepare table data
            final landDetails = landAssets.map((land) {
              return [
                land['name']?.toString() ?? 'N/A',
                land['type']?.toString() ?? 'N/A',
                land['size']?.toString() ?? 'N/A',
              ];
            }).toList();

            final locationDetails = landAssets.map((land) {
              return [
                land['name']?.toString() ?? 'N/A',
                land['address']?.toString() ?? 'N/A',
                land['city']?.toString() ?? 'N/A',
                land['province']?.toString() ?? 'N/A',
              ];
            }).toList();

            final financialDetails = landAssets.map((land) {
              double value = 0.0;
              if (land['purchasePrice'] != null) {
                String valueString = land['purchasePrice'].toString().replaceAll(',', '');
                value = double.tryParse(valueString) ?? 0.0;
              }
              return [
                land['name']?.toString() ?? 'N/A',
                land['purchaseDate']?.toString() ?? 'N/A',
                ' ${value.toStringAsFixed(2)}',
              ];
            }).toList();

            return Column(
              children: [
                // 📌 Total Count Widget
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Text(
                        "Total Lands: $totalLands",
                        style: TextStyle(
                          fontSize: ResponsiveSize.getHeight(size: 18),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      buildTable(
                        title: "Land Details",
                        headers: ['Name', 'Land Type', 'Size'],
                        rows: landDetails,
                      ),
                      buildTable(
                        title: "Location Details",
                        headers: ['Name', 'Address', 'City', 'Province'],
                        rows: locationDetails,
                      ),
                      buildTable(
                        title: "Financial Details",
                        headers: ['Name', 'Purchase Date', 'Value'],
                        rows: financialDetails,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.black,
          onPressed: () {
            final landData = assetsController.filteredAssets
                .where((asset) => asset['category'] == 'Land')
                .toList();
            PdfGenerator.generatePdf(context, 'Land', data: landData);
          },
          label: const Text(
            "Generate PDF",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: const Icon(Icons.print_rounded, color: Colors.white),
        ),
      ),
    );
  }
}
