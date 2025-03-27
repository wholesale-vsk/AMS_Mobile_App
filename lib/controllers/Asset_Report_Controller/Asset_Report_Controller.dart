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
    selectedAssetTypes.value = assetController.categories
        .where((category) => category != 'All')
        .toList();

    // Initialize with some building types selected
    selectedBuildingTypes.value = ['RESIDENTIAL', 'COMMERCIAL'];
  }

  void toggleAssetType(String assetType) {
    if (assetType == null) return;

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
    if (type != null) {
      reportType.value = type;
      _logger.i("📊 Report type set to: $type");
    }
  }

  void toggleIncludeCharts() {
    includeCharts.value = !includeCharts.value;
  }

  // Get filtered assets based on selected types and date range
  List<Map<String, dynamic>> getFilteredAssets() {
    if (selectedAssetTypes.isEmpty) return [];

    return assetController.assets.where((asset) {
      if (asset == null) return false;

      // Filter by asset type
      final category = asset['category'];
      if (category == null || !selectedAssetTypes.contains(category)) {
        return false;
      }

      // Apply building type filter for Building assets
      if (category == 'Building' &&
          selectedBuildingTypes.isNotEmpty &&
          asset.containsKey('buildingType')) {
        String? buildingType = asset['buildingType'] as String?;
        if (buildingType == null || !selectedBuildingTypes.contains(buildingType)) {
          return false;
        }
      }

      // Apply property type filter for Land assets
      if (category == 'Land' &&
          selectedBuildingTypes.isNotEmpty &&
          asset.containsKey('landType')) {
        String? landType = asset['landType'] as String?;
        if (landType == null || !selectedBuildingTypes.contains(landType)) {
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
          _logger.w("⚠️ Could not parse date for asset: ${asset['name'] ?? asset['model'] ?? 'Unknown'}");
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

      // Create PDF document based on report type
      final pdf = await _createPdfReport(filteredAssets, reportType.value);

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
        rowBuilder = (asset) => [
          _getValue(asset, 'name') ?? _getValue(asset, 'model') ?? 'N/A',
          _getValue(asset, 'category') ?? 'N/A',
          _getTypeValue(asset),
          _formatCurrency(_getValue(asset, 'purchasePrice')),
        ];
        break;
      case 'Detailed Report':
        columns = ['Asset Name', 'Category', 'Type', 'Purchase Date', 'Purchase Price', 'Location'];
        rowBuilder = (asset) => [
          _getValue(asset, 'name') ?? _getValue(asset, 'model') ?? 'N/A',
          _getValue(asset, 'category') ?? 'N/A',
          _getTypeValue(asset),
          _formatDate(_getValue(asset, 'purchaseDate')),
          _formatCurrency(_getValue(asset, 'purchasePrice')),
          _getLocationValue(asset),
        ];
        break;
      case 'Financial Analysis':
        columns = ['Asset Name', 'Category', 'Purchase Price', 'Current Value', 'Depreciation'];
        rowBuilder = (asset) => [
          _getValue(asset, 'name') ?? _getValue(asset, 'model') ?? 'N/A',
          _getValue(asset, 'category') ?? 'N/A',
          _formatCurrency(_getValue(asset, 'purchasePrice')),
          _formatCurrency(_calculateCurrentValue(asset)),
          _calculateDepreciation(asset),
        ];
        break;
      case 'Maintenance Report':
        columns = ['Asset Name', 'Category', 'Type', 'Last Maintenance', 'Status', 'Notes'];
        rowBuilder = (asset) => [
          _getValue(asset, 'name') ?? _getValue(asset, 'model') ?? 'N/A',
          _getValue(asset, 'category') ?? 'N/A',
          _getTypeValue(asset),
          _formatDate(_getValue(asset, 'lastMaintenance') ?? 'N/A'),
          _getMaintenanceStatus(asset),
          _getValue(asset, 'maintenanceNotes') ?? 'No notes',
        ];
        break;
      default:
        columns = ['Asset Name', 'Category', 'Type', 'Purchase Date', 'Purchase Price'];
        rowBuilder = (asset) => [
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
        build: (context) => [
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
  pw.Widget _buildSummaryStats(List<Map<String, dynamic>> assets, pw.Font font, pw.Font fontBold) {
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
              _buildStatItem('Total Assets', '${assets.length}', font, fontBold),
              _buildStatItem('Total Value', _formatCurrency(totalValue), font, fontBold),
              _buildStatItem('Date Range', '${_formatDate(startDate.value)} - ${_formatDate(endDate.value)}', font, fontBold),
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
                _buildStatItem(entry.key, '${entry.value}', font, fontBold, flex: 1)
            ).toList(),
          ),
        ],
      ),
    );
  }

  // Build charts section
  pw.Widget _buildCharts(List<Map<String, dynamic>> assets, pw.Font font, pw.Font fontBold) {
    // Count by category
    Map<String, int> categoryCounts = {};
    for (var asset in assets) {
      String category = _getValue(asset, 'category') ?? 'Unknown';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
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
              final maxCount = categoryCounts.values.reduce((a, b) => a > b ? a : b);
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
  pw.Widget _buildStatItem(String label, String value, pw.Font font, pw.Font fontBold, {int flex = 1}) {
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
                  selectedAssetTypes.isNotEmpty ? selectedAssetTypes.join(', ') : 'None',
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
  pw.Widget _buildAssetTable(
      List<Map<String, dynamic>> assets,
      List<String> columns,
      List<dynamic> Function(Map<String, dynamic>) rowBuilder,
      pw.Font font,
      pw.Font fontBold,
      ) {
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

  // Helper functions
  dynamic _getValue(Map<String, dynamic> asset, String key) {
    return asset[key];
  }

  String _getTypeValue(Map<String, dynamic> asset) {
    final category = asset['category'];
    if (category == 'Building') {
      return asset['buildingType'] ?? 'N/A';
    } else if (category == 'Vehicle') {
      return asset['vehicle_type'] ?? asset['type'] ?? 'N/A';
    } else if (category == 'Land') {
      return asset['landType'] ?? 'N/A';
    }
    return 'N/A';
  }

  String _getLocationValue(Map<String, dynamic> asset) {
    final category = asset['category'];
    if (category == 'Building' || category == 'Land') {
      if (asset['address'] != null && asset['city'] != null) {
        return '${asset['address']}, ${asset['city']}';
      } else if (asset['address'] != null) {
        return asset['address'];
      } else if (asset['city'] != null) {
        return asset['city'];
      }
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
        final sanitizedValue = value.toString().replaceAll(RegExp(r'[^\d.]'), '');
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

  void toggleBuildingType(String? buildingType) {
    if (buildingType == null) return;

    if (selectedBuildingTypes.contains(buildingType)) {
      selectedBuildingTypes.remove(buildingType);
    } else {
      selectedBuildingTypes.add(buildingType);
    }
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

  // Get maintenance status for maintenance report
  String _getMaintenanceStatus(Map<String, dynamic> asset) {
    // For vehicles we can use MOT date to determine status
    String category = _getValue(asset, 'category') ?? '';

    if (category == 'Vehicle') {
      var motDate = _getValue(asset, 'motExpiredDate') ?? _getValue(asset, 'motDate');
      if (motDate != null && motDate != 'N/A') {
        try {
          DateTime expiryDate = DateTime.parse(motDate.toString());
          if (expiryDate.isBefore(DateTime.now())) {
            return 'OVERDUE';
          } else if (expiryDate.isBefore(DateTime.now().add(Duration(days: 30)))) {
            return 'DUE SOON';
          } else {
            return 'VALID';
          }
        } catch (e) {
          return 'UNKNOWN';
        }
      }
    }

    // For other assets
    return 'N/A';
  }
}