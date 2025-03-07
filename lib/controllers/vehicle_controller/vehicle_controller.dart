import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/services/data/vehicle_service.dart';

class VehicleController extends GetxController {
  final VehicleService _vehicleService = VehicleService();

  var isLoading = false.obs;

  // Form key for validation
  final GlobalKey<FormState> vehicleFormKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController brandController = TextEditingController();
  final TextEditingController registrationNumberController = TextEditingController();
  final TextEditingController vehicleCategoryController = TextEditingController();
  final TextEditingController vehicleModelController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController vehicleImageController = TextEditingController();
  final TextEditingController motDateController = TextEditingController();
  final TextEditingController motExpiredDateController = TextEditingController();
  final TextEditingController serviceDateController = TextEditingController();
  final TextEditingController purchaseDateController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController insuranceDateController = TextEditingController();
  final TextEditingController insuranceValueController = TextEditingController();
  final TextEditingController motValueController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();

  // Repairs Section
  final TextEditingController repairTypeController = TextEditingController();
  final TextEditingController mileageAtRepairController = TextEditingController();
  var repairs = <Map<String, dynamic>>[].obs;

  /// **ADD VEHICLE FUNCTION**
  Future<void> addVehicle() async {
    if (!vehicleFormKey.currentState!.validate()) {
      Get.snackbar('Validation Error', 'Please fill in all required fields.',
          duration: const Duration(seconds: 3));
      return;
    }

    isLoading.value = true;

    try {
      final response = await _vehicleService.addVehicle(
        registrationNumber: _validateInput(registrationNumberController.text),
        vehicleCategory: _validateInput(vehicleCategoryController.text),
        vehicleModel: _validateInput(vehicleModelController.text),
        vehicleType: _validateInput(vehicleTypeController.text),
        vehicleImage: _validateInput(vehicleImageController.text),
        motDate: _validateInput(motDateController.text),
        motExpiredDate: _validateInput(motExpiredDateController.text),

        purchaseDate: _validateInput(purchaseDateController.text),
        purchasePrice: _validateInput(purchasePriceController.text, defaultValue: '0'),
        motValue: _validateInput(motValueController.text, defaultValue: '0'),
        ownerName: _validateInput(ownerNameController.text),
      );

      print('response for test: $response');

      if (response.isSuccess) {
        Get.snackbar('Success', response.message.toString(),
            duration: const Duration(seconds: 3));
        clearForm(); // ✅ Clears form after success
      } else {
        Get.snackbar('Error', response.message ?? 'Failed to add vehicle.',
            duration: const Duration(seconds: 3));
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: ${e.toString()}',
          duration: const Duration(seconds: 3));
      debugPrint("🚨 Error in addVehicle: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// **ADD REPAIR FUNCTION**
  void addRepair() {
    if (repairTypeController.text.isNotEmpty && mileageAtRepairController.text.isNotEmpty) {
      repairs.add({
        "type": repairTypeController.text,
        "mileage": int.tryParse(mileageAtRepairController.text) ?? 0,
      });
      repairTypeController.clear();
      mileageAtRepairController.clear();
    } else {
      Get.snackbar("Validation Error", "Please enter repair type and mileage.",
          duration: const Duration(seconds: 3));
    }
  }

  /// **REMOVE REPAIR FUNCTION**
  void removeRepair(int index) {
    repairs.removeAt(index);
  }




  /// **CLEAR FORM AFTER SUCCESS**
  void clearForm() {
    brandController.clear();
    registrationNumberController.clear();
    vehicleCategoryController.clear();
    vehicleModelController.clear();
    vehicleTypeController.clear();
    vehicleImageController.clear();
    motDateController.clear();
    motExpiredDateController.clear();
    serviceDateController.clear();
    purchaseDateController.clear();
    purchasePriceController.clear();
    insuranceDateController.clear();
    insuranceValueController.clear();
    motValueController.clear();
    ownerNameController.clear();
    repairs.clear();
  }


  //:::::::::::::::::::::::::::::::::<< HELPER FUNCTION TO HANDLE NULL VALUES >>::::::::::::::::::::::::::::::::://
  String _validateInput(String? value,
      {String defaultValue = '', bool isRequired = false}) {
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return defaultValue;
    }
    return value?.trim().isNotEmpty == true ? value!.trim() : defaultValue;
  }

  @override
  void onClose() {
    brandController.dispose();
    registrationNumberController.dispose();
    vehicleCategoryController.dispose();
    vehicleModelController.dispose();
    vehicleTypeController.dispose();
    vehicleImageController.dispose();
    motDateController.dispose();
    motExpiredDateController.dispose();
    serviceDateController.dispose();
    purchaseDateController.dispose();
    purchasePriceController.dispose();
    insuranceDateController.dispose();
    insuranceValueController.dispose();
    motValueController.dispose();
    ownerNameController.dispose();
    repairTypeController.dispose();
    mileageAtRepairController.dispose();
    super.onClose();
  }
}
