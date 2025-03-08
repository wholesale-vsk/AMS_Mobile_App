import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexalyte_ams/services/data/land_service.dart';
import 'package:flutter/foundation.dart';

class LandController extends GetxController {
  final loadLandService _landService = loadLandService();

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
  final TextEditingController landImageController = TextEditingController();
  final TextEditingController councilTaxDateController = TextEditingController();
  final TextEditingController councilTaxValueController = TextEditingController();
  final TextEditingController leaseDateController = TextEditingController();
  final TextEditingController leaseValueController = TextEditingController();


  //:::::::::::::::::::::::::::::::::<< ADD LAND FUNCTION >>::::::::::::::::::::::::::::::::://
  Future<void> addLand() async {
    if (!landFormKey.currentState!.validate()) {
      Get.snackbar('Validation Error', 'Please fill in all required fields.');
      return;
    }

    isLoading.value = true;

    try {
      final response = await _landService.addLand(
        // ✅ Added missing landId parameter
        landName: _validateInput(landNameController.text, isRequired: true),
        landType: _validateInput(landTypeController.text, isRequired: true),
        landSize: _validateInput(landSizeController.text, defaultValue: '0'),
        landAddress:
            _validateInput(landAddressController.text, isRequired: true),
        landCity: _validateInput(landCityController.text, isRequired: true),
        landProvince:
            _validateInput(landProvinceController.text, isRequired: true),
        purchaseDate:
            _validateInput(purchaseDateController.text, isRequired: true),
        purchasePrice:
            _validateInput(purchasePriceController.text, defaultValue: '0'),
        landImage: _validateInput(landImageController.text),
        councilTaxDate: _validateInput(councilTaxDateController.text, isRequired: true),
        councilTaxValue: _validateInput(councilTaxValueController.text, isRequired: true),
        leaseDate: _validateInput(leaseDateController.text, isRequired: true),
        leaseValue: _validateInput(leaseValueController.text, isRequired: true),



      );

      print('response for test: $response');

      if (response.isSuccess) {
        Get.snackbar('Success', response.message.toString());
        clearForm();
        // Navigate after success (optional)
        // Get.offNamed('/landList');
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
    landImageController.clear();
    councilTaxDateController.clear();
    councilTaxValueController.clear();
    leaseDateController.clear();
    leaseValueController.clear();
    landImageController .clear();
    // Reset form validation state
    landFormKey.currentState?.reset();
  }
  void autoFill() {
    landNameController.text = 'Land 1';
    landTypeController.text = 'Land Type 1';
    landSizeController.text = '100';
    landAddressController.text = 'Land Address 1';
    landCityController.text = 'Land City 1';
    landProvinceController.text = 'Land Province 1';
    purchaseDateController.text = '2023-01-01';
    purchasePriceController.text = '1000';

    councilTaxDateController.text = '2023-01-01';
    councilTaxValueController.text = '1000';

  }

  //:::::::::::::::::::::::::::::::::<< HELPER FUNCTION TO HANDLE NULL VALUES >>::::::::::::::::::::::::::::::::://
  String _validateInput(String? value,
      {String defaultValue = '', bool isRequired = false}) {
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return defaultValue;
    }
    return value?.trim().isNotEmpty == true ? value!.trim() : defaultValue;
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
    councilTaxDateController.dispose();
    councilTaxValueController.dispose();
    landImageController.dispose();

    super.onClose();
  }
}

// class LandService {
//   addLand(
//       {required String landName,
//       required String landType,
//       required String landSize,
//       required String landAddress,
//       required String landCity,
//       required String landProvince,
//       required String purchaseDate,
//       required String purchasePrice,
//       required String landImage}) {
//
//   }
// }
