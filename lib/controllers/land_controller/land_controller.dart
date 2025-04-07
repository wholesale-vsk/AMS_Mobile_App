import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/services/data/land_service.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';


class LandController extends GetxController {
  final LandService _landService = LandService(); // ✅ Fixed Service Name
  final Logger _logger = Logger();

  var isLoading = false.obs;

  // Form key for validation
  final GlobalKey<FormState> landFormKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController landIdController = TextEditingController();
  final TextEditingController landNameController = TextEditingController();
  final TextEditingController landTypeController = TextEditingController();
  final TextEditingController landSizeController = TextEditingController();
  final TextEditingController landAddressController = TextEditingController();
  final TextEditingController landCityController = TextEditingController();
  final TextEditingController landProvinceController = TextEditingController();
  final TextEditingController purchaseDateController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController leaseDateController = TextEditingController();
  final TextEditingController landImageController = TextEditingController();
  // late final File landImageFileController = File('');
  final TextEditingController leaseValueController = TextEditingController();


  Future<void> uploadImage() async {

  }


  //:::::::::::::::::::::::::::::::::<< ADD LAND FUNCTION >>::::::::::::::::::::::::::::::::://
  Future<void> addLand() async {
    if (!landFormKey.currentState!.validate()) {
      Get.snackbar('Validation Error', 'Please fill in all required fields.');
      return;
    }

    isLoading.value = true;

    try {
      final response = await _landService.addLand(
        landName: _validateInput(landNameController.text, isRequired: true),
        landType: _validateInput(landTypeController.text, isRequired: true),
        landSize: _validateInput(landSizeController.text, defaultValue: '0'),
        landAddress: _validateInput(
            landAddressController.text, isRequired: true),
        landCity: _validateInput(landCityController.text, isRequired: true),
        purchaseDate: _validateInput(
            purchaseDateController.text, isRequired: true),
        purchasePrice: _validateInput(
            purchasePriceController.text, defaultValue: '0'),

        leaseDate: _validateInput(leaseDateController.text, isRequired: true),
        leaseValue: _validateInput(leaseValueController.text, isRequired: true),
        landImage: File(landImageController.text),

      );

      _logger.i('Response for test: $response');

      if (response.isSuccess) {
        Get.snackbar('Success', response.message.toString());
        clearForm();
      } else {
        debugPrint(response.message.toString());
        Get.snackbar('Error', response.message ?? 'Failed to add land.');
      }
    } catch (e) {
      debugPrint("Exception in addLand: ${e.toString()}");
      Get.snackbar('Error', 'Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// **Delete Existing Land**
  Future<void> deleteLand() async {
    // Ensure a land ID is selected
    if (landIdController.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please select a land to delete.');
      return;
    }

    // Show confirmation dialog
    final confirmDelete = await Get.defaultDialog(
      title: 'Confirm Deletion',
      middleText: 'Are you sure you want to delete this land?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );

    // Exit if not confirmed
    if (confirmDelete != true) return;

    isLoading(true);

    try {
      final response = await _landService.deleteLand(
        landId: landIdController.text.trim(),
      );

      if (response.isSuccess) {
        Get.snackbar('Success', response.message ?? 'Land deleted successfully.');
        clearForm();
      } else {
        Get.snackbar('Error', response.message ?? 'Failed to delete land.');
      }
    } catch (e, stackTrace) {
      debugPrint("Exception in deleteLand: $e");
      debugPrint("StackTrace: $stackTrace");
      Get.snackbar('Error', 'An unexpected error occurred.');
    } finally {
      isLoading(false);
    }
  }

  //:::::::::::::::::::::::::::::::::<< CLEAR FORM FUNCTION >>::::::::::::::::::::::::::::::::://
  void clearForm() {
    landIdController.clear();
    landNameController.clear();
    landTypeController.clear();
    landSizeController.clear();
    landAddressController.clear();
    landCityController.clear();
    landProvinceController.clear();
    purchaseDateController.clear();
    purchasePriceController.clear();
    landImageController.clear(); // ❌ Removed to retain image
    leaseDateController.clear();
    leaseValueController.clear();

    // Reset form validation state
    landFormKey.currentState?.reset();
  }

  // //:::::::::::::::::::::::::::::::::<< AUTO FILL FUNCTION (FOR TESTING) >>::::::::::::::::::::::::::::::::://
  // void autoFill() {
  //   landNameController.text = 'Land 1';
  //   landTypeController.text = 'Agricultural';
  //   landSizeController.text = '5000';
  //   landAddressController.text = '123 Green Street';
  //   landCityController.text = 'Colombo';
  //   landProvinceController.text = 'Western';
  //   purchaseDateController.text = '2023-01-01';
  //   purchasePriceController.text = '5000000';
  //   landImageController.text = 'image_url_here';
  //   leaseDateController.text = '2023-01-01';
  //   leaseValueController.text = '1000000';
  // }

  //:::::::::::::::::::::::::::::::::<< HELPER FUNCTION TO HANDLE NULL VALUES >>::::::::::::::::::::::::::::::::://
  String _validateInput(String? value,
      {String defaultValue = '', bool isRequired = false}) {
    if (isRequired && (value == null || value
        .trim()
        .isEmpty)) {
      return defaultValue;
    }
    return value
        ?.trim()
        .isNotEmpty == true ? value!.trim() : defaultValue;
  }

  //:::::::::::::::::::::::::::::::::<< DISPOSE CONTROLLERS >>::::::::::::::::::::::::::::::::://
  @override
  void onClose() {
    landIdController.dispose();
    landNameController.dispose();
    landTypeController.dispose();
    landSizeController.dispose();
    landAddressController.dispose();
    landCityController.dispose();
    landProvinceController.dispose();
    purchaseDateController.dispose();
    purchasePriceController.dispose();
    landImageController.dispose();
    leaseDateController.dispose();
    leaseValueController.dispose();

    super.onClose();
  }

  updateLand(asset) async {
    try {
      final response = await _landService.updateLand(
        landName: _validateInput(landNameController.text, isRequired: true),
        landType: _validateInput(landTypeController.text, isRequired: true),
        landSize: _validateInput(landSizeController.text, defaultValue: '0'),
        landAddress: _validateInput(
            landAddressController.text, isRequired: true),
        landCity: _validateInput(landCityController.text, isRequired: true),
        purchaseDate: _validateInput(
            purchaseDateController.text, isRequired: true),
        purchasePrice: _validateInput(
            purchasePriceController.text, defaultValue: '0'),
        landImage: _validateInput(landImageController.text),
        leaseDate: _validateInput(leaseDateController.text, isRequired: true),
        leaseValue: _validateInput(leaseValueController.text, isRequired: true),
        landId: _validateInput(landIdController.text, isRequired: true),
      );

      _logger.i('Response for test: $response');


      if (response.isSuccess) {
        Get.snackbar('Success', response.message.toString());
        clearForm();
      } else {
        debugPrint(response.message.toString());
        Get.snackbar('Error', response.message ?? 'Failed to add land.');
      }
    } catch (e) {
      debugPrint("Exception in addLand: ${e.toString()}");
      Get.snackbar('Error', 'Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }


}
