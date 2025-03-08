import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/assets_controllers/assets_controller.dart';
import '../../../../services/local/pdf_service/pdf_generate_for_single_asset.dart';
import '../../../../utils/theme/font_size.dart';

class VehicleReportScreen extends StatelessWidget {
  VehicleReportScreen({super.key});

  final AssetController assetsController = Get.put(AssetController());

  Future<void> _refreshData() async {
    await assetsController.fetchAllAssets(); // Ensure accurate data refresh
  }

  Widget buildTable({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: FontSizes.large,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Scrollable Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
              MaterialStateColor.resolveWith((states) => Colors.blue.shade200),
              dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
              columnSpacing: 20,
              columns: headers
                  .map((header) => DataColumn(
                label: Text(
                  header,
                  style: TextStyle(
                    fontSize: FontSizes.medium,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ))
                  .toList(),
              rows: rows
                  .map(
                    (row) => DataRow(
                  cells: row
                      .map(
                        (cell) => DataCell(
                      SizedBox(
                        width: 120, // Responsive width
                        child: Text(
                          cell,
                          style: TextStyle(
                            fontSize: FontSizes.small,
                            color: Colors.black.withOpacity(0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
              )
                  .toList(),
            ),
          ),
        ],
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
          elevation: 2,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: _refreshData,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.05,
                  vertical: constraints.maxHeight * 0.02,
                ),
                child: Obx(() {
                  if (assetsController.isLoading.value) {
                    return SizedBox(
                      height: constraints.maxHeight * 0.7,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  final vehicleAssets = assetsController.filteredAssets
                      .where((asset) => asset['category'] == 'Vehicle')
                      .toList();

                  if (vehicleAssets.isEmpty) {
                    return SizedBox(
                      height: constraints.maxHeight * 0.7,
                      child: Center(
                        child: Text(
                          'No Vehicles Available.',
                          style: TextStyle(
                            fontSize: FontSizes.medium,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  final int totalVehicles = assetsController.totalVehicles.value;

                  List<List<String>> vehicleDetails = [];
                  List<List<String>> motDetails = [];
                  List<List<String>> insuranceDetails = [];
                  List<List<String>> financeDetails = [];

                  for (var vehicle in vehicleAssets) {
                    vehicleDetails.add([
                      vehicle['vrn']?.toString() ?? 'N/A',
                      vehicle['vehicleCategory']?.toString() ?? 'N/A',
                      vehicle['model']?.toString() ?? 'N/A',
                    ]);
                    motDetails.add([
                      vehicle['vrn']?.toString() ?? 'N/A',
                      vehicle['motValue']?.toString() ?? 'N/A',
                      vehicle['motDate']?.toString() ?? 'N/A',
                    ]);
                    insuranceDetails.add([
                      vehicle['vrn']?.toString() ?? 'N/A',
                      vehicle['insuranceValue']?.toString() ?? 'N/A',
                      vehicle['insuranceDate']?.toString() ?? 'N/A',
                    ]);
                    financeDetails.add([
                      vehicle['vrn']?.toString() ?? 'N/A',
                      vehicle['purchasePrice']?.toString() ?? 'N/A',
                      vehicle['purchaseDate']?.toString() ?? 'N/A',
                    ]);
                  }

                  return Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Text(
                            "Total Vehicles: $totalVehicles",
                            style: TextStyle(
                              fontSize: FontSizes.large,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
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
                        headers: [
                          'Registration No',
                          'Insurance Value',
                          'Insurance Date'
                        ],
                        rows: insuranceDetails,
                      ),
                      buildTable(
                        title: "Finance Details",
                        headers: [
                          'Registration No',
                          'Purchase Price',
                          'Purchase Date'
                        ],
                        rows: financeDetails,
                      ),
                    ],
                  );
                }),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.blue.shade700,
          onPressed: () async {
            try {
              final vehicleData = assetsController.filteredAssets
                  .where((asset) => asset['category'] == 'Vehicle')
                  .toList();

              await PdfGenerator.generatePdf(context, 'Vehicle', data: vehicleData);

              Get.snackbar("Success", "PDF generated successfully!",
                  backgroundColor: Colors.green, colorText: Colors.white);
            } catch (e) {
              Get.snackbar("Error", "Failed to generate PDF: $e",
                  backgroundColor: Colors.red, colorText: Colors.white);
            }
          },
          label: const Text("Generate PDF", style: TextStyle(color: Colors.white)),
          icon: const Icon(Icons.print_rounded, color: Colors.white),
        ),
      ),
    );
  }
}
