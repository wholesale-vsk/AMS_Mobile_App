import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../controllers/assets_controllers/assets_controller.dart';
import '../../../utils/theme/app_theme_management.dart';
import '../../../utils/theme/responsive_size.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AppThemeManager themeManager = Get.find();
  final AssetController assetController = Get.find();
  Timer? autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    autoRefreshTimer?.cancel();
    super.dispose();
  }

  /// **🔄 Auto Refresh Every 30 Seconds**
  void _startAutoRefresh() {
    autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      assetController.refreshAssets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white, // ✅ No header color
        automaticallyImplyLeading: false, // ✅ Removes back button
      ),
      body: Obx(() {
        var assetSummary = _generateAssetSummary();
        var incomeSummary = _generateIncomeSummary();

        return RefreshIndicator(
          onRefresh: () async {
            await assetController.refreshAssets();
          },
          child: assetController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSize.getWidth(size: 16),
              vertical: ResponsiveSize.getHeight(size: 16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAssetCountSection(),
                const SizedBox(height: 30),

                /// **📊 Asset Summary**
                if (assetSummary.isNotEmpty) ...[
                  _buildSummarySection('Asset Summary', _buildPieChart(assetSummary)),
                  _buildPieChartLegend(assetSummary),
                ] else
                  const Center(child: Text('No asset data available.')),

                const SizedBox(height: 30),

                /// **💰 Income Summary**
                if (incomeSummary.isNotEmpty) ...[
                  _buildSummarySection('Income Summary', _buildPieChart(incomeSummary)),
                  _buildPieChartLegend(incomeSummary),
                ] else
                  const Center(child: Text('No income data available.')),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// **📊 Asset Count Section**
  Widget _buildAssetCountSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildCountCard('Buildings', assetController.totalBuildings.value.toString(), Icons.apartment_rounded, Colors.blue.shade300)),
        Expanded(child: _buildCountCard('Lands', assetController.totalLands.value.toString(), Icons.landscape_rounded, Colors.green.shade300)),
        Expanded(child: _buildCountCard('Vehicles', assetController.totalVehicles.value.toString(), Icons.directions_car_rounded, Colors.orange.shade300)),
      ],
    );
  }

  /// **📊 Build Count Card**
  Widget _buildCountCard(String label, String count, IconData icon, Color cardColor) {
    return GestureDetector(
      onTap: () => Get.toNamed('/view-all-assets', arguments: {'category': label}),
      child: Card(
        color: cardColor,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(label, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7))),
            ],
          ),
        ),
      ),
    );
  }

  /// **📊 Summary Section**
  Widget _buildSummarySection(String title, Widget chart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 10),
        Container(
          height: 300,
          padding: const EdgeInsets.all(8),
          decoration: _boxDecoration(),
          child: chart,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// **📊 Pie Chart**
  Widget _buildPieChart(List<Map<String, dynamic>> data) {
    return PieChart(
      PieChartData(
        sections: data.map((d) {
          return PieChartSectionData(
            color: d['color'],
            value: d['value'].toDouble(),
            title: d['title'],
            radius: 70,
            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
        borderData: FlBorderData(show: false),
        centerSpaceRadius: 50,
        sectionsSpace: 2,
      ),
    );
  }

  /// **📊 Pie Chart Legend**
  Widget _buildPieChartLegend(List<Map<String, dynamic>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.map((d) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: d['color'],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                d['label'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// **📊 Generate Asset Summary**
  List<Map<String, dynamic>> _generateAssetSummary() {
    int buildings = assetController.totalBuildings.value;
    int vehicles = assetController.totalVehicles.value;
    int lands = assetController.totalLands.value;
    int total = buildings + vehicles + lands;

    if (total == 0) return [];

    return [
      {'color': Colors.blue, 'value': (buildings / total) * 100, 'title': '${(buildings / total * 100).toStringAsFixed(1)}%', 'label': 'Buildings'},
      {'color': Colors.green, 'value': (lands / total) * 100, 'title': '${(lands / total * 100).toStringAsFixed(1)}%', 'label': 'Lands'},
      {'color': Colors.orange, 'value': (vehicles / total) * 100, 'title': '${(vehicles / total * 100).toStringAsFixed(1)}%', 'label': 'Vehicles'},
    ];
  }

  /// **📊 Generate Income Summary**
  List<Map<String, dynamic>> _generateIncomeSummary() {
    double buildingIncome = assetController.totalBuildings.value * 50000;
    double landIncome = assetController.totalLands.value * 30000;
    double vehicleIncome = assetController.totalVehicles.value * 20000;
    double totalIncome = buildingIncome + landIncome + vehicleIncome;

    if (totalIncome == 0) return [];

    return [
      {'color': Colors.blue, 'value': (buildingIncome / totalIncome) * 100, 'title': '${(buildingIncome / totalIncome * 100).toStringAsFixed(1)}%', 'label': 'Building Income'},
      {'color': Colors.green, 'value': (landIncome / totalIncome) * 100, 'title': '${(landIncome / totalIncome * 100).toStringAsFixed(1)}%', 'label': 'Land Income'},
      {'color': Colors.orange, 'value': (vehicleIncome / totalIncome) * 100, 'title': '${(vehicleIncome / totalIncome * 100).toStringAsFixed(1)}%', 'label': 'Vehicle Income'},
    ];
  }

  /// **🎨 Box Decoration**
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
    );
  }
}
