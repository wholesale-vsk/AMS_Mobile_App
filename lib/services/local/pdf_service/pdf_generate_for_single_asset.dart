import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../controllers/assets_controllers/assets_controller.dart';

class PdfGenerator {
  static Future<void> generatePdf(BuildContext context, String reportType, {required List<Map<String, dynamic>> data}) async {
    try {
      await _requestPermission();
      final filteredAssets = data;

      if (filteredAssets.isEmpty) {
        _showDialog(context, 'No $reportType assets available.', false);
        return;
      }

      PdfDocument document = PdfDocument();
      document.pageSettings.size = PdfPageSize.a4;
      document.pageSettings.margins.all = 30;

      document.documentInformation
        ..title = '$reportType Report'
        ..author = 'Hexalyte Technology'
        ..creationDate = DateTime.now();

      PdfPage page = document.pages.add();
      _drawHeader(page, reportType);

      double currentY = 100;
      for (var asset in filteredAssets) {
        double assetHeight = _calculateAssetHeight(asset);
        if (currentY + assetHeight > page.getClientSize().height) {
          page = document.pages.add();
          _drawHeader(page, reportType);
          currentY = 100;
        }
        currentY = _drawAssetCard(page, asset, currentY);
      }

      List<int> bytes = await document.save();
      document.dispose();

      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final sanitizedReportType = reportType.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final path = '${directory!.path}/$sanitizedReportType-Report-$timestamp.pdf';

      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);

      if (await file.exists()) {
        _showDialog(context, 'PDF saved successfully at: $path', true);
        await OpenFile.open(path);
      } else {
        print('❌ PDF generation failed.');
      }
    } catch (e) {
      print('❌ Error generating PDF for $reportType: $e');
      _showDialog(context, 'Failed to generate PDF for $reportType. Please try again.', false);
    }
  }

  static Future<void> _requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission not granted');
      }
    }
  }

  static void _drawHeader(PdfPage page, String reportType) {
    page.graphics.drawRectangle(
      bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 80),
      brush: PdfSolidBrush(PdfColor(40, 44, 52)),
    );

    page.graphics.drawString(
      '$reportType Report',
      PdfStandardFont(PdfFontFamily.helvetica, 28, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(10, 25, page.getClientSize().width - 20, 40),
      brush: PdfBrushes.white,
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
  }

  static double _drawAssetCard(PdfPage page, Map<String, dynamic> asset, double currentY) {
    double cardHeight = _calculateAssetHeight(asset);

    page.graphics.drawRectangle(
      bounds: Rect.fromLTWH(20, currentY, page.getClientSize().width - 40, cardHeight),
      brush: PdfSolidBrush(PdfColor(240, 240, 240)),
      pen: PdfPen(PdfColor(100, 100, 100)),
    );

    double detailY = currentY + 10;
    asset.forEach((key, value) {
      page.graphics.drawString(
        '$key: $value',
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(30, detailY, page.getClientSize().width - 60, 20),
      );
      detailY += 20;
    });

    return currentY + cardHeight + 10;
  }

  static double _calculateAssetHeight(Map<String, dynamic> asset) {
    return 20.0 + (asset.length * 20);
  }

  static void _showDialog(BuildContext context, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSuccess ? 'Success' : 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
