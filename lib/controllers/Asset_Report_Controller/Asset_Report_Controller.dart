import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';



import '../../models/assets/building/building_model.dart';
import '../../models/assets/land/land_model.dart';
import '../../models/assets/vehicle/vehicle_model.dart';


import '../../services/data/load_building.dart';
import '../../services/data/load_land.dart';
import '../../services/data/load_vehicle.dart';

class AssetReportController extends GetxController {
  final Logger _logger = Logger();
  Timer? autoRefreshTimer;

  // Initialize services directly at declaration to avoid type issues
  final LoadVehicleService _vehicleService = Get.put(LoadVehicleService());
  final LoadBuildingService _buildingService = Get.put(LoadBuildingService());
  final LoadLandsService _landService = Get.put(LoadLandsService());

  // Reactive data storage
  var assets = <Map<String, dynamic>>[].obs;
  final List<String> categories = ['All', 'Building', 'Vehicle', 'Land'];

  // Selected filters
  var selectedAssetTypes = <String>[].obs;
  var startDate = DateTime.now().subtract(Duration(days: 365)).obs;
  var endDate = DateTime.now().obs;
  var reportType = 'Summary Report'.obs;
  var includeCharts = true.obs;

  // Report generation status
  var isGeneratingReport = false.obs;
  var reportProgress = 0.0.obs;
  var generatedReportPath = ''.obs;
  var isLoading = false.obs;

  // Report types
  final List<String> reportTypes = [
    'Summary Report',
    'Detailed Report',
    'Financial Analysis',
    'Maintenance Report'
  ];

  // Property types
  final buildingTypes = <String>[
    'RESIDENTIAL',
    'COMMERCIAL',
    'INDUSTRIAL',
    'AGRICULTURAL',
    'MIXED USE'
  ].obs;

  final selectedBuildingTypes = <String>[].obs;

  // Vehicle types
  final vehicleTypes = <String>[
    'CAR',
    'TRUCK',
    'VAN',
    'MOTORCYCLE',
    'BUS'
  ].obs;

  final selectedVehicleTypes = <String>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize with all asset types selected by default
    selectedAssetTypes.value = categories
        .where((category) => category != 'All')
        .toList();

    _logger.i("🏢 Selected asset types: $selectedAssetTypes");

    // Initialize with some building types selected
    selectedBuildingTypes.value = ['RESIDENTIAL', 'COMMERCIAL', 'INDUSTRIAL'];
    _logger.i("🏢 Selected building types: $selectedBuildingTypes");

    // Initialize with some vehicle types selected
    selectedVehicleTypes.value = ['CAR', 'TRUCK'];

    // Load data initially
    loadAllAssets();

