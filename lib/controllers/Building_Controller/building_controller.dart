import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/services/data/building_service.dart';
import 'package:logger/logger.dart';

class BuildingController extends GetxController {
  final BuildingService buildingService = BuildingService();
  final Logger _logger = Logger();

  final buildingFormKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController buildingIdController = TextEditingController();
  final TextEditingController buildingNameController = TextEditingController();
  final TextEditingController buildingTypeController = TextEditingController();
  final TextEditingController numberOfFloorsController = TextEditingController();
  final TextEditingController totalAreaController = TextEditingController();
  final TextEditingController buildingAddressController = TextEditingController();
  final TextEditingController buildingCityController = TextEditingController();
  final TextEditingController buildingProvinceController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController purposeOfUseController = TextEditingController();
  final TextEditingController councilTaxController = TextEditingController();
  final TextEditingController councilTaxDateController = TextEditingController();
  final TextEditingController councilTaxValueController = TextEditingController();
  final TextEditingController leaseDateController = TextEditingController();
  final TextEditingController leaseValueController = TextEditingController();
  final TextEditingController purchaseDateController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController buildingImageController = TextEditingController();

  var isLoading = false.obs;

  /// **Add New Building**
  Future<void> addBuilding() async {
    if (!buildingFormKey.currentState!.validate()) {
      Get.snackbar('Validation Error', 'Please fill in all required fields.');
      return;
    }

    isLoading(true);

    try {
      final response = await buildingService.addBuilding(
        buildingId: buildingIdController.text.trim(),
        buildingName: buildingNameController.text.trim(),
        buildingType: buildingTypeController.text.trim().toUpperCase(),
        numberOfFloors: numberOfFloorsController.text.trim(),
        totalArea: totalAreaController.text.trim(),
        buildingAddress: buildingAddressController.text.trim(),
        buildingCity: buildingCityController.text.trim(),
        buildingProvince: buildingProvinceController.text.trim(),
        ownerName: ownerNameController.text.trim(),
        purchasePrice: purchasePriceController.text.trim(),
        purchaseDate: purchaseDateController.text.trim(),
        buildingImage: getSelectedImagePath(buildingImageController),
        purposeOfUse: purposeOfUseController.text.trim(),
        councilTax: councilTaxController.text.trim(),
        councilTaxDate: councilTaxDateController.text.trim(),
        councilTaxValue: councilTaxValueController.text.trim(),
        leaseDate: leaseDateController.text.trim(),
        leaseValue: leaseValueController.text.trim(), image: '',
      );

      if (response.isSuccess) {
        Get.snackbar('Success', response.message ?? 'Building added successfully.');
        clearForm();
      } else {
        Get.snackbar('Error', response.message ?? 'Failed to add building.');
      }
    } catch (e, stackTrace) {
      debugPrint("Exception in addBuilding: $e");
      debugPrint("StackTrace: $stackTrace");
      Get.snackbar('Error', 'An unexpected error occurred.');
    } finally {
      isLoading(false);
    }
  }

  /// **Update Existing Building**
  Future<void> updateBuilding() async {
    if (!buildingFormKey.currentState!.validate()) {
      Get.snackbar('Validation Error', 'Please fill in all required fields.');
      return;
    }

    isLoading(true);

    try {
      final response = await buildingService.updateBuilding(
        buildingId: buildingIdController.text.trim(),
        buildingName: buildingNameController.text.trim(),
        buildingType: buildingTypeController.text.trim().toUpperCase(),
        numberOfFloors: numberOfFloorsController.text.trim(),
        totalArea: totalAreaController.text.trim(),
        buildingAddress: buildingAddressController.text.trim(),
        buildingCity: buildingCityController.text.trim(),
        buildingProvince: buildingProvinceController.text.trim(),
        ownerName: ownerNameController.text.trim(),
        purchasePrice: purchasePriceController.text.trim(),
        purchaseDate: purchaseDateController.text.trim(),
        buildingImage: getSelectedImagePath(buildingImageController),
        purposeOfUse: purposeOfUseController.text.trim(),
        councilTax: councilTaxController.text.trim(),
        councilTaxDate: councilTaxDateController.text.trim(),
        councilTaxValue: councilTaxValueController.text.trim(),
        leaseDate: leaseDateController.text.trim(),
        leaseValue: leaseValueController.text.trim(),
      );
      _logger.i('Response for test: $response');

      if (response.isSuccess) {
        Get.snackbar('Success', response.message ?? 'Building updated successfully.');
        clearForm();
      } else {
        Get.snackbar('Error', response.message ?? 'Failed to update building.');
      }
    } catch (e, stackTrace) {
      debugPrint("Exception in updateBuilding: $e");
      debugPrint("StackTrace: $stackTrace");
      Get.snackbar('Error', 'An unexpected error occurred.');
    } finally {
      isLoading(false);
    }
  }

