import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/controllers/assets_controllers/assets_controller.dart';
import 'package:hexalyte_ams/utils/theme/responsive_size.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../routes/app_routes.dart';

class AssetsViewScreen extends StatefulWidget {
  @override
  _AssetsViewScreenState createState() => _AssetsViewScreenState();
}

class _AssetsViewScreenState extends State<AssetsViewScreen> {
  final AssetController controller = Get.find<AssetController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    double threshold = Get.height * 0.2;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - threshold &&
        !controller.isFetchingMore.value) {
      controller.loadMoreAssets();
    }
  }

  void deleteAsset(Map<String, dynamic> asset) {
    Get.defaultDialog(
      title: "Delete Asset",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: "Are you sure you want to delete this asset?",
      contentPadding: const EdgeInsets.all(20),
      radius: 10,
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.grey[700],
      backgroundColor: Colors.white,
      onConfirm: () {
        controller.deleteAsset(asset);
        Get.back();
        Get.back();
        Get.snackbar(
          "Asset Deleted",
          "The asset has been successfully deleted.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          borderRadius: 10,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        );
      },
      onCancel: () => Get.back(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Assets',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: controller.refreshAssets,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: ResponsiveSize.getWidth(size: 16),
          right: ResponsiveSize.getWidth(size: 16),
          top: ResponsiveSize.getHeight(size: 16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildAssetCategories(),
            const SizedBox(height: 20),
            Expanded(child: _buildAssetsGrid()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          // Add navigation to asset creation screen
          // Get.toNamed(AppRoutes.CREATE_ASSET_SCREEN);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        decoration: InputDecoration(
          hintText: "Search assets...",
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildAssetCategories() {
    final categories = ['All', 'Vehicle', 'Land', 'Building'];

    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final bool isSelected = controller.selectedCategory.value == category;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Material(
                  color: isSelected ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  elevation: isSelected ? 3 : 1,
                  child: InkWell(
                    onTap: () {
                      controller.selectedCategory.value = category;
                      if (category == "All") {
                        controller.fetchAllAssets();
                      } else {
                        controller.changeCategory(category);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildAssetsGrid() {
    return RefreshIndicator(
      onRefresh: controller.refreshAssets,
      backgroundColor: Colors.white,
      color: Colors.blue,
      child: Obx(() {
        final filteredAssets = controller.filteredAssets;

        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        }

        if (filteredAssets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey[400]),
                const SizedBox(height: 15),
                Text(
                  'No assets available',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.only(bottom: 80), // Space for FAB
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: filteredAssets.length,
          itemBuilder: (context, index) => _buildAssetCard(filteredAssets[index]),
        );
      }),
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> asset) {
    String categoryIcon = 'building';
    Color categoryColor = Colors.blue;

    switch (asset['category']) {
      case 'Vehicle':
        categoryIcon = '🚗';
        categoryColor = Colors.orange;
        break;
      case 'Land':
        categoryIcon = '🏞️';
        categoryColor = Colors.green;
        break;
      case 'Building':
        categoryIcon = '🏢';
        categoryColor = Colors.purple;
        break;
      default:
        categoryIcon = '📦';
        categoryColor = Colors.blue;
    }

    return InkWell(
      onTap: () => _navigateToDetails(asset),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _buildAssetImage(asset['imageUrl'] ?? asset['imageURL']),
                ),
                // Category tag
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          categoryIcon,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          asset['category'] ?? 'Asset',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // More options button
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: (String result) {
                        if (result == 'delete') {
                          deleteAsset(asset);
                        }
                      },
                      icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset['name'] ?? 'Unknown Asset',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          asset['vrn'] ?? asset['type'] ?? 'No Data',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetImage(String? imageUrl) {
    const String defaultImage = 'https://via.placeholder.com/150';

    return CachedNetworkImage(
      imageUrl: (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : defaultImage,
      width: double.infinity,
      height: ResponsiveSize.getHeight(size: 120),
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildLoadingImage(),
      errorWidget: (context, url, error) => _buildErrorImage(),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      width: double.infinity,
      height: ResponsiveSize.getHeight(size: 120),
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      width: double.infinity,
      height: ResponsiveSize.getHeight(size: 120),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 30, color: Colors.grey[400]),
            const SizedBox(height: 4),
            Text(
              'No image',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(Map<String, dynamic> asset) {
    final routeMap = {
      'Vehicle': AppRoutes.VEHICLE_DETAILS_SCREEN,
      'Land': AppRoutes.LAND_DETAILS_SCREEN,
      'Building': AppRoutes.BUILDING_DETAILS_SCREEN,
    };
    print("asset onpress "+asset.toString());
    Get.toNamed(routeMap[asset['category']] ?? AppRoutes.VIEW_ALL_ASSETS_SCREEN, arguments: asset);
  }
}