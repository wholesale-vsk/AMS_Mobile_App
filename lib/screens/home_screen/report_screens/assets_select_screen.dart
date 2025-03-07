import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/theme/app_theme_management.dart';
import '../../../utils/theme/responsive_size.dart';

class AssetsSelectForReports extends StatefulWidget {
  @override
  _AssetsSelectForReportsState createState() => _AssetsSelectForReportsState();
}

class _AssetsSelectForReportsState extends State<AssetsSelectForReports> {
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color backgroundColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Asset Reports",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedOpacity(
        opacity: opacity,
        duration: Duration(milliseconds: 500),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [Colors.black, Colors.grey[900]!]
                  : [Colors.white, Colors.grey[200]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 25.0,
            ),
            child: Column(
              children: [
                _buildHeader(context),
                SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      ReportCard(
                        title: "Vehicle Reports",
                        icon: Icons.directions_car_rounded,
                        route: AppRoutes.VEHICLE_REPORT_SCREEN,
                        primaryColor: primaryColor,
                      ),
                      ReportCard(
                        title: "Land Reports",
                        icon: Icons.landscape_rounded,
                        route: AppRoutes.LAND_REPORT_SCREEN,
                        primaryColor: primaryColor,
                      ),
                      ReportCard(
                        title: "Building Reports",
                        icon: Icons.apartment_rounded,
                        route: AppRoutes.BUILDING_REPORT_SCREEN,
                        primaryColor: primaryColor,
                      ),
                      ReportCard(
                        title: "Total Assets Overview",
                        icon: Icons.dashboard_rounded,
                        route: AppRoutes.TOTAL_ASSETS_REPORT_SCREEN,
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blue.withOpacity(0.2),
          child: Icon(Icons.analytics_rounded, size: 50, color: Colors.blue),
        ),
        SizedBox(height: 15),
        Text(
          "View & Analyze Reports",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 5),
        Text(
          "Select a category to generate reports",
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.black54,
          ),
        ),
      ],
    );
  }
}

class ReportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;
  final Color primaryColor;

  const ReportCard({
    required this.title,
    required this.icon,
    required this.route,
    required this.primaryColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    Color cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;
    Color iconBackgroundColor = primaryColor.withOpacity(0.2);

    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: 20.0),
        padding: EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 3,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryColor, size: 30),
            ),
            SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}
