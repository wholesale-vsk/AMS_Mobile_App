import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/services/data/building_service.dart';

class BuildingController extends GetxController {
  final BuildingService _buildingService = BuildingService();

  var isLoading = false.obs;

  // Form key for validation
  final GlobalKey<FormState> buildingFormKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController buildingIdController = TextEditingController();
  final TextEditingController buildingNameController = TextEditingController();
  final TextEditingController buildingTypeController = TextEditingController();
  final TextEditingController numberOfFloorsController = TextEditingController();
  final TextEditingController totalAreaController = TextEditingController();
  final TextEditingController buildingAddressController = TextEditingController();
  final TextEditingController buildingCityController = TextEditingController();
  final TextEditingController buildingProvinceController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController constructionTypeController = TextEditingController();
  final TextEditingController constructionCostController = TextEditingController();
  final TextEditingController constructionDateController = TextEditingController();
  final TextEditingController buildingImageController = TextEditingController();

  //:::::::::::::::::::::::::::::::::<< ADD BUILDING FUNCTION >>::::::::::::::::::::::::::::::::://
  Future<void> addBuilding() async {
    if (!buildingFormKey.currentState!.validate()) {
      Get.snackbar('Validation Error', 'Please fill in all required fields.');
      return;
    }

    isLoading.value = true;

    try {
      final response = await _buildingService.addBuilding(
        buildingImage: getSelectedImagePath(buildingImageController),
        buildingId: _validateInput(buildingIdController.text, isRequired: true),
        buildingName: _validateInput(buildingNameController.text, isRequired: true),
        buildingType: _validateInput(buildingTypeController.text, isRequired: true),
        numberOfFloors: _validateInput(numberOfFloorsController.text, defaultValue: '0'),
        totalArea: _validateInput(totalAreaController.text, defaultValue: '0'),
        buildingAddress: _validateInput(buildingAddressController.text, isRequired: true),
        buildingCity: _validateInput(buildingCityController.text, isRequired: true),
        buildingProvince: _validateInput(buildingProvinceController.text, isRequired: true),
        ownerName: _validateInput(ownerNameController.text, isRequired: true),
        constructionType: _validateInput(constructionTypeController.text),
        constructionCost: _validateInput(constructionCostController.text, defaultValue: '0'),
        constructionDate: _validateInput(constructionDateController.text, isRequired: true),
      );

      debugPrint('Response from API: ${response.message}');

      if (response.isSuccess) {
        Get.snackbar('Success', response.message.toString());
        clearForm();
      } else {
        debugPrint(response.message.toString());
        Get.snackbar('Error', response.message ?? 'Failed to add building.');
      }
    } catch (e) {
      debugPrint("Exception in addBuilding: ${e.toString()}");
      Get.snackbar('Error', 'Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  //:::::::::::::::::::::::::::::::::<< CLEAR FORM FUNCTION >>::::::::::::::::::::::::::::::::://
  void clearForm() {
    buildingIdController.clear();
    buildingNameController.clear();
    buildingTypeController.clear();
    numberOfFloorsController.clear();
    totalAreaController.clear();
    buildingAddressController.clear();
    buildingCityController.clear();
    buildingProvinceController.clear();
    ownerNameController.clear();
    constructionTypeController.clear();
    constructionCostController.clear();
    constructionDateController.clear();
    buildingImageController.clear();

    buildingFormKey.currentState?.reset();
  }

  //:::::::::::::::::::::::::::::::::<< HELPER FUNCTION TO HANDLE NULL VALUES >>::::::::::::::::::::::::::::::::://
  String _validateInput(String? value, {String defaultValue = '', bool isRequired = false}) {
    if (isRequired && (value == null || value.trim().isEmpty)) {
      Get.snackbar('Validation Error', 'Required field cannot be empty.');
      return defaultValue;
    }
    return value?.trim() ?? defaultValue;
  }

  //:::::::::::::::::::::::::::::::::<< GET SELECTED IMAGE PATH >>::::::::::::::::::::::::::::::::://
  String getSelectedImagePath(TextEditingController imageController) {
    return imageController.text.isNotEmpty ? imageController.text : ''; // ✅ Always returns a non-null String
  }

  //:::::::::::::::::::::::::::::::::<< DISPOSE CONTROLLERS >>::::::::::::::::::::::::::::::::://
  @override
  void onClose() {
    buildingIdController.dispose();
    buildingNameController.dispose();
    buildingTypeController.dispose();
    numberOfFloorsController.dispose();
    totalAreaController.dispose();
    buildingAddressController.dispose();
    buildingCityController.dispose();
    buildingProvinceController.dispose();
    ownerNameController.dispose();
    constructionTypeController.dispose();
    constructionCostController.dispose();
    constructionDateController.dispose();
    buildingImageController.dispose();
    super.onClose();
  }
}
