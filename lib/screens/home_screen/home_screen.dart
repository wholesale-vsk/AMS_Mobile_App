import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
      ),
      body: SingleChildScrollView(
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
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildStatisticsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard('Total Assets', '120', Icons.business, Colors.purple),
        _buildStatCard('Active Users', '30', Icons.people, Colors.teal),
        _buildStatCard('Pending Reports', '5', Icons.warning, Colors.orange),
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

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Icons.add, 'New Asset', Colors.purple, AppRoutes.ADD_ASSET_SCREEN),
        _buildActionButton(Icons.history, 'History', Colors.teal, AppRoutes.VIEW_ALL_ASSETS_SCREEN),
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

  Widget _buildFeatureGrid() {
    List<Map<String, dynamic>> features = [
      {'title': 'Assets', 'icon': Icons.business, 'route': AppRoutes.VIEW_ALL_ASSETS_SCREEN},
      {'title': 'Reports', 'icon': Icons.bar_chart, 'route': AppRoutes.ASSETS_SELECT_FOR_REPORT_SCREEN},
      {'title': 'Analytics', 'icon': Icons.show_chart, 'route': AppRoutes.DASHBOARD_SCREEN},
      {'title': 'Settings', 'icon': Icons.settings, 'route': AppRoutes.APP_SETTINGS_SCREEN},
      {'title': 'Users', 'icon': Icons.people, 'route': AppRoutes.USERS_SCREEN},
      {'title': 'Help', 'icon': Icons.help, 'route': AppRoutes.HELP_AND_SUPPORT_SCREEN},
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

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.black,
      currentIndex: _selectedIndex,
      iconSize: 30,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 0:
            Get.offNamed(AppRoutes.HOME_SCREEN);
            break;
          case 1:
            Get.offNamed(AppRoutes.user_selection_screen);
            break;
          case 2:
            Get.offNamed(AppRoutes.APP_SETTINGS_SCREEN);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
