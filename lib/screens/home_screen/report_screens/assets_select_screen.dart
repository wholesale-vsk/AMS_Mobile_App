import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../../controllers/Asset_Report_Controller/Asset_Report_Controller.dart';

class AssetsSelectForReports extends StatelessWidget {
  final AssetReportController _reportController = Get.put(AssetReportController());
  final Logger _logger = Logger();

  AssetsSelectForReports({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    final Color backgroundColor = isDarkMode
        ? Color(0xFF121212)
        : Color(0xFFF5F7FA);
    final Color cardColor = isDarkMode
        ? Color(0xFF1E1E1E)
        : Colors.white;
    final Color textColor = isDarkMode
        ? Colors.white
        : Color(0xFF2D3142);
    final Color subtitleColor = isDarkMode
        ? Colors.grey[400]!
        : Color(0xFF9A9A9A);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Generate Asset Report',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Add a refresh button
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              _reportController.refreshAssets();
              Get.snackbar(
                "Refreshing",
                "Updating asset data...",
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 2),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          // Show loading indicator when initially loading data
          if (_reportController.isLoading.value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading asset data...',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          // Show error view if there's an error
          if (_reportController.hasError.value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error Loading Assets',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _reportController.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _reportController.refreshAssets(),
                    icon: Icon(Icons.refresh),
                    label: Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          // No assets available
          if (_reportController.assets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: subtitleColor,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Assets Found',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Add assets to generate reports',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.add),
                    label: Text('Add Assets'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Get.theme.primaryColor,
                      side: BorderSide(color: Get.theme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Asset count indicator
                    _buildAssetCountIndicator(textColor, subtitleColor),
                    SizedBox(height: 20),

                    _buildSectionTitle('Select Asset Types', Icons.category_rounded, textColor),
                    SizedBox(height: 12),
                    _buildAssetTypeSelector(cardColor, textColor),
                    SizedBox(height: 24),

                    // Only show property types if Building is selected
                    Obx(() {
                      if (_reportController.selectedAssetTypes.contains('Building') ||
                          _reportController.selectedAssetTypes.contains('Land')) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Select Property Types', Icons.home_work_rounded, textColor),
                            SizedBox(height: 12),
                            _buildBuildingTypeSelector(cardColor, textColor),
                            SizedBox(height: 24),
                          ],
                        );
                      }
                      return SizedBox.shrink();
                    }),

                    // Only show vehicle types if Vehicle is selected
                    Obx(() {
                      if (_reportController.selectedAssetTypes.contains('Vehicle')) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Select Vehicle Types', Icons.directions_car_rounded, textColor),
                            SizedBox(height: 12),
                            _buildVehicleTypeSelector(cardColor, textColor),
                            SizedBox(height: 24),
                          ],
                        );
                      }
                      return SizedBox.shrink();
                    }),

                    _buildSectionTitle('Report Type', Icons.description_rounded, textColor),
                    SizedBox(height: 12),
                    _buildReportTypeSelector(cardColor, textColor, subtitleColor),
                    SizedBox(height: 24),

                    _buildSectionTitle('Date Range', Icons.calendar_today_rounded, textColor),
                    SizedBox(height: 12),
                    _buildDateRangeSelector(context, cardColor, textColor, subtitleColor),
                    SizedBox(height: 24),

                    _buildSectionTitle('Additional Options', Icons.tune_rounded, textColor),
                    SizedBox(height: 12),
                    _buildAdditionalOptions(cardColor, textColor, subtitleColor),
                    SizedBox(height: 36),

