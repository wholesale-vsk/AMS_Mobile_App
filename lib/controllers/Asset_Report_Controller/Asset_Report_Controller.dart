import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';
import '../../../controllers/assets/asset_controller.dart';
import '../assets_controllers/assets_controller.dart';

class AssetReportController extends GetxController {
  final Logger _logger = Logger();
  final AssetController assetController = Get.find<AssetController>();

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

  // Report types
  final List<String> reportTypes = [
    'Summary Report',
    'Detailed Report',
    'Financial Analysis',
    'Maintenance Report'
  ];

  // Property types - Initialize with sample data
  final buildingTypes = <String>[
    'RESIDENTIAL',
    'COMMERCIAL',
    'INDUSTRIAL',
    'AGRICULTURAL',
    'MIXED USE'
  ].obs;

  final selectedBuildingTypes = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with all asset types selected by default
    // Added null check for categories
    final categories = assetController.categories ?? [];
    selectedAssetTypes.value = categories
        .where((category) => category != null && category != 'All')
        .cast<String>() // Ensure we have a List<String>
        .toList();

    // Initialize with some building types selected
    selectedBuildingTypes.value = ['RESIDENTIAL', 'COMMERCIAL'];
  }

  void toggleAssetType(String? assetType) {
    if (assetType == null) return; // Null check

    if (selectedAssetTypes.contains(assetType)) {
      selectedAssetTypes.remove(assetType);
    } else {
      selectedAssetTypes.add(assetType);
    }
  }

  void setDateRange(DateTime start, DateTime end) {
    if (start != null) startDate.value = start;
    if (end != null) endDate.value = end;
  }

  void setReportType(String type) {
    if (type != null) reportType.value = type;
  }

  void toggleIncludeCharts() {
    includeCharts.value = !includeCharts.value;
  }

  // Get filtered assets based on selected types and date range
  List<Map<String, dynamic>> getFilteredAssets() {
    if (selectedAssetTypes.isEmpty) return [];

    // Added null check for assets
    final assets = assetController.assets ?? [];

    // Use cast to ensure the correct return type
    return assets.where((asset) {
      if (asset == null) return false; // Skip null assets
      if (asset is! Map<String, dynamic>) return false; // Skip non-map assets

      // Filter by asset type
      final category = asset['category'];
      if (category == null || !selectedAssetTypes.contains(category)) {
        return false;
      }

      // Apply building type filter for Building and Land assets
      if ((category == 'Building' || category == 'Land') &&
          selectedBuildingTypes.isNotEmpty &&
          asset.containsKey('propertyType')) {
        String? propertyType = asset['propertyType'] as String?;
        if (propertyType == null || !selectedBuildingTypes.contains(propertyType)) {
          return false;
        }
      }

      // Filter by date range if purchase date is available
      if (asset.containsKey('purchaseDate') && asset['purchaseDate'] != null && asset['purchaseDate'] != 'N/A') {
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
          _logger.w("⚠️ Could not parse date for asset: ${asset['name'] ?? 'Unknown'}");
          return true;
        }
      }

      // Include assets without purchase date
      return true;
    }).cast<Map<String, dynamic>>().toList();
  }

  // Generate report in PDF format
  Future<void> generateReport() async {
    if (selectedAssetTypes.isEmpty) {
      Get.snackbar(
        "No Asset Types Selected",
        "Please select at least one asset type for the report",
        snackPosition: SnackPosition.BOTTOM,
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
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        isGeneratingReport(false);
        return;
      }

      reportProgress(0.3);

      // Create PDF document
      final pdf = await _createPdfReport(filteredAssets);

      reportProgress(0.7);

      // Save the PDF
      final filePath = await _savePdfReport(pdf);

      reportProgress(1.0);
      generatedReportPath.value = filePath;

      // Show preview dialog
      _showReportPreview(filePath);

      _logger.i("✅ Report generated successfully: $filePath");
    } catch (e) {
      _logger.e("❌ Error generating report: $e");
      Get.snackbar(
        "Error",
        "Failed to generate report: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
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
  Future<pw.Document> _createPdfReport(List<Map<String, dynamic>> assets) async {
    final pdf = pw.Document();

    // Load fonts
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();

    // Add report pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        header: (context) => _buildReportHeader(context, reportType.value, fontBold),
        footer: (context) => _buildReportFooter(context, font),
        build: (context) => [
          _buildReportFilters(font, fontBold),
          pw.SizedBox(height: 20),
          _buildAssetTable(
              assets,
              ['Asset Name', 'Category', 'Type','Purchase Date', 'Purchase Price'],
                  (asset) => [
                _getValue(asset, 'name') ?? (_getValue(asset, 'model') ?? 'N/A'),
                _getValue(asset, 'category') ?? 'N/A',
                    _getValue(asset, 'type') ?? 'N/A',
                _formatDate(_getValue(asset, 'purchaseDate')),
                _formatCurrency(_getValue(asset, 'purchasePrice')),
              ],
              font,
              fontBold
          ),
        ],
      ),
    );

    return pdf;
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
                      'Report Preview',
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
                        backgroundColor: Colors.deepPurple,
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
  pw.Widget _buildReportHeader(pw.Context context, String title, pw.Font fontBold) {
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
                'Hexalyte AMS',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 20,
                  color: PdfColors.blue900,
                ),
              ),
              pw.Text(
                'Generated: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
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
              title ?? 'Asset Report', // Added null check
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 16,
                color: PdfColors.white,
              ),
            ),
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
    // Add null check for selectedAssetTypes
    final assetTypes = selectedAssetTypes.toList();

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
                  assetTypes.isNotEmpty ? assetTypes.join(', ') : 'None',
                  font,
                  fontBold,
                ),
              ),
              pw.Expanded(
                child: _buildFilterItem(
                  'Report Type',
                  reportType.value ?? 'Summary Report',
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
                  '${DateFormat('MM/dd/yyyy').format(startDate.value)} - ${DateFormat('MM/dd/yyyy').format(endDate.value)}',
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
                  selectedBuildingTypes.isNotEmpty ? selectedBuildingTypes.join(', ') : 'All',
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

  pw.Widget _buildFilterItem(String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label ?? 'Filter', // Added null check
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            value ?? 'N/A', // Added null check
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Build asset table for the report - FIXED to handle null values
  pw.Widget _buildAssetTable(
      List<Map<String, dynamic>> assets,
      List<String> columns,
      List<String> Function(Map<String, dynamic>) rowBuilder,
      pw.Font font,
      pw.Font fontBold,
      ) {
    // Add null checks
    final safeAssets = assets ?? [];
    final safeColumns = columns ?? [];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        for (int i = 0; i < safeColumns.length; i++)
          i: pw.FlexColumnWidth(1),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: safeColumns.map((col) =>
              pw.Padding(
                padding: pw.EdgeInsets.all(8),
                child: pw.Text(
                  col ?? '',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 11,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              )
          ).toList(),
        ),
        // Data rows with null check
        ...safeAssets.map((asset) {
          if (asset == null) {
            // Handle null asset
            return pw.TableRow(
              children: List.generate(
                  safeColumns.length,
                      (_) => pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'N/A',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                      ),
                    ),
                  )
              ),
            );
          }

          final rowData = rowBuilder(asset);
          return pw.TableRow(
            children: (rowData ?? []).map((value) =>
                pw.Padding(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Text(
                    value ?? 'N/A',
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

  // Helper functions
  dynamic _getValue(Map<String, dynamic>? asset, String key) {
    if (asset == null) return null;
    return asset[key];
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

  String _formatCurrency(dynamic value) {
    if (value == null || value == 'N/A') return 'N/A';

    try {
      double numValue;
      if (value is num) {
        numValue = value.toDouble();
      } else {
        // Try to parse string value
        final sanitizedValue = value.toString().replaceAll(RegExp(r'[^\d.]'), '');
        if (sanitizedValue.isEmpty) return 'N/A';
        numValue = double.parse(sanitizedValue);
      }
      return '\$${NumberFormat('#,##0.00').format(numValue)}';
    } catch (e) {
      return value.toString();
    }
  }

  void toggleBuildingType(String? buildingType) {
    if (buildingType == null) return;

    if (selectedBuildingTypes.contains(buildingType)) {
      selectedBuildingTypes.remove(buildingType);
    } else {
      selectedBuildingTypes.add(buildingType);
    }
  }
}