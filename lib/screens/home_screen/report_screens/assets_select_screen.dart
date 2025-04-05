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

                    _buildSectionTitle('Select Property Types', Icons.home_work_rounded, textColor),
                    SizedBox(height: 12),
                    _buildBuildingTypeSelector(cardColor, textColor),
                    SizedBox(height: 24),

                    _buildSectionTitle('Select Vehicle Types', Icons.directions_car_rounded, textColor),
                    SizedBox(height: 12),
                    _buildVehicleTypeSelector(cardColor, textColor),
                    SizedBox(height: 24),


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
              if (_reportController.isGeneratingReport.value)
                _buildLoadingOverlay(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAssetCountIndicator(Color textColor, Color subtitleColor) {
    return Obx(() => Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
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
              Text(
                '${_reportController.assets.length} Assets Available',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Filter options to generate your report',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              value: _reportController.reportProgress.value,
              valueColor: AlwaysStoppedAnimation<Color>(Get.theme.primaryColor),
            ),
            SizedBox(height: 20),
            Text(
              'Generating ${_reportController.reportType.value}...',

              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${(_reportController.reportProgress.value * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
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
                    groupValue: _reportController.reportType.value,
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
          ],
        ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(BuildContext context) {
    return Obx(() {
      bool canGenerate = !_reportController.isGeneratingReport.value &&
          _reportController.selectedAssetTypes.isNotEmpty;

      // Check if we have any asset data
      bool hasAssetData = _reportController.assets.isNotEmpty;

      if (!hasAssetData) {
        canGenerate = false;
      }

      return ElevatedButton(
        onPressed: canGenerate
            ? () => _reportController.generateReport()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Get.theme.primaryColor,
          disabledBackgroundColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[300],
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
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  IconData _getReportTypeIcon(String reportType) {
    switch (reportType) {
      case 'Summary Report':
        return Icons.summarize;
      case 'Detailed Report':
        return Icons.description;
      case 'Financial Analysis':
        return Icons.trending_up;
      case 'Maintenance Report':
        return Icons.build;
      default:
        return Icons.description;
    }
  }
}