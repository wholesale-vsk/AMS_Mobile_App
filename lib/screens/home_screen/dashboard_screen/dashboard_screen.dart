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

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  final AppThemeManager themeManager = Get.find();
  final AssetController assetController = Get.find();
  Timer? autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startAutoRefresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    autoRefreshTimer?.cancel();
    super.dispose();
  }

  /// **🔄 Auto Refresh Every 30 Seconds**
  void _startAutoRefresh() {
    autoRefreshTimer?.cancel(); // Prevent duplicate timers
    autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      assetController.refreshAssets();
    });
  }

  /// **🔄 Detect App Resuming from Background**
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      assetController.refreshAssets(); // Refresh when app resumes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Asset Dashboard',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [




        ],
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        var assetSummary = _generateAssetSummary();
        var incomeSummary = _generateIncomeSummary();

        return RefreshIndicator(
          onRefresh: () async {
            await assetController.refreshAssets();
          },
          child: assetController.isLoading.value
              ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
            ),
          )
              : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveSize.getWidth(size: 16),
              vertical: ResponsiveSize.getHeight(size: 16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAssetTotalCard(),
                const SizedBox(height: 20),
                _buildAssetCountSection(),
                const SizedBox(height: 30),

                /// **📊 Asset Summary**
                if (assetSummary.isNotEmpty) ...[
                  _buildSummarySection('Asset Distribution', _buildPieChart(assetSummary)),
                  _buildPieChartLegend(assetSummary),
                ] else
                  _buildEmptyDataCard('No asset data available'),

                const SizedBox(height: 30),

                /// **💰 Income Summary**
                if (incomeSummary.isNotEmpty) ...[
                  _buildSummarySection('Income Distribution', _buildPieChart(incomeSummary)),
                  _buildPieChartLegend(incomeSummary),
                ] else
                  _buildEmptyDataCard('No income data available'),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3498DB),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Show a modal bottom sheet with options to add different assets
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => _buildAddAssetBottomSheet(),
          );
        },
      ),
    );
  }

  /// Build total assets card with animation
  Widget _buildAssetTotalCard() {
    int totalAssets = assetController.totalBuildings.value +
        assetController.totalLands.value +
        assetController.totalVehicles.value;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Total Assets',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF7F8C8D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              totalAssets.toString(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: totalAssets > 0 ? 1.0 : 0.0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF3498DB),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **📊 Asset Count Section**
  Widget _buildAssetCountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Asset Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildCountCard(
                'Buildings',
                assetController.totalBuildings.value.toString(),
                Icons.apartment_rounded,
                const Color(0xFF3498DB),
              ),
            ),
            Expanded(
              child: _buildCountCard(
                'Lands',
                assetController.totalLands.value.toString(),
                Icons.landscape_rounded,
                const Color(0xFF2ECC71),
              ),
            ),
            Expanded(
              child: _buildCountCard(
                'Vehicles',
                assetController.totalVehicles.value.toString(),
                Icons.directions_car_rounded,
                const Color(0xFFE67E22),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// **📊 Build Count Card**
  Widget _buildCountCard(String label, String count, IconData icon, Color cardColor) {
    return GestureDetector(
      onTap: () => Get.toNamed('/view-all-assets', arguments: {'category': label}),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 30, color: cardColor),
              ),
              const SizedBox(height: 12),
              Text(
                count,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: _boxDecoration(),
          child: chart,
        ),
        const SizedBox(height: 12),
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
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
            ),
            badgeWidget: _getIconForSection(d['label']),
            badgePositionPercentageOffset: 1.1,
          );
        }).toList(),
        borderData: FlBorderData(show: false),
        centerSpaceRadius: 50,
        sectionsSpace: 2,
      ),
    );
  }

  /// Get icon widget for pie chart section
  Widget? _getIconForSection(String label) {
    IconData iconData;
    Color iconColor;

    switch (label) {
      case 'Buildings':
      case 'Building Income':
        iconData = Icons.apartment_rounded;
        iconColor = Colors.blue;
        break;
      case 'Lands':
      case 'Land Income':
        iconData = Icons.landscape_rounded;
        iconColor = Colors.green;
        break;
      case 'Vehicles':
      case 'Vehicle Income':
        iconData = Icons.directions_car_rounded;
        iconColor = Colors.orange;
        break;
      default:
        return null;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
      ),
      child: Icon(iconData, size: 16, color: iconColor),
    );
  }

  /// **📊 Pie Chart Legend**
  Widget _buildPieChartLegend(List<Map<String, dynamic>> data) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.map((d) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: d['color'],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    d['label'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                Text(
                  d['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Empty data placeholder
  Widget _buildEmptyDataCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _boxDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.data_usage,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => assetController.refreshAssets(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Refresh Data'),
          ),
        ],
      ),
    );
  }

  /// Add asset bottom sheet
  Widget _buildAddAssetBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add New Asset',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAssetTypeButton(
                'Building',
                Icons.apartment_rounded,
                const Color(0xFF3498DB),
                    () => Get.toNamed('/add-building'),
              ),
              _buildAssetTypeButton(
                'Land',
                Icons.landscape_rounded,
                const Color(0xFF2ECC71),
                    () => Get.toNamed('/add-land'),
              ),
              _buildAssetTypeButton(
                'Vehicle',
                Icons.directions_car_rounded,
                const Color(0xFFE67E22),
                    () => Get.toNamed('/add-vehicle'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Asset type button for bottom sheet
  Widget _buildAssetTypeButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 36,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  /// **📊 Generate Income Summary**
  List<Map<String, dynamic>> _generateIncomeSummary() {
    double buildingIncome = assetController.totalBuildings.value * 5000000;
    double landIncome = assetController.totalLands.value * 3000000;
    double vehicleIncome = assetController.totalVehicles.value * 2000000;
    double totalIncome = buildingIncome + landIncome + vehicleIncome;

    if (totalIncome == 0) return [];

    return [
      {
        'color': const Color(0xFF3498DB),
        'value': (buildingIncome / totalIncome) * 100,
        'title': '${(buildingIncome / totalIncome * 100).toStringAsFixed(1)}%',
        'label': 'Building Income'
      },
      {
        'color': const Color(0xFF2ECC71),
        'value': (landIncome / totalIncome) * 100,
        'title': '${(landIncome / totalIncome * 100).toStringAsFixed(1)}%',
        'label': 'Land Income'
      },
      {
        'color': const Color(0xFFE67E22),
        'value': (vehicleIncome / totalIncome) * 100,
        'title': '${(vehicleIncome / totalIncome * 100).toStringAsFixed(1)}%',
        'label': 'Vehicle Income'
      },
    ];
  }

  /// **📊 Generate Asset Summary**
  List<Map<String, dynamic>> _generateAssetSummary() {
    int buildings = assetController.totalBuildings.value;
    int vehicles = assetController.totalVehicles.value;
    int lands = assetController.totalLands.value;
    int total = buildings + vehicles + lands;

    if (total == 0) return [];

    return [
      {
        'color': const Color(0xFF3498DB),
        'value': (buildings / total) * 100,
        'title': '${(buildings / total * 100).toStringAsFixed(1)}%',
        'label': 'Buildings'
      },
      {
        'color': const Color(0xFF2ECC71),
        'value': (lands / total) * 100,
        'title': '${(lands / total * 100).toStringAsFixed(1)}%',
        'label': 'Lands'
      },
      {
        'color': const Color(0xFFE67E22),
        'value': (vehicles / total) * 100,
        'title': '${(vehicles / total * 100).toStringAsFixed(1)}%',
        'label': 'Vehicles'
      },
    ];
  }

  /// **🎨 Box Decoration**
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    );
  }
}