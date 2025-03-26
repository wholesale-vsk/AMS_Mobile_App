import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/utils/theme/responsive_size.dart';
import '../../../../routes/app_routes.dart';

class AddAssetScreen extends StatefulWidget {
  @override
  _AddAssetScreenState createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<AssetOption> assetOptions = [
    AssetOption(
      title: "Add Vehicle",
      icon: Icons.directions_car_filled_rounded,
      route: AppRoutes.ADD_VEHICLE_SCREEN,
      description: "Cars, trucks, motorcycles, and other vehicles",
      color: Colors.blue,
    ),
    AssetOption(
      title: "Add Land",
      icon: Icons.location_on_rounded,
      route: AppRoutes.ADD_LAND_SCREEN,
      description: "Land, plots, and property parcels",
      color: Colors.green,
    ),
    AssetOption(
      title: "Add Building",
      icon: Icons.apartment_rounded,
      route: AppRoutes.ADD_BUILDING_SCREEN,
      description: "Commercial and residential buildings",
      color: Colors.orange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    final Color backgroundColor = isDarkMode
        ? Color(0xFF121212)
        : Color(0xFFF5F7FA);
    final Color cardColor = isDarkMode
        ? Color(0xFF1E1E1E)
        : Colors.white;
    final Color textColor = isDarkMode
        ? Colors.white
        : Color(0xFF2D3142);
    final Color subtitleColor = isDarkMode
        ? Colors.grey[400]!
        : Color(0xFF9A9A9A);

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => Get.back(),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        //       color: isDarkMode ? Colors.white : Colors.black87,
        //     ),
        //     onPressed: () => Get.changeThemeMode(
        //       isDarkMode ? ThemeMode.light : ThemeMode.dark,
        //     ),
        //   ),
        //   SizedBox(width: 8),
        // ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add Asset",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Select the type of asset you want to add",
                          style: TextStyle(
                            fontSize: 16,
                            color: subtitleColor,
                          ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          children: [
                            // Text(
                            //   "Asset Types",
                            //   style: TextStyle(
                            //     fontSize: 18,
                            //     fontWeight: FontWeight.w600,
                            //     color: textColor,
                            //   ),
                            // ),
                            Spacer(),
                            // TextButton(
                            //   onPressed: () {
                            //     // View all functionality
                            //   },
                            //   child: Text(
                            //     "View All",
                            //     style: TextStyle(
                            //       color: Theme.of(context).primaryColor,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        // Staggered animations for list items
                        return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            final itemAnimation = Tween<double>(
                              begin: 0.0,
                              end: 1.0,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(
                                  0.4 + (index * 0.1),
                                  0.7 + (index * 0.1),
                                  curve: Curves.easeOut,
                                ),
                              ),
                            );

                            return FadeTransition(
                              opacity: itemAnimation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset(0, 0.2),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: Interval(
                                      0.4 + (index * 0.1),
                                      0.7 + (index * 0.1),
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                                ),
                                child: child,
                              ),
                            );
                          },
                          child: _buildAssetCard(
                            assetOptions[index],
                            isDarkMode,
                            cardColor,
                            textColor,
                            subtitleColor,
                          ),
                        );
                      },
                      childCount: assetOptions.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Quick add functionality
      //   },
      //   backgroundColor: Theme.of(context).primaryColor,
      //   child: Icon(Icons.add),
      //   elevation: 4,
      // ),
    );
  }

  Widget _buildAssetCard(
      AssetOption option,
      bool isDarkMode,
      Color cardColor,
      Color textColor,
      Color subtitleColor,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Get.toNamed(option.route),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: option.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    option.icon,
                    color: option.color,
                    size: 26,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        option.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: option.color,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AssetOption {
  final String title;
  final IconData icon;
  final String route;
  final String description;
  final Color color;

  AssetOption({
    required this.title,
    required this.icon,
    required this.route,
    required this.description,
    required this.color,
  });
}