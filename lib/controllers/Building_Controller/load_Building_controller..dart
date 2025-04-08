import 'package:get/get.dart';

import '../../models/assets/building/building_model.dart';
import '../../services/data/load_building.dart'; // Assuming this is the correct model path

class LoadBuildingController extends GetxController {
  final LoadBuildingService _buildingService = LoadBuildingService();
  var buildings = <Building>[].obs;
  var isLoading = false.obs;



  @override
  void onInit() {
    fetchBuildings();
    super.onInit();
  }

  void fetchBuildings() async {
    print("Fetching buildings...");
    try {
      isLoading(true);
      buildings.value = (await _buildingService.fetchBuildings()) as List<Building>;
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch buildings");
    } finally {
      isLoading(false);
    }
  }
}
