import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart'; // For currency formatting
import '../../../controllers/assets_controllers/assets_controller.dart';

class PdfGeneratorForAll {
  static Future<void> generatePdf(BuildContext context, String reportType, {required List<Map<String, dynamic>> data}) async {
    try {
      final AssetController assetsController = Get.put(AssetController());
      final allAssets = assetsController.filteredAssets;

      if (allAssets.isEmpty) {
        Get.snackbar(
          'No Data', 'No assets available to generate the report.',
          backgroundColor: Colors.red, colorText: Colors.white,
        );
        return;
      }

      final tables = getAssetSummaryData(allAssets);

      // Create PDF document
      PdfDocument document = PdfDocument()
        ..pageSettings.size = PdfPageSize.a4
        ..pageSettings.margins.all = 30;

      final page = document.pages.add();
      final graphics = page.graphics;
      final pageWidth = page.getClientSize().width;

      // **Add Header with Background**
      final headerRect = Rect.fromLTWH(0, 0, pageWidth, 50);
      graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(0, 51, 102)), // Dark Blue Header
        bounds: headerRect,
      );

      graphics.drawString(
        '$reportType Report',
        PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold),
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(0, 10, pageWidth, 30),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );

      // Add summary table
      double currentY = 70;
      currentY = await addAssetSummaryTable(document, page, tables, currentY);

      // Save PDF
      List<int> bytes = await document.save();
      document.dispose();

      // Save file
      final directory = await getApplicationSupportDirectory();
      final filePath = '${directory.path}/$reportType-Report.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      // Open PDF
      await OpenFile.open(filePath);
      print('PDF generated successfully: $reportType Report');
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

  /// Generates asset summary data for tables
  static List<Map<String, dynamic>> getAssetSummaryData(List<dynamic> assets) {
    List<Map<String, dynamic>> tables = [];

    // Grouping assets
    Map<String, List<dynamic>> assetGroups = {
      'Building': [],
      'Land': [],
      'Vehicle': [],
      'Equipment': [],
    };

    for (var asset in assets) {
      String type = asset['c-type']?.toString() ?? 'Unknown';
      assetGroups.update(type, (list) => list..add(asset), ifAbsent: () => [asset]);
    }

    // Formatting numbers
    String formatNumber(double value) {
      return NumberFormat("#,###.00").format(value);
    }

    double calculateTotalValue(List<dynamic> assetsList) {
      return assetsList.fold(0.0, (sum, asset) {
        dynamic value = asset['value'];
        double parsedValue = value is num
            ? value.toDouble()
            : double.tryParse(value.toString().replaceAll(',', '')) ?? 0.0;
        return sum + parsedValue;
      });
    }

    tables.add({
      'title': 'Asset Summary',
      'data': [
        ['Asset Type', 'Total Count', 'Total Value '],
        ['Building', assetGroups['Building']!.length.toString(), formatNumber(calculateTotalValue(assetGroups['Building']!))],
        ['Land', assetGroups['Land']!.length.toString(), formatNumber(calculateTotalValue(assetGroups['Land']!))],
        ['Vehicle', assetGroups['Vehicle']!.length.toString(), formatNumber(calculateTotalValue(assetGroups['Vehicle']!))],
        ['Equipment', assetGroups['Equipment']!.length.toString(), formatNumber(calculateTotalValue(assetGroups['Equipment']!))],
      ]
    });

    return tables;
  }

  /// Draws asset summary table on the PDF page with styling
  static Future<double> addAssetSummaryTable(
      PdfDocument document, PdfPage page, List<Map<String, dynamic>> tables, double currentY) async {
    try {
      for (var table in tables) {
        final graphics = page.graphics;
        final pageWidth = page.getClientSize().width;

        // **Draw Table Title with Underline**
        graphics.drawString(
          table['title'],
          PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold),
          bounds: Rect.fromLTWH(0, currentY, pageWidth, 25),
          format: PdfStringFormat(alignment: PdfTextAlignment.left),
        );
        currentY += 30;
        graphics.drawLine(PdfPen(PdfColor(0, 51, 102)), Offset(0, currentY), Offset(pageWidth, currentY));
        currentY += 10;

        // **Create Table Grid**
        PdfGrid grid = PdfGrid();
        grid.columns.add(count: table['data'][0].length);

        // **Create Header Row with Blue Background**
        PdfGridRow header = grid.headers.add(1)[0];
        for (int i = 0; i < table['data'][0].length; i++) {
          header.cells[i].value = table['data'][0][i];
        }
        header.style = PdfGridCellStyle(
          backgroundBrush: PdfBrushes.darkBlue,
          textBrush: PdfBrushes.white,
          font: PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
        );

        // **Add Data Rows with Alternating Colors**
        for (int i = 1; i < table['data'].length; i++) {
          PdfGridRow row = grid.rows.add();
          for (int j = 0; j < table['data'][i].length; j++) {
            row.cells[j].value = table['data'][i][j];
          }

          if (i % 2 == 0) {
            row.style.backgroundBrush = PdfBrushes.lightGray;
          }
        }

        // **Set Grid Style**
        grid.style = PdfGridStyle(
          cellPadding: PdfPaddings(left: 10, right: 10, top: 5, bottom: 5),
          font: PdfStandardFont(PdfFontFamily.helvetica, 10),
        );

        // **Draw Grid and Update Position**
        final result = grid.draw(
          page: page,
          bounds: Rect.fromLTWH(0, currentY, pageWidth, 0),
        );
        currentY = result!.bounds.bottom + 20;
      }
      return currentY;
    } catch (e) {
      print('Error in addAssetSummaryTable: $e');
      return currentY;
    }
  }
}