  /// **Populate Form for Editing**
  void populateFormForEditing(Map<String, dynamic> buildingData) {
    buildingIdController.text = buildingData['buildingId']?.toString() ?? '';
    buildingNameController.text = buildingData['name']?.toString() ?? '';
    buildingTypeController.text = buildingData['buildingType']?.toString() ?? '';
    numberOfFloorsController.text = buildingData['numberOfFloors']?.toString() ?? '';
    totalAreaController.text = buildingData['totalArea']?.toString() ?? '';
    buildingAddressController.text = buildingData['address']?.toString() ?? '';
    buildingCityController.text = buildingData['city']?.toString() ?? '';
    buildingProvinceController.text = buildingData['buildingProvince']?.toString() ?? '';
    ownerNameController.text = buildingData['ownerName']?.toString() ?? '';
    purposeOfUseController.text = buildingData['purposeOfUse']?.toString() ?? '';
    councilTaxController.text = buildingData['councilTax']?.toString() ?? '';
    councilTaxDateController.text = buildingData['councilTaxDate']?.toString() ?? '';
    councilTaxValueController.text = buildingData[' councilTaxValue']?.toString() ?? '';
    leaseDateController.text = buildingData['lease_date']?.toString() ?? '';
    leaseValueController.text = buildingData['leaseValue']?.toString() ?? '';
    purchaseDateController.text = buildingData['purchaseDate']?.toString() ?? '';
    purchasePriceController.text = buildingData['purchasePrice']?.toString() ?? '';
    buildingImageController.text = buildingData['buildingImage']?.toString() ?? '';
  }

  /// **Helper method to get selected image path**
  String getSelectedImagePath(TextEditingController imageController) {
    return imageController.text.trim().isNotEmpty ? imageController.text.trim() : '';
  }

  /// **Clear Form Fields**
  void clearForm() {
    final controllers = [
      buildingIdController,
      buildingNameController,
      buildingTypeController,
      numberOfFloorsController,
      totalAreaController,
      buildingAddressController,
      buildingCityController,
      buildingProvinceController,
      ownerNameController,
      purposeOfUseController,
      councilTaxController,
      councilTaxDateController,
      councilTaxValueController,
      leaseDateController,
      leaseValueController,
      purchaseDateController,
      purchasePriceController,
      buildingImageController,
    ];

    for (var controller in controllers) {
      controller.clear();
    }

    buildingFormKey.currentState?.reset();
  }

  /// **Dispose controllers when controller is destroyed**
  @override
  void onClose() {
    final controllers = [
      buildingIdController,
      buildingNameController,
      buildingTypeController,
      numberOfFloorsController,
      totalAreaController,
      buildingAddressController,
      buildingCityController,
      buildingProvinceController,
      ownerNameController,
      purposeOfUseController,
      councilTaxController,
      councilTaxDateController,
      councilTaxValueController,
      leaseDateController,
      leaseValueController,
      purchaseDateController,
      purchasePriceController,
      buildingImageController,
    ];

    for (var controller in controllers) {
      controller.dispose();
    }

    super.onClose();
  }
}