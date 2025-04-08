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
    super.onInit();
    fetchAllAssets();
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

      List<List<Map<String, dynamic>>> newAssets = [];

      if (hasMoreBuildings.value) {
        newAssets.add(await _fetchBuildings(page: currentBuildingPage.value + 1));
      }

      if (hasMoreVehicles.value) {
        newAssets.add(await _fetchVehicles(page: currentVehiclePage.value + 1));
      }

      if (hasMoreLands.value) {
        newAssets.add(await _fetchLands(page: currentLandPage.value + 1));
      }

      assets.addAll(newAssets.expand((element) => element));
      _incrementPageNumbers();
      _updateLoadMoreFlags();

      // Recalculate total value
      _calculateTotalAssetValue();

      _logger.i("📌 Total Assets After Load More: ${assets.totalElements}");
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

      // Enhanced search to look at both name and other key properties
      bool matchesSearch = query.isEmpty;
      if (!matchesSearch) {
        // Check name field
        if (asset.containsKey('name') && asset['name'] != null) {
          matchesSearch = asset['name'].toString().toLowerCase().contains(query);
        }
        // For vehicles, also check model and vrn
        if (!matchesSearch && asset['category'] == 'Vehicle') {
          if (asset.containsKey('model') && asset['model'] != null) {
            matchesSearch = asset['model'].toString().toLowerCase().contains(query);
          }
          if (!matchesSearch && asset.containsKey('vrn') && asset['vrn'] != null) {
            matchesSearch = asset['vrn'].toString().toLowerCase().contains(query);
          }
        }
        // For buildings and lands, check address
        if (!matchesSearch && (asset['category'] == 'Building' || asset['category'] == 'Land')) {
          if (asset.containsKey('address') && asset['address'] != null) {
            matchesSearch = asset['address'].toString().toLowerCase().contains(query);
          }
        }
      }

      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// **🏗 Fetch Buildings with Pagination**
  Future<List<Map<String, dynamic>>> _fetchBuildings({int page = 1}) async {
    try {
      _logger.i("🏗 Fetching buildings... Page: $page");

      var response = await _buildingService.fetchBuildings(page: page);
      totalBuildings.value = response['totalElements'] ?? 0;

      List<Building> buildings = (response['buildings'] ?? []).cast<Building>();
      List<Map<String, dynamic>> buildingAssets = buildings.map((b) => {
        "category": "Building",
        "name": (b.name.trim().isNotEmpty ?? false) ? b.name!.trim() : "N/A",
        "buildingType": b.buildingType ?? "N/A",
        "numberOfFloors": b.numberOfFloors.toString() ?? "N/A", // Handle null
        "totalArea": b.totalArea.toString() ?? "N/A", // Handle null
        "address": b.address ?? "N/A",
        "purposeOfUse": b.purposeOfUse ?? "N/A",
        "councilTaxValue": b.councilTax.toString() ?? "N/A", // Handle null
        "councilTaxDate": b.councilTaxDate.toString() ?? "N/A",
        "city": b.city ?? "N/A",
        "ownerName": b.ownerName ?? "N/A",
        "purchasePrice": b.purchasePrice.toString() ?? "N/A", // Handle null
        "purchaseDate": b.purchaseDate.toString() ?? "N/A",
        "leaseValue": b.leaseValue.toString() ?? "N/A", // Handle null
        "lease_date": b.leaseDate.toString() ?? "N/A",
        "buildingId": b.link != null? Uri.parse(b.link).pathSegments.last : "",
        "imageURL": b.buildingImage ?? "",
      }).toList();

      _logger.i("🏗 Buildings Loaded: ${buildingAssets.length}");

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
        "name": v.model ?? "N/A", // Use model as name for consistency
        "model": v.model ?? "N/A",
        "vrn": v.vrn ?? "N/A",
        "motValue": v.motValue,
        "insuranceValue": v.insuranceValue,
        "vehicle_type": v.vehicleType ?? "N/A",
        "owner_name": v.ownerName ?? "N/A",
        "purchasePrice": v.purchasePrice,
        "purchaseDate": v.purchaseDate?.toString(),
        "motDate": v.motDate?.toString(),
        "insuranceDate": v.insuranceDate?.toString(),
        "imageURL": v.imageURL ?? "", // Updated from vehicleImage to imageURL
        "createdBy": v.createdBy ?? "N/A",
        "createdDate": v.createdDate?.toString(),
        "lastModifiedBy": v.lastModifiedBy ?? "N/A",
        "lastModifiedDate": v.lastModifiedDate?.toString(),
        "mileage": v.mileage,
        "vehicleId": v.links != null ? Uri.parse(v.links).pathSegments.last : "",
        "motExpiredDate": v.motExpiredDate?.toString(),
      }).toList();

      _logger.i("🚗 Vehicles Loaded: ${vehicleAssets.length}");

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
        "name": l.name ?? "Unknown Land",
        "landType": l.landType ?? "N/A",
        "landSize": l.landSize ?? "N/A",
        "address": l.address ?? "N/A",
        "city": l.city ?? "N/A",
        "purchaseDate": l.purchaseDate?.toString() ?? "N/A",
        "purchasePrice": l.purchasePrice?.toString() ?? "N/A",
        'leaseValue': l.leaseValue?.toString() ?? "N/A",
        'lease_date': l.leaseDate?.toString() ?? "N/A",
        "imageURL": l.imageURL ?? "", // Updated from vehicleImage to imageURL
        "landId": l.links != null ? Uri.parse(l.links).pathSegments.last : "",
      }).toList();

      _logger.i("🌱 Lands Loaded: ${landAssets.length}");

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
    // Fix the calculation to properly determine if there are more pages
    hasMoreBuildings.value = totalBuildings.value > (currentBuildingPage.value * 10);
    hasMoreVehicles.value = totalVehicles.value > (currentVehiclePage.value * 10);
    hasMoreLands.value = totalLands.value > (currentLandPage.value * 10);
  }

  // Get assets by specific category
  List<Map<String, dynamic>> getAssetsByCategory(String category) {
    if (category == 'All') {
      return assets;
    }
    return assets.where((asset) => asset['category'] == category).toList();
  }

  // Format total value as currency string
  String get formattedTotalValue {
    return '\$${totalAssetValue.value.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    )}';
  }
}

extension on RxList<Map<String, dynamic>> {
  get totalElements => null;
}