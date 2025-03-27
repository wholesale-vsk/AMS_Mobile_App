import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/assets_controllers/assets_controller.dart';

import '../../../../services/local/pdf_service/pdf_generate_for_single_asset.dart';
import '../../../../utils/theme/font_size.dart';

class VehicleReportScreen extends StatefulWidget {
  const VehicleReportScreen({super.key});

  @override
  State<VehicleReportScreen> createState() => _VehicleReportScreenState();
}

class _VehicleReportScreenState extends State<VehicleReportScreen> {
  final AssetController assetsController = Get.put(AssetController());
  final RxString _selectedFilter = "All".obs;

  // Timer for auto-refresh functionality
  Timer? _autoRefreshTimer;
  // RxBool to track if auto-refresh is enabled
  final RxBool _isAutoRefreshEnabled = false.obs;
  // Default refresh interval in seconds
  final RxInt _refreshInterval = 60.obs; // 1 minute

  // Refresh data and show a snackbar with refresh status
  Future<void> _refreshData({bool showSnackbar = false}) async {
    try {
      await assetsController.fetchAllAssets(); // Ensure accurate data refresh

      if (showSnackbar) {
        Get.snackbar(
            "Refreshed",
            "Vehicle data updated successfully",
            backgroundColor: Colors.green.shade700,
            colorText: Colors.white,
            margin: const EdgeInsets.all(8),
            duration: const Duration(seconds: 2),
            borderRadius: 10,
            icon: const Icon(Icons.check_circle, color: Colors.white)
        );
      }
    } catch (e) {
      if (showSnackbar) {
        Get.snackbar(
            "Refresh Failed",
            "Could not update data: $e",
            backgroundColor: Colors.red.shade700,
            colorText: Colors.white,
            margin: const EdgeInsets.all(8),
            duration: const Duration(seconds: 3),
            borderRadius: 10,
            icon: const Icon(Icons.error, color: Colors.white)
        );
      }
    }
  }

  // Toggle auto-refresh functionality
  void _toggleAutoRefresh() {
    if (_isAutoRefreshEnabled.value) {
      // Disable auto-refresh
      _autoRefreshTimer?.cancel();
      _autoRefreshTimer = null;
      _isAutoRefreshEnabled.value = false;

      Get.snackbar(
          "Auto-Refresh Disabled",
          "Manual refresh is now required",
          backgroundColor: Colors.grey.shade700,
          colorText: Colors.white,
          margin: const EdgeInsets.all(8),
          duration: const Duration(seconds: 2),
          borderRadius: 10
      );
    } else {
      // Enable auto-refresh
      _isAutoRefreshEnabled.value = true;
      _startAutoRefreshTimer();

      Get.snackbar(
          "Auto-Refresh Enabled",
          "Data will refresh every ${_refreshInterval.value} seconds",
          backgroundColor: Colors.blue.shade700,
          colorText: Colors.white,
          margin: const EdgeInsets.all(8),
          duration: const Duration(seconds: 2),
          borderRadius: 10
      );
    }
  }

