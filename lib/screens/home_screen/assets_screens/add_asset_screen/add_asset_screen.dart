import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/utils/theme/responsive_size.dart';
import '../../../../routes/app_routes.dart';

class AddAssetScreen extends StatefulWidget {
  @override
  _AddAssetScreenState createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> with SingleTickerProviderStateMixin {
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 200), () {
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
          "Add Assets",
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
              horizontal: ResponsiveSize.getWidth(size: 20),
              vertical: ResponsiveSize.getHeight(size: 25),
            ),
            child: Column(
              children: [
                // Header with Icon
                _buildHeader(context),

                SizedBox(height: 30),

                // Asset Cards
                Expanded(
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      AssetCard(
                        title: "Add Vehicle",
                        icon: Icons.directions_car_filled_rounded,
                        route: AppRoutes.ADD_VEHICLE_SCREEN,
                        primaryColor: primaryColor,
                      ),
                      AssetCard(
                        title: "Add Land",
                        icon: Icons.location_on_rounded,
                        route: AppRoutes.ADD_LAND_SCREEN,
                        primaryColor: primaryColor,
                      ),
                      AssetCard(
                        title: "Add Building",
                        icon: Icons.apartment_rounded,
                        route: AppRoutes.ADD_BUILDING_SCREEN,
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
          child: Icon(Icons.inventory_2_rounded, size: 50, color: Colors.blue),
        ),
        SizedBox(height: 15),
        Text(
          "Select an Asset Type",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 5),
        Text(
          "Choose the asset category to manage it",
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.black54,
          ),
        ),
      ],
    );
  }
}

class AssetCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final String route;
  final Color primaryColor;

  const AssetCard({
    required this.title,
    required this.icon,
    required this.route,
    required this.primaryColor,
    Key? key,
  }) : super(key: key);

  @override
  _AssetCardState createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_animationController);
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.2), end: Offset(0, 0))
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    Color cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;

    return GestureDetector(
      onTapDown: (_) => _animationController.reverse(), // Tap animation
      onTapUp: (_) {
        _animationController.forward();
        Future.delayed(Duration(milliseconds: 100), () {
          Get.toNamed(widget.route);
        });
      },
      onTapCancel: () => _animationController.forward(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(bottom: ResponsiveSize.getHeight(size: 20)),
            padding: EdgeInsets.all(ResponsiveSize.getWidth(size: 18)),
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
                    color: widget.primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: widget.primaryColor, size: 30),
                ),
                SizedBox(width: 18),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: widget.primaryColor, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
