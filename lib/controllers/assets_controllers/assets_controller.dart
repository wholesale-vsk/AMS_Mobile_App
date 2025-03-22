import 'dart:ui';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:hexalyte_ams/models/assets/building/building_model.dart';
import 'package:hexalyte_ams/models/assets/land/land_model.dart';
import 'package:hexalyte_ams/models/assets/vehicle/vehicle_model.dart';
import 'package:hexalyte_ams/services/data/load_vehicle.dart';
import 'package:hexalyte_ams/services/data/load_land.dart';
import 'package:hexalyte_ams/services/data/load_building.dart';

class AssetController extends GetxController {
  final Logger _logger = Logger();
  final LoadVehicleService _vehicleService = Get.put(LoadVehicleService());
  final LoadBuildingService _buildingService = Get.put(LoadBuildingService());
  final LoadLandsService _landService = Get.put(LoadLandsService());

  final List<String> categories = ['All', 'Building', 'Vehicle', 'Land'];

  var selectedCategory = 'All'.obs;
  var searchQuery = ''.obs;
  var assets = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var isFetchingMore = false.obs;

  var hasMoreBuildings = true.obs;
  var hasMoreVehicles = true.obs;
  var hasMoreLands = true.obs;

  var totalBuildings = 0.obs;
  var totalVehicles = 0.obs;
  var totalLands = 0.obs;
  var totalAssets = 0.obs;

  // Added total asset value property
  var totalAssetValue = 0.0.obs;

  var currentVehiclePage = 1.obs;
  var currentBuildingPage = 1.obs;
  var currentLandPage = 1.obs;

  @override
  void onInit() {
    fetchAllAssets();
    super.onInit();
  }

