import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../controllers/assets_controllers/assets_controller.dart';

class ModernPdfGenerator {
  // Colors for PDF design
  static final PdfColor brandBlue = PdfColor(0, 120, 212);     // Primary blue
  static final PdfColor darkBlue = PdfColor(0, 90, 158);       // Darker shade for headings
  static final PdfColor lightBlue = PdfColor(229, 241, 251);   // Light blue for backgrounds
  static final PdfColor darkGray = PdfColor(70, 70, 70);       // For text
  static final PdfColor lightGray = PdfColor(240, 240, 240);   // For alternating rows
  static final PdfColor black = PdfColor(0, 0, 0);             // For important text
  static final PdfColor white = PdfColor(255, 255, 255);       // For backgrounds and text

  /// Generates a professional PDF report for a list of assets
  ///
  /// [context] - BuildContext for showing dialogs
  /// [reportTitle] - Title of the report
  /// [data] - List of assets to include in the report
  /// [companyName] - Optional company name (defaults to "Hexalyte Technology")
  /// [companyAddress] - Optional company address for the footer
  /// [logoPath] - Optional path to company logo (not implemented in this version)
  static Future<void> generateReport(
      BuildContext context,
      String reportTitle, {
        required List<Map<String, dynamic>> data,
        String companyName = "Hexalyte Technology",
        String? companyAddress,
        String? logoPath,
      }) async {
    try {
      // Check storage permissions
      await _checkStoragePermission();

      final assets = data;

      // Validate there's data to show
      if (assets.isEmpty) {
        _showResultDialog(context, 'No data available for $reportTitle report.', false);
        return;
      }

      // Create PDF document with A4 size
      final PdfDocument document = PdfDocument();
      document.pageSettings.size = PdfPageSize.a4;
      document.pageSettings.margins = PdfMargins()..all = 30;

      // Set document properties
      document.documentInformation
        ..title = '$reportTitle Report'
        ..author = companyName
        ..subject = 'Asset Management System Report'
        ..creator = 'Hexalyte Asset Manager'
        ..creationDate = DateTime.now();

      // Create pages
      _addTitlePage(document, reportTitle, companyName);
      _addTableOfContents(document, assets, reportTitle);
      _addAssetsPages(document, assets, reportTitle);

      // Add footer to all pages
      _addPageNumbers(document, companyName);

      // Save the document
      final List<int> bytes = await document.save();
      document.dispose();

      // Get directory for saving
      final Directory? directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      // Generate filename with timestamp
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String sanitizedTitle = reportTitle.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final String filePath = '${directory.path}/${sanitizedTitle}_report_$timestamp.pdf';

      // Write file
      final File file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      // Verify and open
      if (await file.exists()) {
        _showResultDialog(context, 'Report saved successfully at: $filePath', true);
        await OpenFile.open(filePath);
      } else {
        throw Exception('File was not created');
      }

    } catch (e) {
      print('❌ Error generating PDF report: $e');
      _showResultDialog(context, 'Failed to generate report: ${e.toString()}', false);
    }
  }

