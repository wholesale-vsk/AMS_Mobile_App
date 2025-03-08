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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Assets',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: controller.refreshAssets,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveSize.getWidth(size: 16), // ✅ Fixed
          vertical: ResponsiveSize.getHeight(size: 16), // ✅ Fixed
        ),
        child: Column(
          children: [
            _buildAssetCategories(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildAssetsGrid()),
          ],
        ),
      ),
    );
  }

  /// ✅ Fixed `_buildSearchBar()`
  Widget _buildSearchBar() {
    return TextField(
      onChanged: controller.updateSearchQuery,
      decoration: InputDecoration(
        hintText: "Search assets...",
        prefixIcon: const Icon(Icons.search, color: Colors.black),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// ✅ Fixed `_buildAssetCategories()` so "All" loads everything correctly
  Widget _buildAssetCategories() {
    final categories = ['All', 'Vehicle', 'Land', 'Building'];

    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final bool isSelected = controller.selectedCategory.value == category;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ChoiceChip(
                label: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) {
                  controller.selectedCategory.value = category; // ✅ Ensure correct selection
                  if (category == "All") {
                    controller.fetchAllAssets(); // ✅ Fetch all assets when "All" is selected
                  } else {
                    controller.changeCategory(category);
                  }
                },
                selectedColor: Colors.blue,
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: Colors.blue,
                  width: 1.5,
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  /// ✅ Fixed `_buildAssetsGrid()` for better performance
  Widget _buildAssetsGrid() {
    return RefreshIndicator(
      onRefresh: controller.refreshAssets,
      child: Obx(() {
        final filteredAssets = controller.filteredAssets;

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (filteredAssets.isEmpty) {
          return const Center(
            child: Text(
              'No assets available',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          );
        }

        return GridView.builder(
          key: const PageStorageKey<String>('assets_grid'),
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: filteredAssets.length,
          itemBuilder: (context, index) => _buildAssetCard(filteredAssets[index]),
        );
      }),
    );
  }

  /// ✅ Fixed `_buildAssetCard()`
  Widget _buildAssetCard(Map<String, dynamic> asset) {
    return InkWell(
      onTap: () => _navigateToDetails(asset),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: _buildAssetImage(asset['imageUrl'] ?? asset['imageURL']),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    asset['name'] ?? 'Unknown Asset',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    asset['vrn'] ?? asset['type'] ?? 'No Data',
                    style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Fixed `_buildAssetImage()` to handle null images properly
  Widget _buildAssetImage(String? imageUrl) {
    const String defaultImage = 'https://via.placeholder.com/150';

    return CachedNetworkImage(
      imageUrl: (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : defaultImage,
      width: double.infinity,
      height: ResponsiveSize.getHeight(size: 100), // ✅ Fixed
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildErrorImage(),
      errorWidget: (context, url, error) => _buildErrorImage(),
    );
  }

  /// ✅ Fixed `_buildErrorImage()`
  Widget _buildErrorImage() {
    return Container(
      width: double.infinity,
      height: ResponsiveSize.getHeight(size: 100), // ✅ Fixed
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
    );
  }

  /// ✅ Fixed `_navigateToDetails()`
  void _navigateToDetails(Map<String, dynamic> asset) {
    final routeMap = {
      'Vehicle': AppRoutes.VEHICLE_DETAILS_SCREEN,
      'Land': AppRoutes.LAND_DETAILS_SCREEN,
      'Building': AppRoutes.BUILDING_DETAILS_SCREEN,
    };
    Get.toNamed(routeMap[asset['category']] ?? AppRoutes.VIEW_ALL_ASSETS_SCREEN, arguments: asset);
  }
}
