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

  Widget buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: FontSizes.small,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: FontSizes.large,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table Title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade700, Colors.teal.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pie_chart, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: FontSizes.large,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
                            (states) => Colors.teal.shade50),
                    dataRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.white),
                    columnSpacing: 20,
                    dividerThickness: 1,
                    headingRowHeight: 56,
                    dataRowHeight: 52,
                    columns: headers
                        .map((header) => DataColumn(
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          header,
                          style: TextStyle(
                            fontSize: FontSizes.medium,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ),
                    ))
                        .toList(),
                    rows: rows
                        .map(
                          (row) => DataRow(
                        cells: row
                            .map(
                              (cell) => DataCell(
                            Container(
                              constraints: const BoxConstraints(
                                minWidth: 100,
                                maxWidth: 180,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  cell,
                                  style: TextStyle(
                                    fontSize: FontSizes.small,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
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
              const SizedBox(height: 16),
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
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Total Assets Report',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
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
          color: Colors.teal.shade700,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.05,
                  vertical: 20,
                ),
                child: Obx(() {
                  if (assetsController.isLoading.value) {
                    return SizedBox(
                      height: constraints.maxHeight * 0.7,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.teal.shade700,
                        ),
                      ),
                    );
                  }

                  // Group assets by category
                  final Map<String, List<Map<String, dynamic>>> groupedAssets = {};

                  for (var asset in assetsController.filteredAssets) {
                    String type = asset['category'] ?? 'Unknown';
                    groupedAssets.putIfAbsent(type, () => []).add(asset);
                  }

                  // Calculate totals
                  int totalCount = assetsController.filteredAssets.length;
                  double totalValue = 0.0;
                  int categoryCount = groupedAssets.length;

                  // Prepare data for the table
                  final List<List<String>> assetDetails = groupedAssets.entries.map((entry) {
                    String assetType = entry.key;
                    int count = entry.value.length;
                    double categoryValue = entry.value.fold(0.0, (sum, asset) {
                      double value = 0.0;
                      if (asset['purchasePrice'] != null) {
                        String valueString = asset['purchasePrice'].toString().replaceAll(',', '');
                        value = double.tryParse(valueString) ?? 0.0;
                      }
                      return sum + value;
                    });

                    totalValue += categoryValue;

                    return [
                      assetType,
                      count.toString(),
                      '${categoryValue.toStringAsFixed(2)}',
                      '${((count / totalCount) * 100).toStringAsFixed(1)}%'
                    ];
                  }).toList();

                  if (assetDetails.isEmpty) {
                    return SizedBox(
                      height: constraints.maxHeight * 0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 70,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Assets Available',
                              style: TextStyle(
                                fontSize: FontSizes.large,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add assets to view your report',
                              style: TextStyle(
                                fontSize: FontSizes.small,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                        child: Text(
                          "Assets Overview",
                          style: TextStyle(
                            fontSize: FontSizes.medium,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      GridView.count(
                        crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          buildSummaryCard(
                            title: "Total Assets",
                            value: totalCount.toString(),
                            icon: Icons.inventory,
                            color: Colors.blue,
                          ),
                          buildSummaryCard(
                            title: "Categories",
                            value: categoryCount.toString(),
                            icon: Icons.category,
                            color: Colors.orange,
                          ),
                          buildSummaryCard(
                            title: "Total Value",
                            value: " ${totalValue.toStringAsFixed(2)}",
                            icon: Icons.attach_money,
                            color: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Assets Table
                      buildTable(
                        title: "Assets by Category",
                        headers: ['Category', 'Count', 'Value', 'Percentage'],
                        rows: assetDetails,
                      ),

                      const SizedBox(height: 70), // Space for FAB
                    ],
                  );
                }),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.teal.shade700,
          onPressed: () async {
            try {
              Get.dialog(
                Center(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          const Text(
                            "Generating PDF...",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                barrierDismissible: false,
              );

              final allAssetsData = assetsController.filteredAssets;
              await PdfGeneratorForAll.generatePdf(
                  context, 'Total Assets', data: allAssetsData);

              Get.back(); // Close the loading dialog
              Get.snackbar(
                "Success",
                "PDF generated successfully!",
                backgroundColor: Colors.green,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                icon: const Icon(Icons.check_circle, color: Colors.white),
              );
            } catch (e) {
              Get.back(); // Close the loading dialog
              Get.snackbar(
                "Error",
                "Failed to generate PDF: $e",
                backgroundColor: Colors.red,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                icon: const Icon(Icons.error, color: Colors.white),
              );
            }
          },
          label: const Text("Generate PDF", style: TextStyle(color: Colors.white)),
          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
        ),
      ),
    );
  }
}