    // Start auto refresh timer
    _startAutoRefresh();
  }

  @override
  void onClose() {
    autoRefreshTimer?.cancel();
    super.onClose();
  }

  void _startAutoRefresh() {
    autoRefreshTimer?.cancel(); // Prevent duplicate timers
    autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      refreshAssets();
      _logger.i("🔄 Auto-refreshing assets...");
    });
  }

  /// Load all asset data from all services
  Future<void> loadAllAssets() async {
    try {
      isLoading(true);
      _logger.i("🔄 Loading all assets for reporting...");

      // Load data from all three services concurrently
      final results = await Future.wait([
        _loadBuildings(),
        _loadVehicles(),
        _loadLands(),
      ]);

      // Combine all assets into a single list
      assets.value = results.expand((element) => element).toList();

      _logger.i("✅ Loaded ${assets.length} assets for reporting");
    } catch (e) {
      _logger.e("❌ Error loading assets: $e");
      Get.snackbar(
        "Loading Error",
        "Failed to load asset data: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  /// Load buildings data
  Future<List<Map<String, dynamic>>> _loadBuildings() async {
    try {
      _logger.i("🏢 Loading building data...");
      final response = await _buildingService.fetchBuildings();

      List<Building> buildings = response['buildings'] ?? [];
      _logger.i("🏢 Loaded ${buildings.length} buildings");

      // Transform Building objects into standardized maps
      return buildings.map((b) => {
        "category": "Building",
        "name": b.name?.trim() ?? "Unnamed Building",
        "buildingType": b.buildingType ?? "N/A",
        "numberOfFloors": b.numberOfFloors,
        "totalArea": b.totalArea,
        "address": b.address ?? "N/A",
        "buildingAddress": b.address ?? "N/A",
        "purposeOfUse": b.purposeOfUse ?? "N/A",
        "councilTaxValue": b.councilTax,
        "councilTaxDate": b.councilTaxDate,
        "city": b.city ?? "N/A",
        "buildingCity": b.city ?? "N/A",
        "ownerName": b.ownerName ?? "N/A",
        "purchasePrice": b.purchasePrice,
        "purchaseDate": b.purchaseDate,
        "leaseValue": b.leaseValue,
        "leaseDate": b.leaseDate,
        "buildingId": b.link != null ? Uri.parse(b.link!).pathSegments.last : "",
        "imageURL": b.buildingImage ?? "",
      }).toList();
    } catch (e) {
      _logger.e("❌ Error loading buildings: $e");
      return [];
    }
  }

  /// Load vehicles data
  Future<List<Map<String, dynamic>>> _loadVehicles() async {
    try {
      _logger.i("🚗 Loading vehicle data...");
      final response = await _vehicleService.fetchVehicles();

      List<Vehicle> vehicles = response['vehicles'] ?? [];
      _logger.i("🚗 Loaded ${vehicles.length} vehicles");

      // Transform Vehicle objects into standardized maps
      return vehicles.map((v) => {
        "category": "Vehicle",
        "name": v.model ?? "Unnamed Vehicle",
        "model": v.model ?? "N/A",
        "vrn": v.vrn ?? "N/A",
        "motValue": v.motValue,
        "insuranceValue": v.insuranceValue,
        "vehicleType": v.vehicleType ?? "N/A",
        "vehicle_type": v.vehicleType ?? "N/A",
        "ownerName": v.ownerName ?? "N/A",
        "purchasePrice": v.purchasePrice,
        "purchaseDate": v.purchaseDate,
        "motDate": v.motDate,
        "motExpiredDate": v.motExpiredDate,
        "insuranceDate": v.insuranceDate,
        "imageURL": v.vehicleImage ?? "",
        "vehicleId": v.links != null ? Uri.parse(v.links!).pathSegments.last : "",
      }).toList();
    } catch (e) {
      _logger.e("❌ Error loading vehicles: $e");
      return [];
    }
  }

  /// Load lands data
  Future<List<Map<String, dynamic>>> _loadLands() async {
    try {
      _logger.i("🌳 Loading land data...");
      final response = await _landService.fetchLands();

      List<Land> lands = response['lands'] ?? [];
      _logger.i("🌳 Loaded ${lands.length} lands");

      // Transform Land objects into standardized maps
      return lands.map((l) => {
        "category": "Land",
        "name": l.name ?? "Unnamed Land",
        "landType": l.landType ?? "N/A",
        "landSize": l.landSize,
        "address": l.address ?? "N/A",
        "landAddress": l.address ?? "N/A",
        "city": l.city ?? "N/A",
        "landCity": l.city ?? "N/A",
        "purchasePrice": l.purchasePrice,
        "purchaseDate": l.purchaseDate,
        "leaseValue": l.leaseValue,
        "leaseDate": l.leaseDate,
        "imageURL": l.landImage ?? "",
        "landId": l.links != null ? Uri.parse(l.links!).pathSegments.last : "",
      }).toList();
    } catch (e) {
      _logger.e("❌ Error loading lands: $e");
      return [];
    }
  }

  /// Refresh all assets
  Future<void> refreshAssets() async {
    try {
      _logger.i("🔄 Refreshing assets for reporting...");
      await loadAllAssets();
    } catch (e) {
      _logger.e("❌ Error refreshing assets: $e");
    }
  }

  void toggleAssetType(String assetType) {
    if (selectedAssetTypes.contains(assetType)) {
      selectedAssetTypes.remove(assetType);
    } else {
      selectedAssetTypes.add(assetType);
    }
  }

  void toggleVehicleType(String vehicleType) {
    if (selectedVehicleTypes.contains(vehicleType)) {
      selectedVehicleTypes.remove(vehicleType);
    } else {
      selectedVehicleTypes.add(vehicleType);
    }
  }

  void toggleBuildingType(String? buildingType) {
    if (buildingType == null) return;
    _logger.i("🏢 Toggling building type: $buildingType");

    if (selectedBuildingTypes.contains(buildingType)) {
      selectedBuildingTypes.remove(buildingType);
      _logger.i("🏢 Removed building type: $buildingType");
    } else {
      selectedBuildingTypes.add(buildingType);
      _logger.i("🏢 Added building type: $buildingType");
    }
  }

  void setDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
  }

  void setReportType(String type) {
    reportType.value = type;
    _logger.i("📊 Report type set to: $type");
  }

  void toggleIncludeCharts() {
    includeCharts.value = !includeCharts.value;
  }

  // Helper function to get value from asset map
  dynamic _getValue(Map<String, dynamic> asset, String key) {
    if (asset.isEmpty) return null;
    return asset[key];
  }

  // Get filtered assets based on selected types and date range
  List<Map<String, dynamic>> getFilteredAssets() {
    if (selectedAssetTypes.isEmpty) return [];

    return assets.where((asset) {
      final category = asset['category'];
      _logger.i("🏢 Filtering asset category: $category");

      if (category == null || !selectedAssetTypes.contains(category)) {
        return false;
      }

      // Apply building type filter for Building assets
      if (category == 'Building' &&
          selectedBuildingTypes.isNotEmpty &&
          asset.containsKey('buildingType')) {
        String? buildingType = asset['buildingType'] as String?;
        _logger.i("🏢 Building type: $buildingType");
        if (buildingType == null ||
            !selectedBuildingTypes.contains(buildingType)) {
          return false;
        }
      }

      // Apply property type filter for Land assets
      if (category == 'Land' &&
          selectedBuildingTypes.isNotEmpty &&
          asset.containsKey('landType')) {
        _logger.i("🌳 Land type: ${asset['landType']}");
        String? landType = asset['landType'] as String?;
        if (landType == null || !selectedBuildingTypes.contains(landType)) {
          return false;
        }
      }

      // Apply vehicle type filter for Vehicle assets
      if (category == 'Vehicle' &&
          selectedVehicleTypes.isNotEmpty &&
          (asset.containsKey('vehicleType') ||
              asset.containsKey('vehicle_type'))) {
        _logger.i("🚗 Vehicle type: ${asset['vehicleType'] ?? asset['vehicle_type']}");
        String? vehicleType = asset['vehicleType'] as String? ??
            asset['vehicle_type'] as String?;
        if (vehicleType == null ||
            !selectedVehicleTypes.contains(vehicleType)) {
          return false;
        }
      }

      // Filter by date range if purchase date is available
      if (asset.containsKey('purchaseDate') && asset['purchaseDate'] != null &&
          asset['purchaseDate'] != 'N/A') {
        try {
          DateTime purchaseDate;

          if (asset['purchaseDate'] is String) {
            // Try to parse the date string
            purchaseDate = DateTime.parse(asset['purchaseDate']);
          } else if (asset['purchaseDate'] is DateTime) {
            purchaseDate = asset['purchaseDate'];
          } else {
            // Skip date filtering if date format is unknown
            return true;
          }

          return purchaseDate.isAfter(startDate.value) &&
              purchaseDate.isBefore(endDate.value.add(Duration(days: 1)));
        } catch (e) {
          // If date parsing fails, include the asset anyway
          _logger.w("⚠️ Could not parse date for asset: ${asset['name'] ??
              asset['model'] ?? 'Unknown'}");
          return true;
        }
      }

      // Include assets without purchase date
      return true;
    }).toList();
  }

  // Generate report in PDF format
  Future<void> generateReport() async {
    if (selectedAssetTypes.isEmpty) {
      Get.snackbar(
        "No Asset Types Selected",
        "Please select at least one asset type for the report",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isGeneratingReport(true);
      reportProgress(0.1);
      _logger.i("📊 Generating ${reportType.value}...");

      // Get filtered assets
      final filteredAssets = getFilteredAssets();
      if (filteredAssets.isEmpty) {
        Get.snackbar(
          "No Data Found",
          "No assets match your selected filters",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        isGeneratingReport(false);
        return;
      }

      reportProgress(0.3);

      // Create PDF document based on report type
      final pdf = await _createPdfReport(filteredAssets, reportType.value);

      reportProgress(0.7);

      // Save the PDF
      final filePath = await _savePdfReport(pdf);

      reportProgress(1.0);

      // Show preview dialog
      _showReportPreview(filePath);

      _logger.i("✅ Report generated successfully: $filePath");
    } catch (e) {
      _logger.e("❌ Error generating report: $e");
      Get.snackbar(
        "Error",
        "Failed to generate report: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isGeneratingReport(false);
    }
  }

  // Save the PDF to a location
  Future<String> _savePdfReport(pw.Document pdf) async {
    final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final String reportName = 'asset_report_$timestamp.pdf';

    // For simplicity, save to application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$reportName';

    // Save the file
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  // Create PDF document
  Future<pw.Document> _createPdfReport(List<Map<String, dynamic>> assets, String type) async {
    final pdf = pw.Document();

    // Load fonts
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();

    // Choose columns based on report type
    List<String> columns = [];
    List<dynamic> Function(Map<String, dynamic>) rowBuilder;

    switch (type) {
      case 'Summary Report':
        columns = ['Asset Name', 'Category', 'Type', 'Purchase Price'];
        rowBuilder = (asset) =>
        [
          _getValue(asset, 'name') ?? _getValue(asset, 'model') ?? 'N/A',
          _getValue(asset, 'category') ?? 'N/A',
          _getTypeValue(asset),
          _formatCurrency(_getValue(asset, 'purchasePrice')),
        ];
        break;
      case 'Detailed Report':
        columns = [
          'Asset Name',
          'Category',
          'Type',
          'Purchase Date',
          'Purchase Price',
          'Location'
        ];
        rowBuilder = (asset) =>
        [
          _getValue(asset, 'name') ?? _getValue(asset, 'model') ?? 'N/A',
          _getValue(asset, 'category') ?? 'N/A',
          _getTypeValue(asset),
          _formatDate(_getValue(asset, 'purchaseDate')),
          _formatCurrency(_getValue(asset, 'purchasePrice')),
          _getLocationValue(asset),
        ];
        break;
      case 'Financial Analysis':
        columns = [
          'Asset Name',
          'Category',
          'Purchase Price',
          'Current Value',
          'Depreciation'
        ];
        rowBuilder = (asset) =>
        [
          _getValue(asset, 'name') ?? _getValue(asset, 'model') ?? 'N/A',
          _getValue(asset, 'category') ?? 'N/A',
          _formatCurrency(_getValue(asset, 'purchasePrice')),
          _formatCurrency(_calculateCurrentValue(asset)),
          _calculateDepreciation(asset),
        ];
        break;
      case 'Maintenance Report':
        columns = [
          'Asset Name',
          'Category',
          'Type',
          'Last Maintenance',
          'Status',
          'Notes'
        ];
        rowBuilder = (asset) =>
        [
          _getValue(asset, 'name') ?? _getValue(asset, 'model') ?? 'N/A',
          _getValue(asset, 'category') ?? 'N/A',
          _getTypeValue(asset),
          _formatDate(_getValue(asset, 'lastMaintenance') ??
              _getMaintenanceDate(asset) ?? 'N/A'),
          _getMaintenanceStatus(asset),
          _getValue(asset, 'maintenanceNotes') ?? 'No notes',
        ];
        break;
      default:
        columns = ['Asset Name', 'Category', 'Type', 'Purchase Date', 'Purchase Price'];
        rowBuilder = (asset) =>
        [
          _getValue(asset, 'name') ?? _getValue(asset, 'model') ?? 'N/A',
          _getValue(asset, 'category') ?? 'N/A',
          _getTypeValue(asset),
          _formatDate(_getValue(asset, 'purchaseDate')),
          _formatCurrency(_getValue(asset, 'purchasePrice')),
        ];
    }

    // Add report pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        header: (context) => _buildReportHeader(context, type, fontBold),
        footer: (context) => _buildReportFooter(context, font),
        build: (context) =>
        [
          _buildReportFilters(font, fontBold),
          pw.SizedBox(height: 20),
          _buildSummaryStats(assets, font, fontBold),
          pw.SizedBox(height: 20),
          _buildAssetTable(assets, columns, rowBuilder, font, fontBold),
          if (includeCharts.value) ...[
            pw.SizedBox(height: 30),
            _buildCharts(assets, font, fontBold),
          ],
        ],
      ),
    );

    return pdf;
  }

  // Build summary statistics section
  pw.Widget _buildSummaryStats(List<Map<String, dynamic>> assets, pw.Font font,
      pw.Font fontBold) {
    // Calculate total value
    double totalValue = 0;
    for (var asset in assets) {
      var price = _getValue(asset, 'purchasePrice');
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
      String category = _getValue(asset, 'category') ?? 'Unknown';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary Statistics',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 14,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                  'Total Assets', '${assets.length}', font, fontBold),
              _buildStatItem(
                  'Total Value', _formatCurrency(totalValue), font, fontBold),
              _buildStatItem('Date Range',
                  '${_formatDate(startDate.value)} - ${_formatDate(
                      endDate.value)}', font, fontBold),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Assets by Category',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 12,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: categoryCounts.entries.map((entry) =>
                _buildStatItem(
                    entry.key, '${entry.value}', font, fontBold, flex: 1)
            ).toList(),
          ),
        ],
      ),
    );
  }

  // Build charts section
  pw.Widget _buildCharts(List<Map<String, dynamic>> assets, pw.Font font,
      pw.Font fontBold) {
    // Count by category
    Map<String, int> categoryCounts = {};
    for (var asset in assets) {
      String category = _getValue(asset, 'category') ?? 'Unknown';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    // Calculate total value by category
    Map<String, double> categoryValues = {};
    for (var asset in assets) {
      String category = _getValue(asset, 'category') ?? 'Unknown';
      var price = _getValue(asset, 'purchasePrice');
      if (price != null && price != 'N/A') {
        double? numValue = _parseNumber(price);
        if (numValue != null) {
          categoryValues[category] = (categoryValues[category] ?? 0) + numValue;
        }
      }
    }

    // Simple bar chart - we'll simulate it with rectangles
    return pw.Container(
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Asset Distribution by Category',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 14,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: categoryCounts.entries.map((entry) {
              // Calculate bar height proportional to count
              final maxHeight = 100.0;
              final maxCount = categoryCounts.values.reduce((a, b) =>
              a > b
                  ? a
                  : b);
              final barHeight = (entry.value / maxCount) * maxHeight;

              return pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Container(
                      height: barHeight,
                      margin: pw.EdgeInsets.symmetric(horizontal: 8),
                      decoration: pw.BoxDecoration(
                        color: _getCategoryColor(entry.key),
                        borderRadius: pw.BorderRadius.vertical(
                          top: pw.Radius.circular(4),
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      entry.key,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                      ),
                    ),
                    pw.Text(
                      '${entry.value}',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'Asset Value Distribution (in \$)',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 14,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: categoryValues.entries.map((entry) {
              // Calculate bar height proportional to value
              final maxHeight = 100.0;
              final maxValue = categoryValues.values.reduce((a, b) =>
              a > b
                  ? a
                  : b);
              final barHeight = (entry.value / maxValue) * maxHeight;

              return pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Container(
                      height: barHeight,
                      margin: pw.EdgeInsets.symmetric(horizontal: 8),
                      decoration: pw.BoxDecoration(
                        color: _getCategoryColor(entry.key),  // Just use the same color
                        borderRadius: pw.BorderRadius.vertical(
                          top: pw.Radius.circular(4),
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      entry.key,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                      ),
                    ),
                    pw.Text(
                      '\$${NumberFormat('#,##0').format(entry.value)}',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Get category color for charts
  PdfColor _getCategoryColor(String category) {
    switch (category) {
      case 'Building':
        return PdfColors.blue400;
      case 'Vehicle':
        return PdfColors.green400;
      case 'Land':
        return PdfColors.amber400;
      default:
        return PdfColors.grey400;
    }
  }

  // Build stat item
  pw.Widget _buildStatItem(String label, String value, pw.Font font,
      pw.Font fontBold, {int flex = 1}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Padding(
        padding: pw.EdgeInsets.symmetric(horizontal: 5),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              value,
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show PDF preview dialog
  void _showReportPreview(String filePath) {
    Get.dialog(
        Dialog(
        insetPadding: EdgeInsets.all(16),
    child: Container(
    height: Get.height * 0.8,
    width: Get.width * 0.9,
    child: Column(
    children: [
    Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    color: Get.theme.primaryColor,
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text(
    '${reportType.value} Preview',
    style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    ),
    ),
      IconButton(
        icon: Icon(Icons.close, color: Colors.white),
        onPressed: () => Get.back(),
      ),
    ],
    ),
    ),
      Expanded(
        child: PdfPreview(
          build: (format) => File(filePath).readAsBytes(),
          allowSharing: false,
          allowPrinting: false,
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
        ),
      ),
      Container(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final result = await OpenFile.open(filePath);
                if (result.type != ResultType.done) {
                  Get.snackbar(
                    "Error",
                    "Could not open the file: ${result.message}",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              icon: Icon(Icons.open_in_new),
              label: Text('Open'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await Printing.layoutPdf(
                  onLayout: (_) => File(filePath).readAsBytes(),
                );
              },
              icon: Icon(Icons.print),
              label: Text('Print'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Column(
          children: [
            Text(
              'File saved at:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Text(
              filePath,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ],
    ),
    ),
        ),
    );
  }

  // PDF Report Header
  pw.Widget _buildReportHeader(pw.Context context, String title,
      pw.Font fontBold) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Vynix',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 20,
                  color: PdfColors.blue900,
                ),
              ),
              pw.Text(
                'Generated: ${DateFormat('MMM dd, yyyy').format(
                    DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            padding: pw.EdgeInsets.symmetric(vertical: 10),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue900,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 16,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            _getReportTypeDescription(title),
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey700,
              fontStyle: pw.FontStyle.italic,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.Divider(thickness: 1),
        ],
      ),
    );
  }

  // PDF Report Footer
  pw.Widget _buildReportFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      margin: pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Asset Management System',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  // Report Filters Section
  pw.Widget _buildReportFilters(pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Report Filters',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 14,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildFilterItem(
                  'Asset Types',
                  selectedAssetTypes.isNotEmpty
                      ? selectedAssetTypes.join(', ')
                      : 'None',
                  font,
                  fontBold,
                ),
              ),
              pw.Expanded(
                child: _buildFilterItem(
                  'Report Type',
                  reportType.value,
                  font,
                  fontBold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildFilterItem(
                  'Date Range',
                  '${DateFormat('MM/dd/yyyy').format(
                      startDate.value)} - ${DateFormat('MM/dd/yyyy').format(
                      endDate.value)}',
                  font,
                  fontBold,
                ),
              ),
              pw.Expanded(
                child: _buildFilterItem(
                  'Include Charts',
                  includeCharts.value ? 'Yes' : 'No',
                  font,
                  fontBold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildFilterItem(
                  'Property Types',
                  selectedBuildingTypes.isNotEmpty ? selectedBuildingTypes.join(
                      ', ') : 'All',
                  font,
                  fontBold,
                ),
              ),
              pw.Expanded(
                child: _buildFilterItem(
                  'Vehicle Types',
                  selectedVehicleTypes.isNotEmpty ? selectedVehicleTypes.join(
                      ', ') : 'All',
                  font,
                  fontBold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFilterItem(String label, String value, pw.Font font,
      pw.Font fontBold) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Build asset table for the report
  pw.Widget _buildAssetTable(List<Map<String, dynamic>> assets,
      List<String> columns,
      List<dynamic> Function(Map<String, dynamic>) rowBuilder,
      pw.Font font,
      pw.Font fontBold,) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        for (int i = 0; i < columns.length; i++)
          i: pw.FlexColumnWidth(1),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: columns.map((col) =>
              pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: pw.Text(
                  col,
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 11,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              )
          ).toList(),
        ),
        // Data rows
        ...assets.map((asset) {
          final rowData = rowBuilder(asset);
          return pw.TableRow(
            children: rowData.map((value) =>
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    value?.toString() ?? 'N/A',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                    ),
                  ),
                )
            ).toList(),
          );
        }).toList(),
      ],
    );
  }

  String _getTypeValue(Map<String, dynamic> asset) {
    final category = asset['category'];
    if (category == 'Building') {
      _logger.i("🏢 Building type: ${asset['buildingType']}");
      return asset['buildingType'] ?? 'N/A';
    } else if (category == 'Vehicle') {
      return asset['vehicleType'] ?? asset['vehicle_type'] ?? asset['type'] ??
          'N/A';
    } else if (category == 'Land') {
      return asset['landType'] ?? 'N/A';
    }
    return 'N/A';
  }

  String _getLocationValue(Map<String, dynamic> asset) {
    final category = asset['category'];
    if (category == 'Building') {
      _logger.i("🏢 Building location: ${asset['buildingAddress']}, ${asset['buildingCity']}");
      if (asset['buildingAddress'] != null && asset['buildingCity'] != null) {
        return '${asset['buildingAddress']}, ${asset['buildingCity']}';
      } else if (asset['buildingAddress'] != null) {
        return asset['buildingAddress'];
      } else if (asset['buildingCity'] != null) {
        return asset['buildingCity'];
      } else if (asset['address'] != null && asset['city'] != null) {
        return '${asset['address']}, ${asset['city']}';
      } else if (asset['address'] != null) {
        return asset['address'];
      } else if (asset['city'] != null) {
        return asset['city'];
      }
    } else if (category == 'Land') {
      if (asset['landAddress'] != null && asset['landCity'] != null) {
        return '${asset['landAddress']}, ${asset['landCity']}';
      } else if (asset['landAddress'] != null) {
        return asset['landAddress'];
      } else if (asset['landCity'] != null) {
        return asset['landCity'];
      } else if (asset['address'] != null && asset['city'] != null) {
        return '${asset['address']}, ${asset['city']}';
      } else if (asset['address'] != null) {
        return asset['address'];
      } else if (asset['city'] != null) {
        return asset['city'];
      }
    } else if (category == 'Vehicle') {
      return asset['ownerName'] ?? 'N/A';
    }
    return 'N/A';
  }

  String _formatDate(dynamic date) {
    if (date == null || date == 'N/A') return 'N/A';

    try {
      DateTime dateTime;
      if (date is DateTime) {
        dateTime = date;
      } else {
        dateTime = DateTime.parse(date.toString());
      }
      return DateFormat('MM/dd/yyyy').format(dateTime);
    } catch (e) {
      return date.toString();
    }
  }

  double? _parseNumber(dynamic value) {
    if (value == null || value == 'N/A') return null;

    try {
      if (value is num) {
        return value.toDouble();
      } else {
        // Try to parse string value
        final sanitizedValue = value.toString().replaceAll(
            RegExp(r'[^\d.]'), '');
        if (sanitizedValue.isEmpty) return null;
        return double.parse(sanitizedValue);
      }
    } catch (e) {
      return null;
    }
  }

  String _formatCurrency(dynamic value) {
    final numValue = _parseNumber(value);
    if (numValue == null) return 'N/A';
    return '\$${NumberFormat('#,##0.00').format(numValue)}';
  }

  String? _getMaintenanceDate(Map<String, dynamic> asset) {
    String category = asset['category'] ?? '';

    if (category == 'Vehicle') {
      // For vehicles, try to get service date, MOT date, or insurance date
      return asset['serviceDate'] ?? asset['motDate'] ?? asset['insuranceDate'];
    } else if (category == 'Building') {
      // For buildings, try to get council tax date or lease date
      return asset['councilTaxDate'] ?? asset['leaseDate'];
    } else if (category == 'Land') {
      // For land, try to get lease date
      return asset['leaseDate'];
    }

    return null;
  }

  // Get maintenance status for maintenance report
  String _getMaintenanceStatus(Map<String, dynamic> asset) {
    // For vehicles we can use MOT date to determine status
    String category = _getValue(asset, 'category') ?? '';

    if (category == 'Vehicle') {
      var motDate = _getValue(asset, 'motExpiredDate') ??
          _getValue(asset, 'motDate');
      if (motDate != null && motDate != 'N/A') {
        try {
          DateTime expiryDate = DateTime.parse(motDate.toString());
          if (expiryDate.isBefore(DateTime.now())) {
            return 'OVERDUE';
          } else
          if (expiryDate.isBefore(DateTime.now().add(Duration(days: 30)))) {
            return 'DUE SOON';
          } else {
            return 'VALID';
          }
        } catch (e) {
          return 'UNKNOWN';
        }
      }
    } else if (category == 'Building') {
      _logger.i("🏢 Building type: ${asset['buildingType']}");
      // For buildings, we can check council tax date
      var councilTaxDate = _getValue(asset, 'councilTaxDate');
      if (councilTaxDate != null && councilTaxDate != 'N/A') {
        try {
          DateTime expiryDate = DateTime.parse(councilTaxDate.toString());
          if (expiryDate.isBefore(DateTime.now())) {
            return 'RENEWAL REQUIRED';
          } else
          if (expiryDate.isBefore(DateTime.now().add(Duration(days: 60)))) {
            return 'UPCOMING RENEWAL';
          } else {
            return 'CURRENT';
          }
        } catch (e) {
          return 'UNKNOWN';
        }
      }
      return 'NOT APPLICABLE';
    } else if (category == 'Land') {
      // For land, we can check lease date
      var leaseDate = _getValue(asset, 'leaseDate');
      if (leaseDate != null && leaseDate != 'N/A') {
        try {
          DateTime expiryDate = DateTime.parse(leaseDate.toString());
          if (expiryDate.isBefore(DateTime.now())) {
            return 'EXPIRED';
          } else
          if (expiryDate.isBefore(DateTime.now().add(Duration(days: 90)))) {
            return 'EXPIRING SOON';
          } else {
            return 'ACTIVE';
          }
        } catch (e) {
          return 'UNKNOWN';
        }
      }
      return 'FREEHOLD';
    }

    // For other assets
    return 'N/A';
  }

  // Calculate current value based on purchase date and depreciation
  double _calculateCurrentValue(Map<String, dynamic> asset) {
    double? purchasePrice = _parseNumber(_getValue(asset, 'purchasePrice'));
    if (purchasePrice == null) return 0.0;

    // Default to 80% of purchase price if we can't calculate better
    double currentValue = purchasePrice * 0.8;

    try {
      var purchaseDateStr = _getValue(asset, 'purchaseDate');
      if (purchaseDateStr != null && purchaseDateStr != 'N/A') {
        DateTime purchaseDate = DateTime.parse(purchaseDateStr.toString());
        int ageInYears = DateTime.now().difference(purchaseDate).inDays ~/ 365;

        // Apply different depreciation rates based on asset type
        String category = _getValue(asset, 'category') ?? '';
        double depreciationRate = 0.0;

        switch (category) {
          case 'Vehicle':
            depreciationRate = 0.15; // 15% per year for vehicles
            break;
          case 'Building':
            _logger.i("🏢 Building type: ${asset['buildingType']}");
            depreciationRate = 0.03; // 3% per year for buildings
            break;
          case 'Land':
            depreciationRate = -0.02; // Land appreciates 2% per year
            break;
          default:
            depreciationRate = 0.10; // 10% for other assets
        }

        // Calculate current value with compound depreciation/appreciation
        currentValue = purchasePrice * pow((1 - depreciationRate), ageInYears);
      }
    } catch (e) {
      _logger.w("Cannot calculate precise current value for asset: $e");
    }

    return currentValue;
  }

  // Calculate depreciation percentage
  String _calculateDepreciation(Map<String, dynamic> asset) {
    double? purchasePrice = _parseNumber(_getValue(asset, 'purchasePrice'));
    if (purchasePrice == null || purchasePrice == 0) return 'N/A';

    double currentValue = _calculateCurrentValue(asset);
    double depreciationPct = ((purchasePrice - currentValue) / purchasePrice) * 100;

    // If negative, it's appreciation
    if (depreciationPct < 0) {
      return '${NumberFormat('#,##0.0').format(depreciationPct.abs())}% appreciation';
    } else {
      return '${NumberFormat('#,##0.0').format(depreciationPct)}%';
    }
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
        return 'Status of maintenance, expiry dates, and service records';
      default:
        return '';
    }
  }


}