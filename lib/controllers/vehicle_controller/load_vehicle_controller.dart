import 'package:get/get.dart';
import '../../models/assets/vehicle/vehicle_model.dart';
import '../../services/data/load_vehicle.dart';


class loadVehicleController extends GetxController {
  final LoadVehicleService _vehicleService = LoadVehicleService();
  var vehicles = <Vehicle>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchVehicles();
    super.onInit();
  }

  void fetchVehicles() async {
    print("fetch hit");
    try {

      isLoading(true);
      vehicles.value = (await _vehicleService.fetchVehicles()) as List<Vehicle>;
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch vehicles");
    } finally {
      isLoading(false);
    }
  }
}
