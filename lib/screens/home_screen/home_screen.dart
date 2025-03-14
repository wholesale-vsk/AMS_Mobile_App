import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';

import 'package:hexalyte_ams/routes/app_routes.dart';
import '../../controllers/assets_controllers/assets_controller.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final AssetController _assetController = Get.put(AssetController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _assetController.fetchAllAssets(); // Initial asset fetch
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _silentRefreshAssets(); // Silent refresh when app resumes
    }
  }

  /// **🔄 Silent Refresh Function**
  void _silentRefreshAssets() async {
    Future.delayed(Duration(milliseconds: 500), () async {
      await _assetController.refreshAssets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 3,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: () async {
              await _assetController.refreshAssets();
            }, // Manual refresh
          )
        ],
      ),
      body: Obx(() {
        // **Avoid showing loading indicator for silent refresh**
        if (_assetController.isLoading.value && !_assetController.isRefreshing.value) {
          return Center(child: CircularProgressIndicator());
        }
        return _buildBody();
      }),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsSection(),
          SizedBox(height: 20),
          _buildQuickActions(),
          SizedBox(height: 20),
          _buildFeatureGrid(),
        ],
      ),
    );
  }

  /// **📊 Statistics Section**
  Widget _buildStatisticsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard('Total Assets', _assetController.totalAssets.value.toString(), Icons.business, Colors.purple),
        _buildStatCard('Buildings', _assetController.totalBuildings.value.toString(), Icons.apartment, Colors.teal),
        _buildStatCard('Vehicles', _assetController.totalVehicles.value.toString(), Icons.directions_car, Colors.orange),
        _buildStatCard('Lands', _assetController.totalLands.value.toString(), Icons.landscape, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 30, color: color),
              SizedBox(height: 10),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  /// **🚀 Quick Action Buttons**
  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Icons.add, 'New Asset', Colors.purple, AppRoutes.ADD_ASSET_SCREEN),
        _buildActionButton(Icons.history, 'History', Colors.teal, AppRoutes.VEHICLE_UPDATE_SCREEN),
        _buildActionButton(Icons.notifications, 'Alerts', Colors.orange, AppRoutes.NOTIFICATION_SCREEN),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, String route) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            radius: 30,
            child: Icon(icon, size: 30, color: color),
          ),
          SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// **📦 Feature Grid**
  Widget _buildFeatureGrid() {
    List<Map<String, dynamic>> features = [
      {'title': 'Assets', 'icon': Icons.business, 'route': AppRoutes.VIEW_ALL_ASSETS_SCREEN},
      {'title': 'Reports', 'icon': Icons.bar_chart, 'route': AppRoutes.ASSETS_SELECT_FOR_REPORT_SCREEN},
      {'title': 'Analytics', 'icon': Icons.show_chart, 'route': AppRoutes.DASHBOARD_SCREEN},
      {'title': 'Settings', 'icon': Icons.settings, 'route': AppRoutes.LAND_UPDATE_SCREEN},
      {'title': 'Chat', 'icon': Icons.chat, 'route': AppRoutes.VEHICLE_UPDATE_SCREEN},
      {'title': 'Help', 'icon': Icons.help, 'route': AppRoutes.BUILDING_UPDATE_SCREEN},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Get.toNamed(features[index]['route']),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(features[index]['icon'], size: 40, color: Colors.black),
                SizedBox(height: 10),
                Text(
                  features[index]['title'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
