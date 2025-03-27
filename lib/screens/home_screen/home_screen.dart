import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:hexalyte_ams/routes/app_routes.dart';
import '../../controllers/assets_controllers/assets_controller.dart';
import 'package:google_fonts/google_fonts.dart';

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

  /// Silent refresh function
  void _silentRefreshAssets() async {
    Future.delayed(Duration(milliseconds: 500), () async {
      await _assetController.refreshAssets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Asset Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => _assetController.isRefreshing.value
              ? Container(
            width: 48,
            height: 48,
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B46C1)),
            ),
          )
              : IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF6B46C1)),
            onPressed: () async {
              await _assetController.refreshAssets();
            },
            tooltip: 'Refresh data',
          ),
          ),
        ],

      ),
      body: RefreshIndicator(
        color: Color(0xFF6B46C1),
        backgroundColor: Colors.white,
        onRefresh: () async {
          await _assetController.refreshAssets();
        },
        child: Obx(() {
          if (_assetController.isLoading.value && !_assetController.isRefreshing.value) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B46C1)),
              ),
            );
          }
          return _buildBody();
        }),
      ),

    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          SizedBox(height: 24),
          _buildAssetSummary(),
          SizedBox(height: 24),
          _buildQuickActions(),
          SizedBox(height: 24),
          _buildFeatureGrid(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6B46C1).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back!',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Here\'s your asset overview',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Asset Summary',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        Row(
          children: [
            _buildStatCard('Total Assets', _assetController.totalAssets.value.toString(), Icons.business, Color(0xFF6B46C1)),
            SizedBox(width: 12),
            _buildStatCard('Buildings', _assetController.totalBuildings.value.toString(), Icons.apartment, Color(0xFF38B2AC)),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard('Vehicles', _assetController.totalVehicles.value.toString(), Icons.directions_car, Color(0xFFDD6B20)),
            SizedBox(width: 12),
            _buildStatCard('Lands', _assetController.totalLands.value.toString(), Icons.landscape, Color(0xFF48BB78)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(Icons.add, 'New Asset', Color(0xFF6B46C1), AppRoutes.ADD_ASSET_SCREEN),
              // _buildActionButton(Icons.history, 'History', Color(0xFF38B2AC), AppRoutes.ASSET_HISTORY_SCREEN),
              _buildActionButton(Icons.notifications, 'Alerts', Color(0xFFDD6B20), AppRoutes.NOTIFICATION_SCREEN),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, String route) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    List<Map<String, dynamic>> features = [
      {'title': 'Assets', 'icon': Icons.business, 'route': AppRoutes.VIEW_ALL_ASSETS_SCREEN, 'color': Color(0xFF6B46C1)},
      {'title': 'Reports', 'icon': Icons.bar_chart, 'route': AppRoutes.ASSETS_SELECT_FOR_REPORT_SCREEN, 'color': Color(0xFF38B2AC)},
      {'title': 'Analytics', 'icon': Icons.show_chart, 'route': AppRoutes.DASHBOARD_SCREEN, 'color': Color(0xFF9F7AEA)},
      {'title': 'Settings', 'icon': Icons.settings, 'route': AppRoutes.APP_SETTINGS_SCREEN, 'color': Color(0xFF4A5568)},
      {'title': 'Chat', 'icon': Icons.chat, 'route': AppRoutes.USER_SELECTION_SCREEN, 'color': Color(0xFFDD6B20)},
      {'title': 'Help', 'icon': Icons.help, 'route': AppRoutes.HELP_AND_SUPPORT_SCREEN, 'color': Color(0xFF48BB78)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Features',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => Get.toNamed(features[index]['route']),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: features[index]['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        features[index]['icon'],
                        size: 28,
                        color: features[index]['color'],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      features[index]['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}