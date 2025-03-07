import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/assets_controllers/assets_controller.dart';
import '../../../../services/local/pdf_service/pdf_generate_for_single_asset.dart';
import '../../../../utils/theme/app_theme_management.dart';
import '../../../../utils/theme/responsive_size.dart';
import '../../../../utils/theme/font_size.dart';

class VehicleReportScreen extends StatelessWidget {
  VehicleReportScreen({super.key});

  final AppThemeManager themeManager = Get.find();
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
            'Vehicle Reports',
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

            final vehicleAssets = assetsController.filteredAssets
                .where((asset) => asset['category'] == 'Vehicle')
                .toList();

            if (vehicleAssets.isEmpty) {
              return Center(
                child: Text(
                  'No Vehicles Available.',
                  style: TextStyle(
                    fontSize: ResponsiveSize.getHeight(size: 16),
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            // 📌 Show Total Vehicles Count at the Top
            final int totalVehicles = assetsController.totalVehicles.value;

            // Prepare table data
            final vehicleDetails = vehicleAssets.map((vehicle) {
              return [
                vehicle['vrn']?.toString() ?? 'N/A',
                vehicle['vehicleCategory']?.toString() ?? 'N/A',
                vehicle['model']?.toString() ?? 'N/A',
              ];
            }).toList();

            final motDetails = vehicleAssets.map((vehicle) {
              return [
                vehicle['vrn']?.toString() ?? 'N/A',
                vehicle['motValue']?.toString() ?? 'N/A',
                vehicle['motDate']?.toString() ?? 'N/A',
              ];
            }).toList();

            final insuranceDetails = vehicleAssets.map((vehicle) {
              return [
                vehicle['vrn']?.toString() ?? 'N/A',
                vehicle['insuranceValue']?.toString() ?? 'N/A',
                vehicle['insuranceDate']?.toString() ?? 'N/A',
              ];
            }).toList();

            final financeDetails = vehicleAssets.map((vehicle) {
              return [
                vehicle['vrn']?.toString() ?? 'N/A',
                vehicle['purchasePrice']?.toString() ?? 'N/A',
                vehicle['purchaseDate']?.toString() ?? 'N/A',
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
                        "Total Vehicles: $totalVehicles",
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
                        title: "Vehicle Details",
                        headers: ['Registration No', 'Vehicle Type', 'Model'],
                        rows: vehicleDetails,
                      ),
                      buildTable(
                        title: "MOT Details",
                        headers: ['Registration No', 'MOT Value', 'MOT Date'],
                        rows: motDetails,
                      ),
                      buildTable(
                        title: "Insurance Details",
                        headers: ['Registration No', 'Insurance Value', 'Insurance Date'],
                        rows: insuranceDetails,
                      ),
                      buildTable(
                        title: "Finance Details",
                        headers: ['Registration No', 'Purchase Price', 'Purchase Date'],
                        rows: financeDetails,
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
            final vehicleData = assetsController.filteredAssets
                .where((asset) => asset['category'] == 'Vehicle')
                .toList();
            PdfGenerator.generatePdf(context, 'Vehicle', data: vehicleData);
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
