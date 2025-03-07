import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../controllers/assets_controllers/assets_controller.dart';

class PdfGenerator {
  static Future<void> generatePdf(BuildContext context, String reportType, {required List<Map<String, dynamic>> data}) async {
    try {
      final AssetController assetsController = Get.put(AssetController());

      // Filter assets based on report type
      final filteredAssets = assetsController.filteredAssets
          .where((asset) => asset['category'] == reportType)
          .toList();

      if (filteredAssets.isEmpty) {
        throw Exception('No $reportType assets available');
      }

      // Prepare asset data for PDF tables
      final tables = _getAssetData(reportType, filteredAssets);

      // Create PDF document
      PdfDocument document = PdfDocument();
      document.pageSettings.size = PdfPageSize.a4;
      document.pageSettings.margins.all = 30;
      final page = document.pages.add();

      // Add header
      page.graphics.drawString(
        '$reportType Report',
        PdfStandardFont(PdfFontFamily.helvetica, 24),
        bounds: Rect.fromLTWH(0, 20, page.getClientSize().width, 30),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );

      // Add tables dynamically
      double currentY = 70; // Start below the header
      for (var table in tables) {
        currentY = await _addTable(document, page, table['title'], table['data'], currentY);
      }

      // Save PDF
      List<int> bytes = await document.save();
      document.dispose();

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$reportType-Report.pdf');
      await file.writeAsBytes(bytes, flush: true);

      // Open PDF
      await OpenFile.open(file.path);
      print('✅ PDF generated successfully: $reportType Report');
    } catch (e) {
      print('❌ Error generating PDF: $e');
    }
  }

  static List<Map<String, dynamic>> _getAssetData(String type, List<dynamic> assets) {
    switch (type) {
      case 'Building':
        return [
          {
            'title': 'Building Details',
            'data': [
              ['Name', 'Type', 'Floors'],
              ...assets.map((a) => [
                a['name'] ?? 'N/A',
                a['buildingType'] ?? 'N/A',
                a['numberOfFloors']?.toString() ?? 'N/A'
              ])
            ]
          },
          {
            'title': 'Location Details',
            'data': [
              ['Name', 'Address', 'City', 'Province'],
              ...assets.map((a) => [
                a['name'] ?? 'N/A',
                a['address'] ?? 'N/A',
                a['city'] ?? 'N/A',
                a['province'] ?? 'N/A'
              ])
            ]
          },
          {
            'title': 'Financial Details',
            'data': [
              ['Name', 'Construction Type', 'Cost'],
              ...assets.map((a) => [
                a['name'] ?? 'N/A',
                a['constructionType'] ?? 'N/A',
                a['purchasePrice']?.toString() ?? 'N/A'
              ])
            ]
          },
        ];
      case 'Land':
        return [
          {
            'title': 'Land Details',
            'data': [
              ['Name', 'Type', 'Size (Acres)'],
              ...assets.map((a) => [
                a['name'] ?? 'N/A',
                a['type'] ?? 'N/A',
                a['size']?.toString() ?? 'N/A'
              ])
            ]
          },
          {
            'title': 'Location Details',
            'data': [
              ['Name', 'Address', 'City', 'Province'],
              ...assets.map((a) => [
                a['name'] ?? 'N/A',
                a['address'] ?? 'N/A',
                a['city'] ?? 'N/A',
                a['province'] ?? 'N/A'
              ])
            ]
          },
          {
            'title': 'Financial Details',
            'data': [
              ['Name', 'Purchase Date', 'Value'],
              ...assets.map((a) => [
                a['name'] ?? 'N/A',
                a['purchaseDate'] ?? 'N/A',
                'LKR ${a['purchasePrice']?.toString() ?? 'N/A'}'
              ])
            ]
          },
        ];
      case 'Vehicle':
        return [
          {
            'title': 'Vehicle Details',
            'data': [
              ['VRN', 'Type', 'Model'],
              ...assets.map((a) => [
                a['vrn'] ?? 'N/A',
                a['vehicleCategory'] ?? 'N/A',
                a['model'] ?? 'N/A'
              ])
            ]
          },
          {
            'title': 'MOT Details',
            'data': [
              ['VRN', 'MOT Date', 'MOT Value'],
              ...assets.map((a) => [
                a['vrn'] ?? 'N/A',
                a['motDate'] ?? 'N/A',
                a['motValue']?.toString() ?? 'N/A'
              ])
            ]
          },
          {
            'title': 'Insurance Details',
            'data': [
              ['VRN', 'Insurance Date', 'Insurance Value'],
              ...assets.map((a) => [
                a['vrn'] ?? 'N/A',
                a['insuranceDate'] ?? 'N/A',
                a['insuranceValue']?.toString() ?? 'N/A'
              ])
            ]
          },
          {
            'title': 'Finance Details',
            'data': [
              ['VRN', 'Purchase Date', 'Value'],
              ...assets.map((a) => [
                a['vrn'] ?? 'N/A',
                a['purchaseDate'] ?? 'N/A',
                'LKR ${a['purchasePrice']?.toString() ?? 'N/A'}'
              ])
            ]
          },
        ];
      default:
        return [];
    }
  }

  static Future<double> _addTable(PdfDocument document, PdfPage page,
      String title, List<List<dynamic>> rows, double currentY) async {
    try {
      page.graphics.drawString(
        title,
        PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(0, currentY, page.getClientSize().width, 25),
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
      );
      currentY += 30;

      PdfGrid grid = PdfGrid();
      grid.columns.add(count: rows[0].length);
      PdfGridRow header = grid.headers.add(1)[0];

      for (int i = 0; i < rows[0].length; i++) {
        header.cells[i].value = rows[0][i];
      }

      header.style = PdfGridCellStyle(
        backgroundBrush: PdfBrushes.gray,
        textBrush: PdfBrushes.white,
        font: PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
      );

      for (int i = 1; i < rows.length; i++) {
        PdfGridRow row = grid.rows.add();
        for (int j = 0; j < rows[i].length; j++) {
          row.cells[j].value = rows[i][j];
        }
      }

      final result = grid.draw(
        page: page,
        bounds: Rect.fromLTWH(0, currentY, page.getClientSize().width, 0),
      );

      return result!.bounds.bottom + 20;
    } catch (e) {
      print('❌ Error in _addTable: $e');
      return currentY;
    }
  }
}