  // Start the auto-refresh timer with the current interval
  void _startAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
        Duration(seconds: _refreshInterval.value),
            (_) => _refreshData(showSnackbar: true)
    );
  }

  // Show a dialog to configure the refresh interval
  void _showRefreshIntervalDialog() {
    final TextEditingController intervalController = TextEditingController(
        text: _refreshInterval.value.toString()
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Set Refresh Interval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter refresh interval in seconds:'),
            const SizedBox(height: 16),
            TextField(
              controller: intervalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Seconds',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final int? newInterval = int.tryParse(intervalController.text);
              if (newInterval != null && newInterval > 0) {
                _refreshInterval.value = newInterval;
                if (_isAutoRefreshEnabled.value) {
                  _startAutoRefreshTimer(); // Restart timer with new interval
                }
                Get.back();
                Get.snackbar(
                    "Interval Updated",
                    "Refresh interval set to $_refreshInterval seconds",
                    backgroundColor: Colors.blue.shade700,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(8),
                    duration: const Duration(seconds: 2),
                    borderRadius: 10
                );
              } else {
                Get.snackbar(
                    "Invalid Value",
                    "Please enter a positive number",
                    backgroundColor: Colors.red.shade700,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(8),
                    duration: const Duration(seconds: 2),
                    borderRadius: 10
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Get filtered vehicles based on selected filter
  List<Map<String, dynamic>> _getFilteredVehicles() {
    final vehicleAssets = assetsController.filteredAssets
        .where((asset) => asset['category'] == 'Vehicle')
        .toList();

    if (_selectedFilter.value == 'All') {
      return vehicleAssets;
    }

    // Convert filter names to lowercase for case-insensitive comparison
    String filterType = _selectedFilter.value.toLowerCase();
    if (filterType == 'cars') {
      return vehicleAssets.where((v) =>
      (v['vehicle_type']?.toString().toLowerCase() ?? '').contains('car') ||
          // Also include vehicles where type might not explicitly say "car" but is a car model
          !(v['vehicle_type']?.toString().toLowerCase() ?? '').contains('truck') &&
              !(v['vehicle_type']?.toString().toLowerCase() ?? '').contains('bike') &&
              !(v['vehicle_type']?.toString().toLowerCase() ?? '').contains('motorcycle')
      ).toList();
    } else if (filterType == 'trucks') {
      return vehicleAssets.where((v) =>
      (v['vehicle_type']?.toString().toLowerCase() ?? '').contains('truck') ||
          (v['vehicle_type']?.toString().toLowerCase() ?? '').contains('lorry')
      ).toList();
    } else if (filterType == 'motorcycles') {
      return vehicleAssets.where((v) =>
      (v['vehicle_type']?.toString().toLowerCase() ?? '').contains('bike') ||
          (v['vehicle_type']?.toString().toLowerCase() ?? '').contains('motorcycle')
      ).toList();
    }

    return vehicleAssets;
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color.withOpacity(0.9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle, BuildContext context) {
    final registrationNo = vehicle['vrn']?.toString() ?? 'N/A';
    final vehicleType = vehicle['vehicle_type']?.toString() ?? 'N/A';
    final model = vehicle['model']?.toString() ?? 'N/A';
    final motValue = vehicle['motValue']?.toString() ?? 'N/A';
    final motDate = vehicle['motDate']?.toString() ?? 'N/A';
    final insuranceValue = vehicle['insuranceValue']?.toString() ?? 'N/A';
    final insuranceDate = vehicle['insuranceDate']?.toString() ?? 'N/A';
    final purchasePrice = vehicle['purchasePrice']?.toString() ?? 'N/A';
    final purchaseDate = vehicle['purchaseDate']?.toString() ?? 'N/A';

    // Determine icon based on vehicle type
    IconData vehicleIcon = Icons.directions_car;
    if (vehicleType.toLowerCase().contains('truck')) {
      vehicleIcon = Icons.local_shipping;
    } else if (vehicleType.toLowerCase().contains('bike') ||
        vehicleType.toLowerCase().contains('motorcycle')) {
      vehicleIcon = Icons.two_wheeler;
    } else if (vehicleType.toLowerCase().contains('bus')) {
      vehicleIcon = Icons.directions_bus;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.indigo.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                vehicleIcon,
                color: Colors.indigo.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    registrationNo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$vehicleType - $model",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Divider(color: Colors.grey.shade300),

          // MOT and Insurance Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Status Information",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusItem(
                      title: "MOT",
                      value: motValue,
                      date: motDate,
                      iconData: Icons.car_repair,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 16),
                    _buildStatusItem(
                      title: "Insurance",
                      value: insuranceValue,
                      date: insuranceDate,
                      iconData: Icons.security,
                      color: Colors.green.shade700,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Financial Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.payments, color: Colors.indigo.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Financial Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Purchase Price",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            purchasePrice,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Purchase Date",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            purchaseDate,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  // View detailed report
                },
                icon: const Icon(Icons.visibility, size: 20),
                label: const Text('View Details'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.indigo.shade700,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () async {
                  try {
                    final vehicleData = [vehicle];
                    await ModernPdfGenerator.generateReport(
                        context,
                        'Vehicle Details',
                        data: vehicleData,
                        companyName: 'Hexalyte Technology'
                    );
                    Get.snackbar(
                        "Success",
                        "PDF generated for $registrationNo",
                        backgroundColor: Colors.green.shade700,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(8),
                        borderRadius: 10,
                        icon: const Icon(Icons.check_circle, color: Colors.white)
                    );
                  } catch (e) {
                    Get.snackbar(
                        "Error",
                        "Failed to generate PDF: $e",
                        backgroundColor: Colors.red.shade700,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(8),
                        borderRadius: 10,
                        icon: const Icon(Icons.error, color: Colors.white)
                    );
                  }
                },
                icon: const Icon(Icons.picture_as_pdf, size: 20),
                label: const Text('Generate PDF'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required String title,
    required String value,
    required String date,
    required IconData iconData,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      "Value: ",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text(
                      "Date: ",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Vehicle Reports',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              // Show auto-refresh indicator if enabled
              Obx(() => _isAutoRefreshEnabled.value
                  ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync, size: 14, color: Colors.blue.shade800),
                    const SizedBox(width: 4),
                    Text(
                      '${_refreshInterval.value}s',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox.shrink()
              ),
            ],
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: () => _refreshData(showSnackbar: true),
              tooltip: 'Manual Refresh',
            ),
            Obx(() => IconButton(
              icon: Icon(
                _isAutoRefreshEnabled.value
                    ? Icons.timer : Icons.timer_off,
                color: _isAutoRefreshEnabled.value
                    ? Colors.blue.shade700 : Colors.black87,
              ),
              onPressed: _toggleAutoRefresh,
              tooltip: _isAutoRefreshEnabled.value
                  ? 'Disable Auto-refresh'
                  : 'Enable Auto-refresh',
            )),
            IconButton(
              icon: const Icon(Icons.timelapse, color: Colors.black87),
              onPressed: _showRefreshIntervalDialog,
              tooltip: 'Set Refresh Interval',
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.black87),
              onPressed: () {
                // Show filter options dialog
                Get.dialog(
                  AlertDialog(
                    title: const Text('Filter Vehicles'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('All Vehicles'),
                          leading: Radio<String>(
                            value: 'All',
                            groupValue: _selectedFilter.value,
                            onChanged: (value) {
                              _selectedFilter.value = value!;
                              Get.back();
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Cars'),
                          leading: Radio<String>(
                            value: 'Cars',
                            groupValue: _selectedFilter.value,
                            onChanged: (value) {
                              _selectedFilter.value = value!;
                              Get.back();
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Trucks'),
                          leading: Radio<String>(
                            value: 'Trucks',
                            groupValue: _selectedFilter.value,
                            onChanged: (value) {
                              _selectedFilter.value = value!;
                              Get.back();
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Motorcycles'),
                          leading: Radio<String>(
                            value: 'Motorcycles',
                            groupValue: _selectedFilter.value,
                            onChanged: (value) {
                              _selectedFilter.value = value!;
                              Get.back();
                            },
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Obx(() {
                if (assetsController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Get filtered vehicle list based on selected filter
                final filteredVehicles = _getFilteredVehicles();

                if (filteredVehicles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.no_crash,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter.value == 'All'
                              ? 'No Vehicles Available'
                              : 'No ${_selectedFilter.value} Available',
                          style: TextStyle(
                            fontSize: FontSizes.medium,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _refreshData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Data'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Calculate summary statistics for the filtered vehicles
                final int totalVehicles = filteredVehicles.length;

                // Calculate total purchase price
                double totalValue = 0.0;
                for (var vehicle in filteredVehicles) {
                  if (vehicle['purchasePrice'] != null) {
                    String valueString = vehicle['purchasePrice'].toString().replaceAll(',', '');
                    totalValue += double.tryParse(valueString) ?? 0.0;
                  }
                }

                // Count different vehicle types
                int cars = 0, trucks = 0, bikes = 0;
                for (var vehicle in filteredVehicles) {
                  final type = (vehicle['vehicle_type'] ?? '').toString().toLowerCase();
                  if (type.contains('car')) {
                    cars++;
                  } else if (type.contains('truck') || type.contains('lorry')) {
                    trucks++;
                  } else if (type.contains('bike') || type.contains('motorcycle')) {
                    bikes++;
                  }
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * 0.04,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      SizedBox(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth * 0.45,
                              child: _buildSummaryCard(
                                title: 'Total ${_selectedFilter.value == "All" ? "Vehicles" : _selectedFilter.value}',
                                value: totalVehicles.toString(),
                                icon: _selectedFilter.value == 'Cars'
                                    ? Icons.directions_car
                                    : _selectedFilter.value == 'Trucks'
                                    ? Icons.local_shipping
                                    : _selectedFilter.value == 'Motorcycles'
                                    ? Icons.two_wheeler
                                    : Icons.directions_car_filled,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth * 0.45,
                              child: _buildSummaryCard(
                                title: 'Total Value',
                                value: ' ${totalValue.toStringAsFixed(2)}',
                                icon: Icons.monetization_on,
                                color: Colors.indigo.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Filters
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        width: double.infinity,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Obx(() => Row(
                            children: [
                              _buildFilterChip('All', _selectedFilter.value == 'All', () => _selectedFilter.value = 'All'),
                              _buildFilterChip('Cars', _selectedFilter.value == 'Cars', () => _selectedFilter.value = 'Cars'),
                              _buildFilterChip('Trucks', _selectedFilter.value == 'Trucks', () => _selectedFilter.value = 'Trucks'),
                              _buildFilterChip('Motorcycles', _selectedFilter.value == 'Motorcycles', () => _selectedFilter.value = 'Motorcycles'),
                            ],
                          )),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Section Title with count
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              _selectedFilter.value == 'All'
                                  ? 'Vehicle List'
                                  : '${_selectedFilter.value} List',
                              style: TextStyle(
                                fontSize: FontSizes.medium,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$totalVehicles',
                                style: TextStyle(
                                  fontSize: FontSizes.small,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Vehicle Cards
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredVehicles.length,
                        itemBuilder: (context, index) {
                          return _buildVehicleCard(filteredVehicles[index], context);
                        },
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            try {
              // Get the filtered vehicles based on current filter
              final vehicleData = _getFilteredVehicles();

              // Generate report title based on the filter
              final reportTitle = _selectedFilter.value == 'All'
                  ? 'Vehicle Fleet Inventory'
                  : '${_selectedFilter.value} Fleet Inventory';

              await ModernPdfGenerator.generateReport(
                  context,
                  reportTitle,
                  data: vehicleData,
                  companyName: 'Hexalyte Technology'
              );

              Get.snackbar(
                  "Success",
                  "PDF report generated successfully!",
                  backgroundColor: Colors.green.shade700,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(8),
                  borderRadius: 10,
                  icon: const Icon(Icons.check_circle, color: Colors.white)
              );
            } catch (e) {
              Get.snackbar(
                  "Error",
                  "Failed to generate PDF: $e",
                  backgroundColor: Colors.red.shade700,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(8),
                  borderRadius: 10,
                  icon: const Icon(Icons.error, color: Colors.white)
              );
            }
          },
          label: Text(
              _selectedFilter.value == 'All'
                  ? "Generate Full Report"
                  : "Generate ${_selectedFilter.value} Report",
              style: const TextStyle(color: Colors.white)
          ),
          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          backgroundColor: Colors.indigo.shade700,
          elevation: 4,
        ),
      ),
    );
  }
}