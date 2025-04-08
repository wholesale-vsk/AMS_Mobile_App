import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/services/data/vehicle_service.dart';
import 'package:logger/logger.dart';

class VehicleController extends GetxController {
  final VehicleService _vehicleService = VehicleService();
  final Logger _logger = Logger();
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
  final TextEditingController mileageController = TextEditingController();
  final TextEditingController vehicleIdController = TextEditingController();


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
        vehicleModel: _validateInput(vehicleModelController.text),
        vehicleType: _validateInput(vehicleTypeController.text),
        motDate: _validateInput(motDateController.text),
        motExpiredDate: _validateInput(motExpiredDateController.text),
        insuranceDate: _validateInput(insuranceDateController.text),
        insuranceValue: _validateInput(insuranceValueController.text, defaultValue: '0'),
        mileage: double.tryParse(_validateInput(mileageController.text)) ?? 0.0,
        purchasePrice: double.tryParse(_validateInput(purchasePriceController.text, defaultValue: '0')) ?? 0.0,
        motValue: _validateInput(motValueController.text, defaultValue: '0'),
        ownerName: _validateInput(ownerNameController.text),
        purchaseDate: _validateInput(purchaseDateController.text),
        vehicleImage: File(vehicleImageController.text),
      );

      _logger.i('Response for test: $response');

      if (response.isSuccess) {
        Get.snackbar('Success', response.message.toString(),
            duration: const Duration(seconds: 3));
        clearForm();
      } else {
        Get.snackbar('Error', response.message ?? 'Failed to add vehicle.',
            duration: const Duration(seconds: 3));
      }
    } catch (e, stackTrace) {
      Get.snackbar('Error', 'An unexpected error occurred. Please try again.',
          duration: const Duration(seconds: 3));
      _logger.e("Error in addVehicle", error: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  /// **UPDATE VEHICLE FUNCTION**
  Future<void> updateVehicle() async {
    if (!vehicleFormKey.currentState!.validate()) {
      Get.snackbar('Validation Error', 'Please fill in all required fields.',
          duration: const Duration(seconds: 3));
      return;
    }

    isLoading.value = true;

    try {
      final response = await _vehicleService.updateVehicle(
        registrationNumber: _validateInput(registrationNumberController.text),
        vehicleModel: _validateInput(vehicleModelController.text),
        vehicleType: _validateInput(vehicleTypeController.text),

        motDate: _validateInput(motDateController.text),
        motExpiredDate: _validateInput(motExpiredDateController.text),
        insuranceDate: _validateInput(insuranceDateController.text),
        insuranceValue: _validateInput(insuranceValueController.text, defaultValue: '0'),
        mileage: double.tryParse(_validateInput(mileageController.text)) ?? 0.0,
        purchaseDate: _validateInput(purchaseDateController.text),
        purchasePrice: double.tryParse(_validateInput(purchasePriceController.text, defaultValue: '0')) ?? 0.0, // Changed to double to match service
        motValue: _validateInput(motValueController.text, defaultValue: '0'),
        ownerName: _validateInput(ownerNameController.text),
        vehicleId: _validateInput(vehicleIdController.text), vehicleImage: '',
        // vehicleImage: File(vehicleImageController.text),
      );

      _logger.i('Response for update: $response');

      if (response.isSuccess) {
        Get.snackbar('Success', response.message.toString(),
            duration: const Duration(seconds: 3));
        clearForm();
      } else {
        Get.snackbar('Error', response.message ?? 'Failed to update vehicle.',
            duration: const Duration(seconds: 3));
      }
    } catch (e, stackTrace) {
      Get.snackbar('Error', 'An unexpected error occurred. Please try again.',
          duration: const Duration(seconds: 3));
      _logger.e("Error in updateVehicle", error: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }
  // /// **Delete Existing Vehicle**
  // Future<void> deleteVehicle() async {
  //   // Ensure a vehicle ID is selected
  //   if (vehicleIdController.text.trim().isEmpty) {
  //     Get.snackbar('Validation Error', 'Please select a vehicle to delete.');
  //     return;
  //   }
  //
  //   // Show confirmation dialog
  //   final confirmDelete = await Get.defaultDialog(
  //     title: 'Confirm Deletion',
  //     middleText: 'Are you sure you want to delete this vehicle?',
  //     textConfirm: 'Delete',
  //     textCancel: 'Cancel',
  //     onConfirm: () => Get.back(result: true),
  //     onCancel: () => Get.back(result: false),
  //   );
  //
  //   // Exit if not confirmed
  //   if (confirmDelete != true) return;
  //
  //   isLoading(true);
  //
  //   try {
  //     // final response = await _vehicleService.deleteVehicle(
  //       vehicleId: vehicleIdController.text.trim(),
  //     );
  //
  //     if (response.isSuccess) {
  //       Get.snackbar('Success', response.message ?? 'Vehicle deleted successfully.');
  //       clearForm();
  //       await fetchVehicles(); // Refresh the list
  //     } else {
  //       Get.snackbar('Error', response.message ?? 'Failed to delete vehicle.');
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint("Exception in deleteVehicle: $e");
  //     debugPrint("StackTrace: $stackTrace");
  //     Get.snackbar('Error', 'An unexpected error occurred.');
  //   } finally {
  //     isLoading(false);
  //   }
  // }

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
    mileageController.clear();
    vehicleIdController.clear(); // Added to clear vehicle ID
  }

  //:::::::::::::::::::::::::::::::::<< HELPER FUNCTION TO HANDLE NULL VALUES >>::::::::::::::::::::::::::::::::://
  String _validateInput(String? value, {String defaultValue = ''}) {
    return value != null && value.trim().isNotEmpty ? value.trim() : defaultValue;
  }

  @override
  void onClose() {
    // Dispose all controllers
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
    mileageController.dispose();
    vehicleIdController.dispose(); // Added to dispose vehicle ID controller
    super.onClose();
  }

  fetchVehicles() {}
}