  /// Adds a professionally designed title page to the document
  static void _addTitlePage(PdfDocument document, String reportTitle, String companyName) {
    final PdfPage page = document.pages.add();
    final Size pageSize = page.getClientSize();
    final double width = pageSize.width;
    final double height = pageSize.height;

    // Create a blue banner at the top
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, width, height * 0.4),
        brush: PdfSolidBrush(brandBlue)
    );

    // Add white title text on the blue background
    page.graphics.drawString(
        reportTitle.toUpperCase(),
        PdfStandardFont(PdfFontFamily.helvetica, 36, style: PdfFontStyle.bold),
        brush: PdfSolidBrush(white),
        bounds: Rect.fromLTWH(40, height * 0.15, width - 80, 50),
        format: PdfStringFormat(alignment: PdfTextAlignment.center)
    );

    // Add subtitle
    page.graphics.drawString(
        'ASSET MANAGEMENT REPORT',
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        brush: PdfSolidBrush(white),
        bounds: Rect.fromLTWH(40, height * 0.24, width - 80, 30),
        format: PdfStringFormat(alignment: PdfTextAlignment.center)
    );

    // Add a decorative line at the bottom of the blue section
    page.graphics.drawLine(
        PdfPen(white, width: 3),
        Offset(width * 0.3, height * 0.35),
        Offset(width * 0.7, height * 0.35)
    );

    // Add company information in the white area
    page.graphics.drawString(
        'Prepared by:',
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.italic),
        brush: PdfSolidBrush(darkGray),
        bounds: Rect.fromLTWH(width * 0.1, height * 0.5, width * 0.8, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center)
    );

    page.graphics.drawString(
        companyName,
        PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold),
        brush: PdfSolidBrush(brandBlue),
        bounds: Rect.fromLTWH(width * 0.1, height * 0.55, width * 0.8, 30),
        format: PdfStringFormat(alignment: PdfTextAlignment.center)
    );

    // Add current date
    final String dateStr = DateFormat('MMMM d, yyyy').format(DateTime.now());
    page.graphics.drawString(
        'Generated on: $dateStr',
        PdfStandardFont(PdfFontFamily.helvetica, 14),
        brush: PdfSolidBrush(darkGray),
        bounds: Rect.fromLTWH(width * 0.1, height * 0.65, width * 0.8, 20),
        format: PdfStringFormat(alignment: PdfTextAlignment.center)
    );

    // Add a decorative bottom element
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, height - 20, width, 20),
        brush: PdfSolidBrush(brandBlue)
    );
  }

  /// Creates a table of contents page
  static void _addTableOfContents(PdfDocument document, List<Map<String, dynamic>> assets, String reportTitle) {
    PdfPage currentPage = document.pages.add();
    Size pageSize = currentPage.getClientSize();
    double yPosition = 50;

    // Draw page header
    _drawSectionHeader(currentPage, 'TABLE OF CONTENTS', yPosition);
    yPosition += 60;

    // Draw table header
    _drawTableHeader(currentPage, ['Asset Name', 'Page Number'], [0.7, 0.3], yPosition);
    yPosition += 40;

    // Draw table rows for each asset
    for (int i = 0; i < assets.length; i++) {
      final asset = assets[i];
      final String assetName = _getAssetName(asset, i);

      // Draw row with alternating background
      final bool isEvenRow = i % 2 == 0;
      final PdfColor rowColor = isEvenRow ? lightGray : white;

      currentPage.graphics.drawRectangle(
          bounds: Rect.fromLTWH(40, yPosition, pageSize.width - 80, 30),
          brush: PdfSolidBrush(rowColor),
          pen: PdfPen(PdfColor(200, 200, 200))
      );

      // Draw asset name
      currentPage.graphics.drawString(
          assetName,
          PdfStandardFont(PdfFontFamily.helvetica, 12),
          brush: PdfSolidBrush(darkGray),
          bounds: Rect.fromLTWH(50, yPosition + 8, (pageSize.width - 80) * 0.7 - 10, 20)
      );

      // Draw page number (asset index + 3 to account for title and TOC pages)
      currentPage.graphics.drawString(
          (i + 3).toString(),
          PdfStandardFont(PdfFontFamily.helvetica, 12),
          brush: PdfSolidBrush(darkGray),
          bounds: Rect.fromLTWH(
              50 + (pageSize.width - 80) * 0.7,
              yPosition + 8,
              (pageSize.width - 80) * 0.3 - 10,
              20
          ),
          format: PdfStringFormat(alignment: PdfTextAlignment.center)
      );

      yPosition += 30;

      // Add a new page if needed
      if (yPosition > pageSize.height - 100 && i < assets.length - 1) {
        currentPage = document.pages.add();
        pageSize = currentPage.getClientSize(); // Update page size for the new page
        yPosition = 50;

        // Draw continued header
        _drawSectionHeader(currentPage, 'TABLE OF CONTENTS (CONTINUED)', yPosition);
        yPosition += 60;

        // Draw table header again
        _drawTableHeader(currentPage, ['Asset Name', 'Page Number'], [0.7, 0.3], yPosition);
        yPosition += 40;
      }
    }

    // Summary section
    yPosition += 20;
    Size currentPageSize = currentPage.getClientSize();
    currentPage.graphics.drawString(
        'Total Assets: ${assets.length}',
        PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
        brush: PdfSolidBrush(brandBlue),
        bounds: Rect.fromLTWH(40, yPosition, currentPageSize.width - 80, 20)
    );
  }

  /// Creates individual pages for each asset
  static void _addAssetsPages(PdfDocument document, List<Map<String, dynamic>> assets, String reportTitle) {
    for (int i = 0; i < assets.length; i++) {
      final asset = assets[i];
      PdfPage currentPage = document.pages.add();
      double yPosition = 50;

      // Draw page header
      _drawSectionHeader(currentPage, '$reportTitle DETAILS', yPosition);
      yPosition += 60;

      // Get asset name for the subheader
      final String assetName = _getAssetName(asset, i);

      // Draw asset name as subheader
      Size pageSize = currentPage.getClientSize();
      currentPage.graphics.drawRectangle(
          bounds: Rect.fromLTWH(40, yPosition, pageSize.width - 80, 40),
          brush: PdfSolidBrush(darkBlue),
          pen: PdfPen(darkBlue)
      );

      currentPage.graphics.drawString(
          assetName,
          PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold),
          brush: PdfSolidBrush(white),
          bounds: Rect.fromLTWH(50, yPosition + 10, pageSize.width - 100, 20)
      );

      yPosition += 50;

      // Draw asset properties table
      final List<String> keys = asset.keys.toList();

      // Draw properties table
      for (int j = 0; j < keys.length; j++) {
        final String key = keys[j];
        final String value = asset[key]?.toString() ?? 'N/A';

        // Skip if name is already shown in header
        if (key.toLowerCase() == 'name') continue;

        // Draw row with alternating background
        final bool isEvenRow = j % 2 == 0;
        final PdfColor rowColor = isEvenRow ? lightGray : white;

        pageSize = currentPage.getClientSize(); // Refresh page size in case page changed
        currentPage.graphics.drawRectangle(
            bounds: Rect.fromLTWH(40, yPosition, pageSize.width - 80, 30),
            brush: PdfSolidBrush(rowColor),
            pen: PdfPen(PdfColor(200, 200, 200))
        );

        // Format property name for display
        final String formattedKey = _formatPropertyName(key);

        // Draw property name
        currentPage.graphics.drawString(
            formattedKey,
            PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
            brush: PdfSolidBrush(darkGray),
            bounds: Rect.fromLTWH(50, yPosition + 8, (pageSize.width - 80) * 0.4 - 10, 20)
        );

        // Draw property value
        currentPage.graphics.drawString(
            value,
            PdfStandardFont(PdfFontFamily.helvetica, 12),
            brush: PdfSolidBrush(black),
            bounds: Rect.fromLTWH(
                50 + (pageSize.width - 80) * 0.4,
                yPosition + 8,
                (pageSize.width - 80) * 0.6 - 10,
                20
            )
        );

        yPosition += 30;

        // Add a new page if needed
        if (yPosition > pageSize.height - 100 && j < keys.length - 1) {
          currentPage = document.pages.add();
          yPosition = 50;

          // Draw continued header
          _drawSectionHeader(currentPage, '$reportTitle DETAILS (CONTINUED)', yPosition);
          yPosition += 60;

          // Draw asset name again
          pageSize = currentPage.getClientSize(); // Get new page size
          currentPage.graphics.drawRectangle(
              bounds: Rect.fromLTWH(40, yPosition, pageSize.width - 80, 40),
              brush: PdfSolidBrush(darkBlue),
              pen: PdfPen(darkBlue)
          );

          currentPage.graphics.drawString(
              '$assetName (Continued)',
              PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold),
              brush: PdfSolidBrush(white),
              bounds: Rect.fromLTWH(50, yPosition + 10, pageSize.width - 100, 20)
          );

          yPosition += 50;
        }
      }
    }
  }

  /// Add page numbers and footer to all pages
  static void _addPageNumbers(PdfDocument document, String companyName) {
    for (int i = 0; i < document.pages.count; i++) {
      final PdfPage page = document.pages[i];
      final Size pageSize = page.getClientSize();

      // Skip page number on title page
      if (i > 0) {
        // Add page number
        page.graphics.drawString(
            'Page ${i + 1} of ${document.pages.count}',
            PdfStandardFont(PdfFontFamily.helvetica, 10),
            brush: PdfSolidBrush(darkGray),
            bounds: Rect.fromLTWH(pageSize.width - 100, pageSize.height - 25, 60, 20),
            format: PdfStringFormat(alignment: PdfTextAlignment.right)
        );
      }

      // Add footer line
      page.graphics.drawLine(
          PdfPen(PdfColor(200, 200, 200)),
          Offset(40, pageSize.height - 40),
          Offset(pageSize.width - 40, pageSize.height - 40)
      );

      // Add company name in footer
      page.graphics.drawString(
          companyName,
          PdfStandardFont(PdfFontFamily.helvetica, 10),
          brush: PdfSolidBrush(darkGray),
          bounds: Rect.fromLTWH(40, pageSize.height - 25, 200, 20)
      );

      // Add date on right side of footer (if not title page)
      if (i > 0) {
        String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        page.graphics.drawString(
            dateStr,
            PdfStandardFont(PdfFontFamily.helvetica, 10),
            brush: PdfSolidBrush(darkGray),
            bounds: Rect.fromLTWH(pageSize.width - 200, pageSize.height - 25, 100, 20),
            format: PdfStringFormat(alignment: PdfTextAlignment.right)
        );
      }
    }
  }

  /// Helper to draw a section header
  static void _drawSectionHeader(PdfPage page, String title, double yPosition) {
    final Size pageSize = page.getClientSize();

    // Draw header background
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, yPosition - 10, pageSize.width, 50),
        brush: PdfSolidBrush(brandBlue)
    );

    // Draw header text
    page.graphics.drawString(
        title,
        PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold),
        brush: PdfSolidBrush(white),
        bounds: Rect.fromLTWH(40, yPosition, pageSize.width - 80, 30),
        format: PdfStringFormat(alignment: PdfTextAlignment.center)
    );

    // Draw accent line
    page.graphics.drawLine(
        PdfPen(white, width: 2),
        Offset(pageSize.width * 0.3, yPosition + 35),
        Offset(pageSize.width * 0.7, yPosition + 35)
    );
  }

  /// Helper to draw a table header
  static void _drawTableHeader(PdfPage page, List<String> columns, List<double> widthRatios, double yPosition) {
    final Size pageSize = page.getClientSize();
    final double tableWidth = pageSize.width - 80;

    // Draw header background
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(40, yPosition, tableWidth, 30),
        brush: PdfSolidBrush(darkBlue),
        pen: PdfPen(darkBlue)
    );

    // Draw column headers
    double xOffset = 50;
    for (int i = 0; i < columns.length; i++) {
      final double columnWidth = tableWidth * widthRatios[i] - 10;

      page.graphics.drawString(
          columns[i].toUpperCase(),
          PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
          brush: PdfSolidBrush(white),
          bounds: Rect.fromLTWH(xOffset, yPosition + 8, columnWidth, 20),
          format: i == columns.length - 1 ? PdfStringFormat(alignment: PdfTextAlignment.center) : null
      );

      xOffset += tableWidth * widthRatios[i];
    }
  }

  /// Helper to get asset name
  static String _getAssetName(Map<String, dynamic> asset, int index) {
    if (asset.containsKey('name') && asset['name'] != null) {
      return asset['name'].toString();
    } else if (asset.containsKey('id') && asset['id'] != null) {
      return asset['id'].toString();
    } else if (asset.containsKey('title') && asset['title'] != null) {
      return asset['title'].toString();
    } else {
      return 'Asset ${index + 1}';
    }
  }

  /// Helper to format property names for display
  static String _formatPropertyName(String key) {
    // Convert snake_case or camelCase to Title Case
    String formatted = key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')  // Add space before capitals
        .replaceAll('_', ' ')                                                    // Replace underscores with spaces
        .trim();                                                                 // Remove leading/trailing spaces

    // Capitalize first letter of each word
    formatted = formatted.split(' ').map((word) =>
    word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
    ).join(' ');

    return formatted;
  }

  /// Check for storage permission
  static Future<void> _checkStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        if (!result.isGranted) {
          throw Exception('Storage permission is required to save the report');
        }
      }
    }
  }

  /// Show result dialog
  static void _showResultDialog(BuildContext context, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isSuccess ? 'Success' : 'Error',
          style: TextStyle(
              color: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.bold
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
            style: TextButton.styleFrom(
              foregroundColor: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
      ),
    );
  }
}