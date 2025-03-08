import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/assets_controllers/assets_controller.dart';
import '../../../../services/local/pdf_service/pdf_generate_for_single_asset.dart';
import '../../../../utils/theme/font_size.dart';

class LandReportScreen extends StatefulWidget {
  const LandReportScreen({super.key});

  @override
  _LandReportScreenState createState() => _LandReportScreenState();
}

class _LandReportScreenState extends State<LandReportScreen>
    with AutomaticKeepAliveClientMixin {
  final AssetController assetsController = Get.find<AssetController>();

  @override
  bool get wantKeepAlive => true;

  Future<void> _refreshData() async {
    assetsController.fetchAssets(); // Refresh the data
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
                  color: Colors.green.shade700,
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
                            (states) => Colors.green.shade200),
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
    super.build(context);

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

                  final landAssets = assetsController.filteredAssets
                      .where((asset) => asset['category'] == 'Land')
                      .toList();

                  if (landAssets.isEmpty) {
                    return SizedBox(
                      height: constraints.maxHeight * 0.7,
                      child: Center(
                        child: Text(
                          'No Lands Available.',
                          style: TextStyle(
                            fontSize: FontSizes.medium,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  final int totalLands = assetsController.totalLands.value;

                  List<List<String>> landDetails = [];
                  List<List<String>> locationDetails = [];
                  List<List<String>> financialDetails = [];

                  for (var land in landAssets) {
                    String name = land['name']?.toString() ?? 'N/A';
                    String type = land['type']?.toString() ?? 'N/A';
                    String size = land['size']?.toString() ?? 'N/A';
                    String address = land['address']?.toString() ?? 'N/A';
                    String city = land['city']?.toString() ?? 'N/A';
                    String province = land['province']?.toString() ?? 'N/A';
                    String purchaseDate =
                        land['purchaseDate']?.toString() ?? 'N/A';

                    double value = 0.0;
                    if (land['purchasePrice'] != null) {
                      String valueString =
                      land['purchasePrice'].toString().replaceAll(',', '');
                      value = double.tryParse(valueString) ?? 0.0;
                    }

                    landDetails.add([name, type, size]);
                    locationDetails.add([name, address, city, province]);
                    financialDetails
                        .add([name, purchaseDate, 'LKR ${value.toStringAsFixed(2)}']);
                  }

                  return Column(
                    children: [
                      // Total Count Widget

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
              final landData = assetsController.filteredAssets
                  .where((asset) => asset['category'] == 'Land')
                  .toList();

              await PdfGenerator.generatePdf(context, 'Land', data: landData);

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
