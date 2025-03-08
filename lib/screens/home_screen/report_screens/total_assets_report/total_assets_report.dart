import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/services/local/pdf_service/pdf_generate_for_all_assets.dart';
import '../../../../controllers/assets_controllers/assets_controller.dart';
import '../../../../utils/theme/font_size.dart';

class TotalAssetsReportScreen extends StatelessWidget {
  TotalAssetsReportScreen({super.key});

  final AssetController assetsController = Get.put(AssetController());

  Future<void> _refreshData() async {
    assetsController.fetchAssets();
  }

  Widget buildTable({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
                  color: Colors.teal.shade700,
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth, // Ensures responsiveness
                  ),
                  child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.teal.shade200),
                    dataRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.white),
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
                              width: 100,
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
              ),
            ],
          ),
        );
      },
    );
  }

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

                    return [assetType, count.toString(), 'LKR ${totalValue.toStringAsFixed(2)}'];
                  }).toList();

                  if (assetDetails.isEmpty) {
                    return SizedBox(
                      height: constraints.maxHeight * 0.7,
                      child: const Center(
                        child: Text(
                          'No Assets Available.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Card(
                      //   elevation: 4,
                      //   shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(12)),
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(
                      //         vertical: 12, horizontal: 16),
                      //     child: Text(
                      //       "Total Assets: ${assetsController.totalAssets.value}",
                      //       style: TextStyle(
                      //         fontSize: FontSizes.large,
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.black,
                      //       ),
                      //       textAlign: TextAlign.center,
                      //     ),
                      //   ),
                      // ),
                      buildTable(
                        title: "Assets Summary",
                        headers: ['Asset Type', 'Count', 'Total Value'],
                        rows: assetDetails,
                      ),
                    ],
                  );
                }),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.black,
          onPressed: () async {
            try {
              final allAssetsData = assetsController.filteredAssets;

              await PdfGeneratorForAll.generatePdf(
                  context, 'Total Assets', data: allAssetsData);

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