                    _buildGenerateButton(context),
                    SizedBox(height: 24),
                  ],
                ),
              ),
              // Show overlay when generating report
              if (_reportController.isGeneratingReport.value)
                _buildLoadingOverlay(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAssetCountIndicator(Color textColor, Color subtitleColor) {
    return Obx(() {
      // Get filtered asset count
      final filteredAssets = _reportController.getFilteredAssets();
      final totalAssets = _reportController.assets.length;
      final isFiltered = filteredAssets.length != totalAssets || _reportController.selectedAssetTypes.length < 3;

      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Get.theme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2_rounded,
                  color: Get.theme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isFiltered
                        ? Text(
                      '${filteredAssets.length} of ${totalAssets} Assets Selected',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                        : Text(
                      '${totalAssets} Assets Available',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Adjust filters to customize your report',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Show total value if we have assets selected
            if (filteredAssets.isNotEmpty) ...[
              SizedBox(height: 12),
              Divider(height: 1, thickness: 1, color: Get.theme.primaryColor.withOpacity(0.1)),
              SizedBox(height: 12),
              _buildAssetValueSummary(filteredAssets, textColor, subtitleColor),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildAssetValueSummary(List<Map<String, dynamic>> assets, Color textColor, Color subtitleColor) {
    // Calculate total value
    double totalValue = 0;
    for (var asset in assets) {
      var price = asset['purchasePrice'];
      if (price != null && price != 'N/A') {
        double? numValue = _parseNumber(price);
        if (numValue != null) {
          totalValue += numValue;
        }
      }
    }

    // Count by category
    Map<String, int> categoryCounts = {};
    for (var asset in assets) {
      String category = asset['category'] ?? 'Unknown';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    return Row(
      children: [
        Expanded(
          child: _buildCountTag('Total Value', '${_formatCurrency(totalValue)}', Icons.attach_money_rounded),
        ),
        SizedBox(width: 12),

        if (categoryCounts.containsKey('Building'))
          Expanded(
            child: _buildCountTag('Buildings', '${categoryCounts['Building']}', Icons.business_rounded),
          ),

        if (categoryCounts.containsKey('Vehicle'))
          Expanded(
            child: _buildCountTag('Vehicles', '${categoryCounts['Vehicle']}', Icons.directions_car_rounded),
          ),

        if (categoryCounts.containsKey('Land'))
          Expanded(
            child: _buildCountTag('Lands', '${categoryCounts['Land']}', Icons.landscape_rounded),
          ),
      ],
    );
  }

  Widget _buildCountTag(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Get.theme.primaryColor,
          ),
          SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.primaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: _reportController.reportProgress.value,
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation<Color>(Get.theme.primaryColor),
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Generating ${_reportController.reportType.value}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _getGenerationStatusText(_reportController.reportProgress.value),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '${(_reportController.reportProgress.value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Get.theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGenerationStatusText(double progress) {
    if (progress < 0.3) {
      return 'Collecting asset data...';
    } else if (progress < 0.6) {
      return 'Creating report content...';
    } else if (progress < 0.9) {
      return 'Generating PDF document...';
    } else {
      return 'Finalizing report...';
    }
  }

  Widget _buildSectionTitle(String title, IconData icon, Color textColor) {
    return Row(
      children: [
        Icon(
          icon,
          color: Get.theme.primaryColor,
          size: 22,
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAssetTypeSelector(Color cardColor, Color textColor) {
    return Obx(() {
      final filteredCategories = _reportController.categories
          .where((category) => category != 'All')
          .toList();

      return Card(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select the types of assets to include in the report',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: filteredCategories
                    .map((assetType) => _buildAssetTypeChip(assetType))
                    .toList(),
              ),

              // Show select all / clear all buttons
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _reportController.selectedAssetTypes.value = [
                        'Building', 'Vehicle', 'Land'
                      ];
                    },
                    icon: Icon(Icons.select_all, size: 16),
                    label: Text('Select All'),
                    style: TextButton.styleFrom(
                      foregroundColor: Get.theme.primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  if (_reportController.selectedAssetTypes.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        _reportController.selectedAssetTypes.clear();
                      },
                      icon: Icon(Icons.clear_all, size: 16),
                      label: Text('Clear All'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBuildingTypeSelector(Color cardColor, Color textColor) {
    return Obx(() {
      final buildingTypes = _reportController.buildingTypes;

      return Card(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select the property types to include in the report',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'These filters apply to Building and Land assets only',
                style: TextStyle(
                  color: textColor.withOpacity(0.5),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: buildingTypes
                    .map((buildingType) => _buildBuildingTypeChip(buildingType))
                    .toList(),
              ),

              // Show select all / clear all buttons
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _reportController.selectedBuildingTypes.value =
                      List<String>.from(_reportController.buildingTypes);
                    },
                    icon: Icon(Icons.select_all, size: 16),
                    label: Text('Select All'),
                    style: TextButton.styleFrom(
                      foregroundColor: Get.theme.primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  if (_reportController.selectedBuildingTypes.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        _reportController.selectedBuildingTypes.clear();
                      },
                      icon: Icon(Icons.clear_all, size: 16),
                      label: Text('Clear All'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildVehicleTypeSelector(Color cardColor, Color textColor) {
    return Obx(() {
      final vehicleTypes = _reportController.vehicleTypes;

      return Card(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select the vehicle types to include in the report',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: vehicleTypes
                    .map((vehicleType) => _buildVehicleTypeChip(vehicleType))
                    .toList(),
              ),

              // Show select all / clear all buttons
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _reportController.selectedVehicleTypes.value =
                      List<String>.from(_reportController.vehicleTypes);
                    },
                    icon: Icon(Icons.select_all, size: 16),
                    label: Text('Select All'),
                    style: TextButton.styleFrom(
                      foregroundColor: Get.theme.primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  if (_reportController.selectedVehicleTypes.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        _reportController.selectedVehicleTypes.clear();
                      },
                      icon: Icon(Icons.clear_all, size: 16),
                      label: Text('Clear All'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAssetTypeChip(String assetType) {
    Color chipColor = _getColorForAssetType(assetType);
    bool isSelected = _reportController.selectedAssetTypes.contains(assetType);

    return FilterChip(
      selected: isSelected,
      label: Text(assetType),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Get.isDarkMode ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      selectedColor: chipColor,
      backgroundColor: Get.isDarkMode ? Colors.black12 : Colors.grey[100],
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.transparent : chipColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      onSelected: (selected) {
        _reportController.toggleAssetType(assetType);
      },
    );
  }

  Widget _buildBuildingTypeChip(String buildingType) {
    Color chipColor = _getColorForBuildingType(buildingType);
    bool isSelected = _reportController.selectedBuildingTypes.contains(buildingType);

    return FilterChip(
      selected: isSelected,
      label: Text(buildingType),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Get.isDarkMode ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      selectedColor: chipColor,
      backgroundColor: Get.isDarkMode ? Colors.black12 : Colors.grey[100],
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.transparent : chipColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      onSelected: (selected) {
        _reportController.toggleBuildingType(buildingType);
      },
    );
  }

  Widget _buildVehicleTypeChip(String vehicleType) {
    Color chipColor = _getColorForVehicleType(vehicleType);
    bool isSelected = _reportController.selectedVehicleTypes.contains(vehicleType);

    return FilterChip(
      selected: isSelected,
      label: Text(vehicleType),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Get.isDarkMode ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      selectedColor: chipColor,
      backgroundColor: Get.isDarkMode ? Colors.black12 : Colors.grey[100],
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.transparent : chipColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      onSelected: (selected) {
        _reportController.toggleVehicleType(vehicleType);
      },
    );
  }

  Color _getColorForAssetType(String assetType) {
    switch (assetType) {
      case 'Building':
        return Colors.orange;
      case 'Vehicle':
        return Colors.blue;
      case 'Land':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  Color _getColorForBuildingType(String buildingType) {
    switch (buildingType) {
      case 'RESIDENTIAL':
        return Colors.blue;
      case 'COMMERCIAL':
        return Colors.purple;
      case 'INDUSTRIAL':
        return Colors.orange;
      case 'AGRICULTURAL':
        return Colors.green;
      default:
        return Colors.teal;
    }
  }

  Color _getColorForVehicleType(String vehicleType) {
    switch (vehicleType) {
      case 'CAR':
        return Colors.red;
      case 'TRUCK':
        return Colors.brown;
      case 'VAN':
        return Colors.indigo;
      case 'MOTORCYCLE':
        return Colors.deepOrange;
      case 'BUS':
        return Colors.deepPurple;
      default:
        return Colors.blue;
    }
  }

  Widget _buildReportTypeSelector(Color cardColor, Color textColor, Color subtitleColor) {
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose the type of report to generate',
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            Obx(() => Column(
              children: _reportController.reportTypes.map((type) =>
                  RadioListTile<String>(
                    title: Text(
                      type,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      _getReportTypeDescription(type),
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 12,
                      ),
                    ),
                    value: type,
                    groupValue: _reportController.reportType
                        .value,
                    onChanged: (value) {
                      if (value != null) {
                        _reportController.setReportType(value);
                      }
                    },
                    activeColor: Get.theme.primaryColor,
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
              ).toList(),
            )),
          ],
        ),
      ),
    );
  }

  String _getReportTypeDescription(String reportType) {
    switch (reportType) {
      case 'Summary Report':
        return 'A brief overview of all assets with basic information';
      case 'Detailed Report':
        return 'Comprehensive breakdown of all asset properties and details';
      case 'Financial Analysis':
        return 'Analysis of asset values, purchase costs, and financial metrics';
      case 'Maintenance Report':
        return 'Status of vehicle maintenance, MOT dates, and service records';
      default:
        return '';
    }
  }

  Widget _buildDateRangeSelector(BuildContext context, Color cardColor, Color textColor, Color subtitleColor) {
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select date range for asset purchase dates',
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            Obx(() => InkWell(
              onTap: () => _selectDateRange(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Colors.black12 : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range,
                      color: Get.theme.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy').format(_reportController.startDate.value),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Get.isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy').format(_reportController.endDate.value),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),

            // Quick date range buttons
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickDateButton('Last 30 Days', 30),
                _buildQuickDateButton('Last 90 Days', 90),
                _buildQuickDateButton('Last Year', 365),
                _buildQuickDateButton('All Time', 3650), // ~10 years
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(String label, int days) {
    return OutlinedButton(
      onPressed: () {
        _reportController.setDateRange(
          DateTime.now().subtract(Duration(days: days)),
          DateTime.now(),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Get.theme.primaryColor,
        side: BorderSide(color: Get.theme.primaryColor.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        visualDensity: VisualDensity.compact,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: _reportController.startDate.value,
        end: _reportController.endDate.value,
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Get.theme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Get.isDarkMode ? Colors.white : Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Get.theme.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _reportController.setDateRange(picked.start, picked.end);
    }
  }

  Widget _buildAdditionalOptions(Color cardColor, Color textColor, Color subtitleColor) {
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional report options',
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            Obx(() => SwitchListTile(
              title: Text(
                'Include Charts & Graphs',
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                'Add visual representations of data to the report',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 12,
                ),
              ),
              value: _reportController.includeCharts.value,
              onChanged: (value) {
                _reportController.toggleIncludeCharts();
              },
              activeColor: Get.theme.primaryColor,
              contentPadding: EdgeInsets.zero,
            )),

            // Divider
            Divider(height: 24, thickness: 1),

            // Preview of report contents based on selected type
            _buildReportPreview(textColor, subtitleColor),
          ],
        ),
      ),
    );
  }

  Widget _buildReportPreview(Color textColor, Color subtitleColor) {
    return Obx(() {
      String reportType = _reportController.reportType.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Contents Preview',
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),

          // Different preview content based on report type
          ...(_getReportContentPreview(reportType).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    size: 16,
                    color: Get.theme.primaryColor.withOpacity(0.7)
                ),
                SizedBox(width: 8),
                Text(
                  item,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ))),

          SizedBox(height: 8),
          if (_reportController.includeCharts.value)
            Row(
              children: [
                Icon(Icons.check_circle_outline,
                    size: 16,
                    color: Get.theme.primaryColor.withOpacity(0.7)
                ),
                SizedBox(width: 8),
                Text(
                  'Visual charts and graphs',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
        ],
      );
    });
  }

  List<String> _getReportContentPreview(String reportType) {
    switch (reportType) {
      case 'Summary Report':
        return [
          'Basic asset information',
          'Asset categories and types',
          'Total value summary',
          'Asset count by category'
        ];
      case 'Detailed Report':
        return [
          'Comprehensive asset details',
          'Location information',
          'Purchase details',
          'Property specifications',
          'Owner information'
        ];
      case 'Financial Analysis':
        return [
          'Purchase price analysis',
          'Current value estimates',
          'Depreciation calculations',
          'Financial metrics',
          'Value comparison by category'
        ];
      case 'Maintenance Report':
        return [
          'Maintenance status indicators',
          'MOT and insurance dates',
          'Upcoming renewals',
          'Maintenance history summary',
          'Status alerts and warnings'
        ];
      default:
        return ['Basic asset information'];
    }
  }

  Widget _buildGenerateButton(BuildContext context) {
    return Obx(() {
      // Get filtered assets to check if any match the criteria
      final filteredAssets = _reportController.getFilteredAssets();
      bool hasFilteredAssets = filteredAssets.isNotEmpty;

      bool canGenerate = !_reportController.isGeneratingReport.value &&
          _reportController.selectedAssetTypes.isNotEmpty &&
          hasFilteredAssets;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!hasFilteredAssets && _reportController.assets.isNotEmpty)
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No assets match your current filter criteria. Please adjust your filters.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Get.isDarkMode ? Colors.amber[200] : Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ElevatedButton(
            onPressed: canGenerate
                ? () => _reportController.generateReport()
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              disabledBackgroundColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[300],
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.grey,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getReportTypeIcon(_reportController.reportType.value), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Generate ${_reportController.reportType.value}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  IconData _getReportTypeIcon(String reportType) {
    switch (reportType) {
      case 'Summary Report':
        return Icons.summarize_rounded;
      case 'Detailed Report':
        return Icons.description_rounded;
      case 'Financial Analysis':
        return Icons.trending_up_rounded;
      case 'Maintenance Report':
        return Icons.build_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  // Helper method to parse number values
  double? _parseNumber(dynamic value) {
    if (value == null || value == 'N/A') return null;

    try {
      if (value is num) {
        return value.toDouble();
      } else {
        // Try to parse string value
        final sanitizedValue = value.toString().replaceAll(RegExp(r'[^\d.]'), '');
        if (sanitizedValue.isEmpty) return null;
        return double.parse(sanitizedValue);
      }
    } catch (e) {
      _logger.w("⚠️ Number parsing error: $e");
      return null;
    }
  }

  // Helper method to format currency values
  String _formatCurrency(dynamic value) {
    final numValue = (value is num) ? value.toDouble() : _parseNumber(value);
    if (numValue == null) return 'N/A';
    return '\$${NumberFormat('#,##0.00').format(numValue)}';
  }
}