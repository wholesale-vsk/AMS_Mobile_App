import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/services/local/pdf_service/pdf_generate_for_all_assets.dart';
import '../../../../controllers/assets_controllers/assets_controller.dart';
import '../../../../utils/theme/app_theme_management.dart';
import '../../../../utils/theme/responsive_size.dart';

class TotalAssetsReportScreen extends StatelessWidget {
  TotalAssetsReportScreen({super.key});

  final AppThemeManager themeManager = Get.find();
  final AssetController assetsController = Get.put(AssetController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Total Assets Report',
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
            horizontal: ResponsiveSize.getWidth(size: 16),
            vertical: ResponsiveSize.getHeight(size: 10),
          ),
          child: Obx(() {
            if (assetsController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            // Group assets by category
            final Map<String, List<Map<String, dynamic>>> groupedAssets = {};

            for (var asset in assetsController.filteredAssets) {
              String type = asset['category'] ?? 'Unknown';
              groupedAssets.putIfAbsent(type, () => []).add(asset);
            }

            // Prepare data for the table
            final List<List<String>> assetDetails = groupedAssets.entries.map((entry) {
              String assetType = entry.key;
              int count = entry.value.length;
              double totalValue = entry.value.fold(0.0, (sum, asset) {
                double value = 0.0;
                if (asset['purchasePrice'] != null) {
                  String valueString = asset['purchasePrice'].toString().replaceAll(',', '');
                  value = double.tryParse(valueString) ?? 0.0;
                }
                return sum + value;
              });

              return [assetType, count.toString(), ' ${totalValue.toStringAsFixed(2)}'];
            }).toList();

            if (assetDetails.isEmpty) {
              return const Center(
                child: Text(
                  'No Assets Available.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              );
            }

            return Column(
              children: [
                // 📌 Total Assets Count
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Text(
                        "Total Assets: ${assetsController.totalAssets.value}",
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
                // 📌 Asset Table
                Expanded(
                  child: ListView(
                    children: [
                      _buildTable(
                        headers: ['Asset Type', 'Count', 'Total Value'],
                        rows: assetDetails,
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
            final allAssetsData = assetsController.filteredAssets;
            PdfGeneratorForAll.generatePdf(context, 'Total Assets', data: allAssetsData);
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

  //:::::::::::::::::::::::::::::::::<< TABLE BUILDER >>::::::::::::::::::::::::::::::::://
  Widget _buildTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Table Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: headers.map((header) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      header,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
                            fontSize: 14,
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
}
