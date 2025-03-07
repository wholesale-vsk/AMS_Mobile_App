import 'package:get/get.dart';
import 'package:hexalyte_ams/models/assets/land/land_model.dart';
import 'package:hexalyte_ams/services/data/load_land.dart';

class LoadLandController extends GetxController {
  final LoadLandsService _landsService = LoadLandsService(); // ✅ Corrected Service Name
  var lands = <Land>[].obs; // ✅ Corrected Model Type
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchLand(); // ✅ Corrected Method Name
    super.onInit();
  }

  /// **🔄 Fetch Lands from API**
  Future<void> fetchLand() async {
    print("🔄 Fetching Lands...");
    try {
      isLoading(true);
      List<Land> fetchedLands = (await _landsService.fetchLands()) as List<Land>;
      lands.assignAll(fetchedLands); // ✅ Corrected Way to Assign Data
      print("✅ Lands Loaded: ${lands.length}");
    } catch (e) {
      print("❌ Error Fetching Lands: $e");
      Get.snackbar("Error", "Failed to fetch lands: $e");
    } finally {
      isLoading(false);
    }
  }
}