  /// **🔄 Fetch all assets initially**
  Future<void> fetchAllAssets() async {
    try {
      isLoading(true);
      _logger.i("🔄 Fetching All Assets...");

      var results = await Future.wait([
        _fetchBuildings(),
        _fetchVehicles(),
        _fetchLands(),
      ]);

      assets.value = results.expand((element) => element).toList();
      totalAssets.value = totalBuildings.value + totalVehicles.value + totalLands.value;

      // Calculate total asset value
      _calculateTotalAssetValue();

      _updateLoadMoreFlags();
      _logger.i("📌 Total Assets Loaded: ${assets.length}");
    } catch (e) {
      _logger.e("❌ Error fetching assets: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Calculate the total value of all assets
  void _calculateTotalAssetValue() {
    double total = 0.0;

    for (var asset in assets) {
      if (asset.containsKey('purchasePrice') && asset['purchasePrice'] != null) {
        // Handle different data types
        var price = asset['purchasePrice'];

        if (price is String) {
          // Convert string to double if possible
          final sanitizedPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
          if (sanitizedPrice.isNotEmpty) {
            total += double.tryParse(sanitizedPrice) ?? 0.0;
          }
        } else if (price is num) {
          // Already a number
          total += price.toDouble();
        }
      }
    }

    totalAssetValue.value = total;
    _logger.i("💰 Total Asset Value Calculated: \$${totalAssetValue.value}");
  }

  /// **🔄 Load More Assets (Infinite Scroll)**
  Future<void> loadMoreAssets() async {
    if (isFetchingMore.value) return;

    try {
      isFetchingMore(true);
      _logger.i("📦 Loading more assets...");

      var newAssets = await Future.wait([
        if (hasMoreBuildings.value) _fetchBuildings(page: currentBuildingPage.value + 1),
        if (hasMoreVehicles.value) _fetchVehicles(page: currentVehiclePage.value + 1),
        if (hasMoreLands.value) _fetchLands(page: currentLandPage.value + 1),
      ]);

      assets.addAll(newAssets.expand((element) => element));
      _incrementPageNumbers();
      _updateLoadMoreFlags();

      // Recalculate total value
      _calculateTotalAssetValue();

      _logger.i("📌 Total Assets After Load More: ${assets.length}");
    } catch (e) {
      _logger.e("❌ Error loading more assets: $e");
    } finally {
      isFetchingMore(false);
    }
  }

  /// **🔄 Refresh all assets (Pull-to-Refresh)**
  Future<void> refreshAssets() async {
    try {
      isRefreshing(true);
      _logger.i("🔄 Refreshing Assets...");

      _resetPagination();
      await fetchAllAssets();

      _logger.i("📌 Total Assets After Refresh: ${assets.length}");
    } catch (e) {
      _logger.e("❌ Error refreshing assets: $e");
      Get.snackbar(
        "Refresh Failed",
        "Could not update assets. Try again later.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFdc3545),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isRefreshing(false);
    }
  }

  /// **🔍 Update search query & refresh UI**
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// **🔄 Change category & refresh assets**
  void changeCategory(String category) {
    if (selectedCategory.value != category) {
      selectedCategory.value = category;
      fetchAllAssets();
    }
  }

  /// **🔍 Get filtered & searched assets**
  List<Map<String, dynamic>> get filteredAssets {
    final query = searchQuery.value.toLowerCase();
    return assets.where((asset) {
      bool matchesCategory = selectedCategory.value == 'All' || asset['category'] == selectedCategory.value;
      bool matchesSearch = query.isEmpty || (asset['name'] ?? '').toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }
  /// **🏗 Fetch Buildings with Pagination**
  Future<List<Map<String, dynamic>>> _fetchBuildings({int page = 1}) async {
    try {
      _logger.i("🏗 Fetching buildings... Page: $page");

      var response = await _buildingService.fetchBuildings();
      totalBuildings.value = response['totalElements'] ?? 0;

      List<Building> buildings = (response['buildings'] ?? []).cast<Building>();
      List<Map<String, dynamic>> buildingAssets = buildings.map((b) => {
        "category": "Building",

        "name": (b.name?.trim().isNotEmpty ?? false) ? b.name!.trim() : "N/A",
        "buildingType": b.buildingType ?? "N/A",
        "numberOfFloors": b.numberOfFloors.toString(), // Ensures it's a string
        "totalArea": b.totalArea.toString(), // Ensures it's a string
        "address": b.address ?? "N/A",
        "purposeOfUse": b.purposeOfUse ?? "N/A",
        "councilTaxValue": b.councilTaxValue.toString(), // Ensures it's a string
        "councilTaxDate": b.councilTaxDate?.toString() ?? "N/A", // Convert DateTime properly
        "city": b.city ?? "N/A",
        "ownerName": b.ownerName ?? "N/A",
        "purchasePrice": b.purchasePrice.toString(), // Ensures it's a string
        "purchaseDate": b.purchaseDate?.toString() ?? "N/A", // Convert DateTime properly
        "leaseValue": b.leaseValue.toString(), // Ensures it's a string
        "lease_date": b.leaseDate?.toString() ?? "N/A", // Convert DateTime properly




      }).toList();

      _logger.i("🏗 Buildings Loaded: ${buildingAssets.length}");
      _logger.i("📝 Building Details: ${buildingAssets.map((b) => b.toString()).join("\n")}");

      return buildingAssets;
    } catch (e) {
      _logger.e("❌ Error fetching buildings: $e");
      return [];
    }
  }


  /// **🚗 Fetch Vehicles with Pagination**
  Future<List<Map<String, dynamic>>> _fetchVehicles({int page = 1}) async {
    try {
      _logger.i("🚗 Fetching vehicles... Page: $page");

      var response = await _vehicleService.fetchVehicles(page: page);
      totalVehicles.value = response['totalElements'] ?? 0;

      List<Vehicle> vehicles = (response['vehicles'] ?? []).cast<Vehicle>();
      List<Map<String, dynamic>> vehicleAssets = vehicles.map((v) => {
        "category": "Vehicle",
        "model": v.model,
        "vrn": v.vrn,
        "motValue": v.motValue,
        "insuranceValue": v.insuranceValue,
        "vehicle_type": v.vehicletype,
        "owner_name": v.ownerName,
        "isActive": v.isActive,
        "purchasePrice": v.purchasePrice, // Keep as double, no "N/A"
        "purchaseDate":(v.purchaseDate),
        "motDate": (v.motDate),
        "insuranceDate":(v.insuranceDate),
        "imageURL": v.imageURL,
        "createdBy": v.createdBy,
        "createdDate": (v.createdDate),
        "lastModifiedBy": v.lastModifiedBy,
        "lastModifiedDate": (v.lastModifiedDate),
        "milage": v.milage,
        "vehicleId": Uri.parse(v.links).pathSegments.last,
        "motExpiredDate": (v.motExpiredDate),
        "type": "Vehicle", // ✅ Ensures type is set for filtering
      }).toList();

      _logger.i("🚗 Vehicles Loaded: ${vehicleAssets.length}");
      _logger.i("📝 Vehicle Details: ${vehicleAssets.map((v) => v.toString()).join("\n")}");

      return vehicleAssets;
    } catch (e) {
      _logger.e("❌ Error fetching vehicles: $e");
      return [];
    }
  }


  /// **🌱 Fetch Lands with Pagination**
  Future<List<Map<String, dynamic>>> _fetchLands({int page = 1}) async {
    try {
      _logger.i("🌱 Fetching lands... Page: $page");

      var response = await _landService.fetchLands(page: page);
      totalLands.value = response['totalElements'] ?? 0;

      List<Land> lands = (response['lands'] ?? []).cast<Land>();
      List<Map<String, dynamic>> landAssets = lands.map((l) => {
        "category": "Land",
        "name": l.name ?? "Unknown",
        "type": l.type ?? "N/A",
        "landSize": l.size ?? "N/A",
        "address": l.address ?? "N/A",
        "city": l.city ?? "N/A",
        "purchaseDate": l.purchaseDate ?? "N/A",
        "purchasePrice": l.purchasePrice ?? "N/A",
        // 'leaseValue': l.leaseValue ?? "N/A",
        'lease_date': l.leaseDate ?? "N/A",
        "imageURL": l.imageURL ?? "",
      }).toList();

      _logger.i("🌱 Lands Loaded: ${landAssets.length}");
      _logger.i("📝 Land Details: ${landAssets.map((l) => l.toString()).join("\n")}");

      return landAssets;
    } catch (e) {
      _logger.e("❌ Error fetching lands: $e");
      return [];
    }
  }
  void deleteAsset(Map<String, dynamic> asset) {
    assets.remove(asset);
    totalAssets.value = assets.length;
    _calculateTotalAssetValue(); // Recalculate total value after deletion
    update(); // Notify listeners to refresh the UI

    _logger.i("✅ Asset Deleted: ${asset['name']}");
  }



  /// **🔄 Helper Methods**
  void _incrementPageNumbers() {
    if (hasMoreBuildings.value) currentBuildingPage.value++;
    if (hasMoreVehicles.value) currentVehiclePage.value++;
    if (hasMoreLands.value) currentLandPage.value++;
  }

  void _resetPagination() {
    currentBuildingPage.value = 1;
    currentVehiclePage.value = 1;
    currentLandPage.value = 1;
    hasMoreBuildings.value = true;
    hasMoreVehicles.value = true;
    hasMoreLands.value = true;
  }

  void _updateLoadMoreFlags() {
    hasMoreBuildings.value = currentBuildingPage.value < (totalBuildings.value ~/ 10);
    hasMoreVehicles.value = currentVehiclePage.value < (totalVehicles.value ~/ 10);
    hasMoreLands.value = currentLandPage.value < (totalLands.value ~/ 10);
  }

  void fetchAssets() {}

  getAssetsByCategory(String s) {}

  // Format total value as currency string
  String get formattedTotalValue {
    return '\$${totalAssetValue.value.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    )}';
  }
}
